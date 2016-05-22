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
    
    
    /** (readonly) */
    public var isCancelled : Bool {
        if let queue = self.runningBlockInQueue {
            let testResult = dispatch_block_testcancel(queue)
            return Bool(testResult)
        }
        return false
    }
    
    /** (read only) */
    public internal(set) var api:API
    /** (read only) */
    public internal(set) var running:Bool = false
    /** (read only) */
    
    //MARK: internal variables
    internal var runningBlockInQueue:dispatch_block_t!
    public internal(set) var params:Parameters = []
    
    internal var sessionTask:NSURLSessionTask?
    
    public internal(set) var responseAssistants:[Assistant] = []
    public internal(set)  var failedResponseAssistants:[Assistant] = []
    public internal(set)  var cancelledAssistant: Assistant?
    
    public var allowedMIMEs: [MIMEType]{
        
        return self.responseAssistants.reduce([MIMEType]()) { (MIMEs, responseAssistant) -> [MIMEType] in
            
            if let MIMEAssistant = responseAssistant as? MIMESupport {
                return MIMEs + MIMEAssistant.allowedMIMEs
            }

            return MIMEs
        }
    }
    
    lazy var queue: dispatch_queue_t = dispatch_queue_create(self.identifier, DISPATCH_QUEUE_SERIAL)
    
    convenience init<T:ParameterValue>(API api:API, params:[String: T], connector: Connector = Acclaim.configuration.connector) {
        let params = Parameters(dictionary: params)
        self.init(API: api, params: params, connector: connector)
    }
    
    required public init(API api:API, params:Parameters = [], connector: Connector = Acclaim.configuration.connector) {
        self.api = api
        self.params = params
        self.configuration.connector = connector
        
        if let sharedRequestParameters = Acclaim.sharedRequestParameters {
            self.params.addParams(sharedRequestParameters)
        }
        
    }
    
    internal func run(connector connector: Connector, completion: ((data: NSData?, connection: Connection, error: NSError?) -> Void)?){
        
        guard !self.running else {
            return
        }
        
        // set
        self.sessionTask = connector._request(API: self.api, params: self.params, configuration: self.configuration) {[unowned self] (task, response, error) in
            
            let connection = Connection(originalRequest: task.originalRequest, currentRequest: task.currentRequest, response: response, requestMIMEs: self.allowedMIMEs, cached: false)
            let data = task.data.copy() as! NSData
            completion?(data: data, connection: connection, error: error)
            
            self.handleResponses(data: data, connection: connection, error: error)
            
            //remove
            Acclaim.removeRunningCaller(self)
            
            self.runningBlockInQueue = nil
            self.running = false
            
        }
        
        self.sessionTask?.apiCaller = self
        
        defer{
            self.running = true
        }
        
    }

    public func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?) -> Void)?) {
        
        let block = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_DETACHED, self.configuration.priority.qos_class, self.configuration.priority.relative_priority) {[unowned self] () -> Void in
            self.run(connector: self.configuration.connector, completion: completion)
        }
        
        self.runningBlockInQueue = block
        dispatch_barrier_async(self.queue, block)
        
        //add
        Acclaim.addRunningCaller(self)
        
    }
    
    public func suspend() {
        self.sessionTask?.suspend()
    }
    
    public func cancel(){
        
        //插入cancel指令到running之後
        dispatch_sync(self.queue) {
            
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
            
            self.running = false
            self.sessionTask?.cancel()
            
            dispatch_block_cancel(self.runningBlockInQueue)
            
        }
        
    }
    
    deinit{
        ACDebugLog("APICaller : [\(unsafeAddressOf(self))] deinit")
    }
}

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
            
            self.responseAssistants.forEach { reciver in
                
                if let error = reciver.handle(data, connection: connection, error: error) {
                    self.handleFailedResponse(data: data, connection: connection, error: error)
                }
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