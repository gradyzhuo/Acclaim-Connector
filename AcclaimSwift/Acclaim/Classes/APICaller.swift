//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Caller{
    init(API api: API, params: RequestParameters, connector: Connector)
}

public class APICaller : Caller {
    
    internal var identifier: String = String(NSDate().timeIntervalSince1970)
    
    /// A enum describes should Response Cached to a storage forever.
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
    
    /**
     The queue priority level configure of sending a request. (readonly)
     
     There are 3 levels as below:
     - High
     - Medium
     - Low
     
     Otherwise:
     - Default = Medium
     */
    public internal(set) var priority:QueuePriority = .Default
    public internal(set) var cacheStoragePolicy:CacheStoragePolicy = .AllowedInMemoryOnly(renewRule: .NotRenewed)
    
    
    /** (readonly) */
    public  var cancelled:Bool {
        if let queue = self.blockInQueue {
            let testResult = dispatch_block_testcancel(queue)
            return Bool(testResult)
        }
        return false
    }
    
    /** (read only) */
    public internal(set) var api:API!
    /** (read only) */
    public internal(set) var running:Bool = false
    /** (read only) */
    
    //MARK: internal variables
    internal var blockInQueue:dispatch_block_t!
    internal var params:RequestParameters = []
    
    internal var sessionTask:NSURLSessionTask?
    
    internal var responseAssistants:[Assistant] = []
    internal var failedResponseAssistants:[Assistant] = []
    internal var cancelledAssistant: Assistant?
    
    internal var sendingProcessHandler: ProcessHandler?
    internal var receivingProcessHandler: ProcessHandler?
    
    internal var cancelledResumeData:NSData?
    
    internal var connector: Connector!
    
    public convenience init(API api:API, params:[String: ParameterValueType], connector: Connector = Acclaim.configuration.connector) {
        self.init(API: api, params: RequestParameters(dictionary: params), connector: connector)
    }
    
    public convenience init(API api:API, params:[Parameter], connector: Connector = Acclaim.configuration.connector ) {
        self.init(API: api, params: RequestParameters(params: params), connector: connector)
    }
    
    public required init(API api:API, params:RequestParameters = [], connector: Connector = Acclaim.configuration.connector) {
        self.api = api
        self.params = params
        self.connector = connector
    }
    
    public func run()->APICaller{
        self.resume()
        return self
    }
    
    public func run(cacheStoragePolicy:APICaller.CacheStoragePolicy, priority: QueuePriority = .Default)->APICaller{
        
        self.cacheStoragePolicy = cacheStoragePolicy
        self.priority = priority
        
        return self.run()
    }
    
    internal func run(connector connector: Connector){
        
        guard !self.running else {
            return
        }
        
        // set
        self.sessionTask = connector.request(API: self.api, params: self.params) { (data, connection, error) in
            
            let request:NSURLRequest! = self.sessionTask?.currentRequest
            
            self.handleResponses(data: data, connection: connection, error: error)
            
            //remove
            Acclaim.removeRunningCaller(APICaller: self)
            
        }
        
        self.sessionTask?.apiCaller = self
        
        defer{
            self.running = true
        }
        
    }
    
    internal func retry(API api:API){

    }
    
    public func resume(){
        
        let block = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_DETACHED, priority.qos_class, priority.relative_priority) {[unowned self] () -> Void in
            self.run(connector: self.connector)
        }
        
        self.blockInQueue = block
        dispatch_barrier_async(priority.queue, block)
        
        //add
        Acclaim.addRunningCaller(self)
        
    }
    
    public func cancel(){
        
        guard self.running else {
            return
        }
        
        //透過非同步，插入cancel指令到running之後
        dispatch_async(dispatch_get_main_queue()) {
            
            guard self.running else {
                ACDebugLog("Caller is not running. Please perform `func call()` to run your api.")
                return
            }
            
            guard !self.cancelled else {
                return
            }
            
            if let downloadTask = self.sessionTask as? NSURLSessionDownloadTask {
                downloadTask.cancelByProducingResumeData{[unowned self] data in
                    self.cancelledResumeData = data
                }
            }else{
                self.sessionTask?.cancel()
            }
            
            
            dispatch_block_cancel(self.blockInQueue)
            
            ACDebugLog("Caller is cancelled.")
        }
        
    }
    
    deinit{
        ACDebugLog("APICaller : [\(unsafeAddressOf(self))] deinit")
    }
}

extension APICaller {
    
    internal func handleCachedResponse(cachedResponse: NSCachedURLResponse, byRequest request: NSURLRequest){
        let connection = Connection(originalRequest: request, currentRequest: request, response: cachedResponse.response, cached: true)
        self.handleResponses(fromCached: true)(data: cachedResponse.data, connection: connection, error: nil)
    }

    internal func handleResponses(data data:NSData?, connection: Connection, error:ErrorType?){
        self.handleResponses()(data: data, connection: connection, error: error)
    }
    
    internal func handleResponses(fromCached cached: Bool = false)->(data:NSData?, connection: Connection, error:ErrorType?)->Void{
        
        return {[unowned self] (data:NSData?, connection: Connection, error:ErrorType?)->Void in
            
            guard !self.cancelled else {
                //檢查cancel的訊息，並在這裡回傳resumedData
                self.cancelledAssistant?.handle(self.cancelledResumeData, connection: connection, error: nil)
                return
            }
            
            guard error == nil else {
                //remove cached response data by renewRule : RenewByRetry
                
                //before this request
                if let cachedResponse = Acclaim.cachedResponse(request: connection.currentRequest) {
                    self.handleCachedResponse(cachedResponse, byRequest: connection.currentRequest)
                }
                
                self.handleFailedResponse(data: data, connection: connection, error: error)
                return
            }
            
            if let response = connection.response, let data = data where cached == false{
                let cacheStoragePolicy = NSURLCacheStoragePolicy(self.cacheStoragePolicy)
                let cachedResponse = NSCachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: cacheStoragePolicy)
                Acclaim.storeCachedResponse(cachedResponse, forRequest: connection.currentRequest)
            }
            
            self.responseAssistants.forEach { reciver in
                
                if let error = reciver.handle(data, connection: connection, error: error) as? NSError {
                    self.handleFailedResponse(data: data, connection: connection, error: error)
                }
            }
        }
        
    }
    
    internal func handleFailedResponse(data data:NSData?, connection: Connection, error:ErrorType?) {
        self.failedResponseAssistants.forEach { $0.handle(data, connection: connection, error: error) }
    }
    
    
    public func addResponseAssistant<T:ResponseAssistant>(forType type:ResponseAssistantType = .Normal, responseAssistant assistant: T)->Self{
        switch type {
        case .Normal:
            self.responseAssistants.append(assistant)
        case .Failed:
            self.failedResponseAssistants.append(assistant)
        }
        
        return self
    }
    
}

// convenience response handler function
extension APICaller {

    public func addFailedResponseHandler(statusCode statusCode:Int? = nil, handler:FailedResponseAssistant.Handler)->Self{
        var assistant = FailedResponseAssistant()
        if let statusCode = statusCode {
            assistant.addHandler(forStatusCode: statusCode, handler: handler)
        }else{
            assistant.handler = handler
        }
        self.failedResponseAssistants.append(assistant)
        
        return self
    }
    
    
    
    public func addOriginalDataResponseHandler(handler:OriginalDataResponseAssistant.Handler)->Self{
        self.addResponseAssistant(responseAssistant: OriginalDataResponseAssistant(handler: handler))
        return self
    }

}

//handle sending/receving processing
extension APICaller {
    
    public func setCancelledResponseHandler(handler:ResumeDataResponseAssistant.Handler)->Self{
        self.cancelledAssistant = ResumeDataResponseAssistant(handler: handler)
        return self
    }
    
    public func setSendingProcessHandler(handler: ProcessHandler)->Self {
        self.sendingProcessHandler = handler
        return self
    }
    
    public func setRecevingProcessHandler(handler: ProcessHandler)->Self {
        self.receivingProcessHandler = handler
        return self
    }
}

//MARK: - RenewRule internal methods
extension APICaller.CacheStoragePolicy.RenewRule {
    
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
    public init(_ rawValue: APICaller.CacheStoragePolicy) {
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

extension APICaller.CacheStoragePolicy {
    
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