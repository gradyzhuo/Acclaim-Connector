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
    
    public var identifier: String = String(Date().timeIntervalSince1970)
    public var configuration: Acclaim.Configuration = Acclaim.configuration
    
    public var taskType: RequestTaskType
    
    //MARK: readonly variables
    
    /** (readonly) */
    public var isCancelled : Bool {
        return self.isBlockCanncelled && (self.sessionTask?.state == .canceling)
    }
    
    /** (read only) */
    public internal(set) var api:API
    /** (read only) */
    public var running:Bool{
        return self.sessionTask?.state == URLSessionTask.State.running
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
        return self.runningItem.isCancelled
    }
    
    internal var runningItem:DispatchWorkItem!{
        didSet{
            guard let item = self.runningItem else{
                return
            }
            
            item.notify(queue: self.queue) { 
                [unowned self] in
                self.sessionTask?.apiCaller = self
                Acclaim.add(runningCaller: self)
            }

        }
    }
    
    internal var sessionTask:URLSessionTask?
    internal lazy var queue: DispatchQueue = DispatchQueue(label: self.identifier, attributes: DispatchQueueAttributes.serial)
    
    //MARK: -
    public init(API api:API, params:Parameters = [], taskType: RequestTaskType = .DataTask, configuration: Acclaim.Configuration = Acclaim.configuration) {
        self.api = api
        self.params = params
        self.configuration = configuration
        self.taskType = taskType
        
        if let sharedRequestParameters = Acclaim.sharedRequestParameters {
            self.params.add(params: sharedRequestParameters)
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
    internal func run(by connector: Connector){
        
        guard !self.running else {
            return
        }
        
        // set
        self.sessionTask = connector._request(API: self.api, params: self.params, requestTaskType: self.taskType, configuration: self.configuration) {[unowned self] (task, response, error) in
            
            let connection = Connection(originalRequest: task.originalRequest, currentRequest: task.currentRequest, response: response, requestMIMEs: self.allowedMIMEs, cached: false)
            let data = task.data
            self.handleResponses(data: data, connection: connection, error: error)
            
            //remove
            Acclaim.remove(runningCaller: self)
            
        }
        
        self.sessionTask?.resume()
    }

    public func resume() {
        
        let item = DispatchWorkItem(qos: self.configuration.priority.qos, flags: .enforceQoS) { [unowned self] in
            self.run(by: self.configuration.connector)
        }
        
        self.runningItem = item
        self.queue.sync(execute: item)
        
        
    }
    
    public func cancel(){
        
        //插入cancel指令到running之後
        self.queue.sync {[unowned self] in
            
            //Ignore if APICaller is not running.
            guard self.running else {
                Debug(log: "Caller is not running. Please perform `func resume()` to run your api.")
                return
            }
            
            //Ignore if APICaller has been cannceled.
            guard !self.isCancelled else {
                Debug(log: "Caller has been cannceled. Please perform `func resume()` to run your api.")
                return
            }

            self.sessionTask?.cancel()
            Acclaim.remove(runningCaller: self)
            self.runningItem.cancel()
            
        }
        
    }
    
    //MARK: -
    deinit{
        Debug(log: "APICaller : [\(unsafeAddress(of: self))] deinit")
    }
}


//MARK: - Response Handler

extension APICaller {
    
    internal func handle(cachedResponse: CachedURLResponse, byRequest request: URLRequest){
        let connection = Connection(originalRequest: request, currentRequest: request, response: cachedResponse.response, requestMIMEs: self.allowedMIMEs, cached: true)
        self.handleResponses(fromCached: true)(data: cachedResponse.data, connection: connection, error: nil)
    }

    internal func handleResponses(data:Data?, connection: Connection, error:NSError?){
        self.handleResponses()(data: data, connection: connection, error: error)
    }
    
    internal func handleResponses(fromCached cached: Bool = false)->(data:Data?, connection: Connection, error:NSError?)->Void{
        
        return {[unowned self] (data:Data?, connection: Connection, error:NSError?)->Void in
            
            guard !self.isCancelled else {
                //檢查cancel的訊息，並在這裡回傳resumedData
                self.cancelledAssistant?.handle(data: data, connection: connection, error: nil)
                return
            }
            
            guard error == nil else {
                //remove cached response data by renewRule : RenewByRetry
                
                //before this request
                if let cachedResponse = Acclaim.cachedResponse(for: connection.currentRequest) {
                    self.handle(cachedResponse: cachedResponse, byRequest: connection.currentRequest)
                }
                
                
                if error?.code == -999 && error?.localizedDescription == "cancelled" {
                    self.cancelledAssistant?.handle(data: data, connection: connection, error: error)
                }else{
                    self.handleFailedResponse(data: data, connection: connection, error: error)
                }
                
                return
            }
            
            if let response = connection.response, let data = data where cached == false{
                let cacheStoragePolicy = URLCache.StoragePolicy(self.configuration.cacheStoragePolicy)
                let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: cacheStoragePolicy)
                Acclaim.store(cachedResponse: cachedResponse, forRequest: connection.currentRequest)
            }
            
            self.responseAssistants.forEach { receiver in
                receiver.handle(data: data, connection: connection, error: error)
            }
        }
        
    }
    
    internal func handleFailedResponse(data:Data?, connection: Connection, error:NSError?) {
        
        self.failedResponseAssistants.forEach { $0.handle(data: data, connection: connection, error: error) }
    }
    
    
    public func handle<T : ResponseAssistant>(responseType: ResponseAssistantType, assistant: T) -> T {
        switch responseType {
        case .success:
            self.responseAssistants.append(assistant)
        case .failed:
            self.failedResponseAssistants.append(assistant)
        }
        
        return assistant
    }
    
}

//handle sending/receving processing
extension APICaller {
    
    public func cancelled(_ handler: ResumeDataResponseAssistant.Handler) -> Self {
        self.cancelledAssistant = ResumeDataResponseAssistant(handler: handler)
        return self
    }
    
}


/// A enum describes how `ResponseCached` should cache into a storage.
public enum CacheStoragePolicy{
    
    /// A enum describes the renew rule by the response failed.
    public enum RenewRule {
        
        case notRenewed
        /// Not implemented.
        case renewSinceDate(data: Date)
        /// Not implemented.
        case renewByRetry(limitCount: Int)
        
        internal static let DefaultRetryCount = 4
    }
    
    /// Response will be cached into a storage.
    case allowed(renewRule: RenewRule)
    /// Response will be cached into a memory only.
    case allowedInMemoryOnly(renewRule: RenewRule)
    /// Response should not be cached.
    case notAllowed
    
    internal var renewRule: RenewRule {
        switch self {
        case .allowed(let renewRule):
            return renewRule
        case .allowedInMemoryOnly(let renewRule):
            return renewRule
        case .notAllowed:
            return .notRenewed
        }
    }
}

//MARK: - RenewRule internal methods
extension CacheStoragePolicy.RenewRule {
    
    internal var _method:String{
        switch self {
        case .notRenewed:
            return "NotRenewed"
        case .renewSinceDate:
            return "RenewSinceDate"
        case .renewByRetry:
            return "RenewByRetry"
        }
    }
}



extension URLCache.StoragePolicy {
    public init(_ rawValue: CacheStoragePolicy) {
        switch rawValue{
        case .allowed:
            self = .allowed
        case .allowedInMemoryOnly:
            self = .allowedInMemoryOnly
        case .notAllowed:
            self = .notAllowed
        }
    }
}

extension CacheStoragePolicy {
    
    public init(_ rawValue: URLCache.StoragePolicy){
        switch rawValue {
        case .allowed:
            self = .allowed(renewRule: .notRenewed)
        case .allowedInMemoryOnly:
            self = .allowedInMemoryOnly(renewRule: .notRenewed)
        case .notAllowed:
            self = .notAllowed
        }
    }
}
