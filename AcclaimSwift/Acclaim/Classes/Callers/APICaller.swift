//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public enum ProcessHandlerType : String {
    case Sending = "Sending"
    case Receiving = "Receiving"
}

public class APICaller : Caller, APISupport, ResponseSupport, Configurable, MIMESupport, CancelSupport {
    
    public var identifier: String = String(NSDate().timeIntervalSince1970)
    public var configuration: Acclaim.Configuration = Acclaim.configuration
    
    public var taskType: RequestTaskType
    
    //MARK: readonly variables
    
    /** (readonly) */
    public var isCancelled : Bool {
        return self.isBlockCanncelled && (self.sessionTask?.state == NSURLSessionTaskState.Canceling)
    }
    
    /** (read only) */
    public internal(set) var api:API
    /** (read only) */
    public var running:Bool{
        return self.sessionTask?.state == NSURLSessionTaskState.Running
    }
    
    /** (read only) */
    public internal(set) var params:Parameters = []
    /** (read only) */
    public internal(set) var responseAssistants:[Assistant] = []
    /** (read only) */
    public internal(set) var failedResponseAssistants:[Assistant] = []
    /** (read only) */
    public internal(set) var cancelledAssistant: Assistant?
    
    /** (read only) */
    public var allowedMIMEs: [MIMEType]{
        
        return self.responseAssistants.reduce([MIMEType]()) { (MIMEs, responseAssistant) -> [MIMEType] in
            
            if let MIMEAssistant = responseAssistant as? MIMESupport {
                return MIMEs + MIMEAssistant.allowedMIMEs
            }
            
            return MIMEs
        }
    }
    
    //MARK: internal variables
    
    internal var isBlockCanncelled : Bool {
        let testResult = dispatch_block_testcancel(self.runningBlockInQueue)
        return Bool(testResult)
    }
    
    internal var runningBlockInQueue:dispatch_block_t!{
        didSet{
            guard let block = self.runningBlockInQueue else{
                return
            }
            dispatch_block_notify(block, self.queue) { [unowned self] in
                self.sessionTask?.apiCaller = self
                Acclaim.addRunningCaller(self)
            }
        }
    }
    
    internal var sessionTask:NSURLSessionTask?
    internal lazy var queue: dispatch_queue_t = dispatch_queue_create(self.identifier, DISPATCH_QUEUE_SERIAL)
    
    //MARK: -
    public init(API api:API, params:Parameters = [], taskType: RequestTaskType = .DataTask, configuration: Acclaim.Configuration = Acclaim.configuration) {
        self.api = api
        self.params = params
        self.configuration = configuration
        self.taskType = taskType
        
        if let sharedRequestParameters = Acclaim.sharedRequestParameters {
            self.params.addParams(sharedRequestParameters)
        }
        
    }
    
    
    public convenience init<T:ParameterValue>(API api:API, paramsDict:[String:T] = [:], taskType: RequestTaskType = .DataTask, configuration: Acclaim.Configuration = Acclaim.configuration) {
        
        let params = Parameters(dictionary: paramsDict)
        self.init(API: api, params:params, taskType:taskType, configuration: configuration)
    }
    
    public convenience init<T:ParameterValue>(API api:API, paramsDict:[String:[T]] = [:], taskType: RequestTaskType = .DataTask, configuration: Acclaim.Configuration = Acclaim.configuration) {
        let params = Parameters(dictionary: paramsDict)
        self.init(API: api, params:params, taskType:taskType, configuration: configuration)
    }
    
    public convenience init<T:ParameterValue>(API api:API, paramsDict:[String:[String:T]] = [:], taskType: RequestTaskType = .DataTask, configuration: Acclaim.Configuration = Acclaim.configuration) {
        let params = Parameters(dictionary: paramsDict)
        self.init(API: api, params:params, taskType:taskType, configuration: configuration)
    }
    
    //MARK: -
    internal func run(connector connector: Connector){
        
        guard !self.running else {
            return
        }
        
        // set
        self.sessionTask = connector._request(API: self.api, params: self.params, requestTaskType: self.taskType, configuration: self.configuration) {[unowned self] (task, response, error) in
            
            let connection = Connection(originalRequest: task.originalRequest, currentRequest: task.currentRequest, response: response, requestMIMEs: self.allowedMIMEs, cached: false)
            let data = task.data.copy() as! NSData
            self.handleResponses(data: data, connection: connection, error: error)
            
            //remove
            Acclaim.removeRunningCaller(self)
            
        }
        
        self.sessionTask?.resume()
    }

    public func resume() {
        
        let block = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_ENFORCE_QOS_CLASS, self.configuration.priority.qos_class, self.configuration.priority.relative_priority) {[unowned self] in
            self.run(connector: self.configuration.connector)
        }
        
        self.runningBlockInQueue = block
        dispatch_sync(self.queue, block)
        
        
//        dispatch_block_perform(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block)
        
        
        
        
    }
    
    public func suspend() {
        
        dispatch_sync(self.queue) { [unowned self] in
            self.sessionTask?.suspend()
        }
        
        Acclaim.removeRunningCaller(self)
    }
    
    public func cancel(){
        
        //插入cancel指令到running之後
        dispatch_sync(self.queue) {[unowned self] in
            
            //Ignore if APICaller is not running.
            guard self.running else {
                ACDebugLog("Caller is not running. Please perform `func resume()` to run your api.")
                return
            }
            
            //Ignore if APICaller has been cannceled.
            guard !self.isCancelled else {
                ACDebugLog("Caller has been cannceled. Please perform `func resume()` to run your api.")
                return
            }

            self.sessionTask?.cancel()
            Acclaim.removeRunningCaller(self)
            dispatch_block_cancel(self.runningBlockInQueue)
            
        }
        
    }
    
    //MARK: -
    deinit{
        ACDebugLog("APICaller : [\(unsafeAddressOf(self))] deinit")
    }
}


//MARK: - Response Handler

extension APICaller {
    
    internal func handleCachedResponse(cachedResponse: NSCachedURLResponse, byRequest request: NSURLRequest){
        let connection = Connection(originalRequest: request, currentRequest: request, response: cachedResponse.response, requestMIMEs: self.allowedMIMEs, cached: true)
        self.handleResponses(fromCached: true)(data: cachedResponse.data, connection: connection, error: nil)
    }

    internal func handleResponses(data data:NSData?, connection: Connection, error:NSError?){
        self.handleResponses()(data: data, connection: connection, error: error)
    }
    
    internal func handleResponses(fromCached cached: Bool = false)->(data:NSData?, connection: Connection, error:NSError?)->Void{
        
        return {[unowned self] (data:NSData?, connection: Connection, error:NSError?)->Void in
            
            guard !self.isCancelled else {
                //檢查cancel的訊息，並在這裡回傳resumedData
                self.cancelledAssistant?.handle(data, connection: connection, error: nil)
                return
            }
            
            guard error == nil else {
                //remove cached response data by renewRule : RenewByRetry
                
                //before this request
                if let cachedResponse = Acclaim.cachedResponse(request: connection.currentRequest) {
                    self.handleCachedResponse(cachedResponse, byRequest: connection.currentRequest)
                }
                
                
                if error?.code == -999 && error?.localizedDescription == "cancelled" {
                    self.cancelledAssistant?.handle(data, connection: connection, error: error)
                }else{
                    self.handleFailedResponse(data: data, connection: connection, error: error)
                }
                
                return
            }
            
            if let response = connection.response, let data = data where cached == false{
                let cacheStoragePolicy = NSURLCacheStoragePolicy(self.configuration.cacheStoragePolicy)
                let cachedResponse = NSCachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: cacheStoragePolicy)
                Acclaim.storeCachedResponse(cachedResponse, forRequest: connection.currentRequest)
            }
            
            self.responseAssistants.forEach { receiver in
                receiver.handle(data, connection: connection, error: error)
            }
        }
        
    }
    
    internal func handleFailedResponse(data data:NSData?, connection: Connection, error:NSError?) {
        
        self.failedResponseAssistants.forEach { $0.handle(data, connection: connection, error: error) }
    }
    
    
    public func handle<T : ResponseAssistant>(responseType type: ResponseAssistantType, assistant: T) -> T {
        switch type {
        case .Success:
            self.responseAssistants.append(assistant)
        case .Failed:
            self.failedResponseAssistants.append(assistant)
        }
        
        return assistant
    }
    
}

//handle sending/receving processing
extension APICaller {
    
    public func cancelled(handler: ResumeDataResponseAssistant.Handler) -> Self {
        self.cancelledAssistant = ResumeDataResponseAssistant(handler: handler)
        return self
    }
    
}


/// A enum describes how `ResponseCached` should cache into a storage.
public enum CacheStoragePolicy{
    
    /// A enum describes the renew rule by the response failed.
    public enum RenewRule {
        
        case NotRenewed
        /// Not implemented.
        case RenewSinceDate(data: NSDate)
        /// Not implemented.
        case RenewByRetry(limitCount: Int)
        
        internal static let DefaultRetryCount = 4
    }
    
    /// Response will be cached into a storage.
    case Allowed(renewRule: RenewRule)
    /// Response will be cached into a memory only.
    case AllowedInMemoryOnly(renewRule: RenewRule)
    /// Response should not be cached.
    case NotAllowed
    
    internal var renewRule: RenewRule {
        switch self {
        case .Allowed(let renewRule):
            return renewRule
        case .AllowedInMemoryOnly(let renewRule):
            return renewRule
        case .NotAllowed:
            return .NotRenewed
        }
    }
}

//MARK: - RenewRule internal methods
extension CacheStoragePolicy.RenewRule {
    
    internal var _method:String{
        switch self {
        case .NotRenewed:
            return "NotRenewed"
        case .RenewSinceDate:
            return "RenewSinceDate"
        case .RenewByRetry:
            return "RenewByRetry"
        }
    }
}



extension NSURLCacheStoragePolicy {
    public init(_ rawValue: CacheStoragePolicy) {
        switch rawValue{
        case .Allowed:
            self = .Allowed
        case .AllowedInMemoryOnly:
            self = .AllowedInMemoryOnly
        case .NotAllowed:
            self = .NotAllowed
        }
    }
}

extension CacheStoragePolicy {
    
    public init(_ rawValue: NSURLCacheStoragePolicy){
        switch rawValue {
        case .Allowed:
            self = .Allowed(renewRule: .NotRenewed)
        case .AllowedInMemoryOnly:
            self = .AllowedInMemoryOnly(renewRule: .NotRenewed)
        case .NotAllowed:
            self = .NotAllowed
        }
    }
}