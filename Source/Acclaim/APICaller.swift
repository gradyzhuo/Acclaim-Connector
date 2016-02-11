//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

internal protocol Caller{
    
}

public class APICaller : Caller {
    
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
    
    
    internal var responseAssistants:[_ResponseAssistantProtocol] = []
    internal var failedResponseAssistants:[_ResponseAssistantProtocol] = []
    
    internal var connector: Connector
    
    public convenience init(API api:API, params:[String: ParameterValueType], connector: Connector = Acclaim.defaultConnector) {
        self.init(API: api, params: RequestParameters(dictionary: params), connector: connector)
    }
    
    public convenience init(API api:API, params:[RequestParameter], connector: Connector = Acclaim.defaultConnector) {
        self.init(API: api, params: RequestParameters(params: params), connector: connector)
    }
    
    internal init(API api:API, params:RequestParameters, connector: Connector = Acclaim.defaultConnector) {
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
    
    internal func run(var connector connector: Connector){
        
        let request = self.api.generateRequest(self.params)
        
        guard !self.running else {
            return
        }
        
        // set
        let dataTask = connector.sendRequest(request, taskType: self.api.requestTaskType) {[weak self] (data, response, error) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.handleResponses(data: data, connection: (request, response, false), error: error)
            
            defer {
                //Remove caller after response completion.
                Acclaim.removeRunningCaller(API: weakSelf.api)
            }
        }

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
        
        Acclaim.addRunningCaller(self)
        
    }
    
    public func cancel(){
        
        guard self.running else {
            ACDebugLog("Caller is not running. Please perform call() to run your api.")
            return
        }
        
        guard !self.cancelled else {
            return
        }
        
        self.running = false
        
        dispatch_block_cancel(self.blockInQueue)
        Acclaim.removeRunningCaller(API: self.api)
        ACDebugLog("Caller is cancelled.")
    }
    
    deinit{
        ACDebugLog("APICaller : [\(unsafeAddressOf(self))] deinit")
    }
}

extension APICaller {
    
    internal func handleCachedResponse(cachedResponse: NSCachedURLResponse, byRequest request: NSURLRequest){
        self.handleResponses(fromCached: true)(data: cachedResponse.data, connection: (request: request, response: cachedResponse.response, cached: true), error: nil)
    }

    internal func handleResponses(data data:NSData?, connection: Acclaim.Connection, error:ErrorType?){
        self.handleResponses()(data: data, connection: connection, error: error)
    }
    
    internal func handleResponses(fromCached cached: Bool = false)->(data:NSData?, connection: Acclaim.Connection, error:ErrorType?)->Void{
        
        return {[unowned self] (data:NSData?, connection: Acclaim.Connection, error:ErrorType?)->Void in
            
            guard error == nil else {
                //remove cached response data by renewRule : RenewByRetry
                
                //before this request
                if let cachedResponse = Acclaim.cachedResponse(request: connection.request) {
                    self.handleCachedResponse(cachedResponse, byRequest: connection.request)
                }
                
                self.handleFailedResponse(data: data, connection: connection, error: error)
                return
            }
            
            if let response = connection.response, let data = data where cached == false{
                let cacheStoragePolicy = NSURLCacheStoragePolicy(self.cacheStoragePolicy)
                let cachedResponse = NSCachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: cacheStoragePolicy)
                Acclaim.storeCachedResponse(cachedResponse, forRequest: connection.request)
            }
            
            self.responseAssistants.forEach { reciver in
                
                if let error = reciver.handle(data, connection: connection, error: error) as? NSError {
                    self.handleFailedResponse(data: data, connection: connection, error: error)
                }
            }
        }
        
    }
    
    internal func handleFailedResponse(data data:NSData?, connection: Acclaim.Connection, error:ErrorType?) {
        self.failedResponseAssistants.forEach { $0.handle(data, connection: connection, error: error) }
    }
    
    
    public func addResponseAssistant<T:ResponseAssistantProtocol>(responseAssistant assistant: T)->APICaller{
        self.responseAssistants.append(assistant)
        return self
    }
    
}

// convenience response handler function
extension APICaller {
    
    public func addFailedResponseHandler(statusCode statusCode:Int? = nil, handler:HTTPResponseAssistant.Handler)->APICaller{
        self.failedResponseAssistants.append(HTTPResponseAssistant(statusCode: statusCode, handler: handler))
        return self
    }
    
    public func addOriginalDataResponseHandler(handler:OriginalDataResponseAssistant.Handler)->APICaller{
        self.addResponseAssistant(responseAssistant: OriginalDataResponseAssistant(handler: handler))
        return self
    }
    
    public func addImageResponseHandler(resumeData:NSData? = nil, handler:ImageResponseAssistant.Handler)->APICaller{
        self.api.requestTaskType = .DownloadTask(resumeData: nil)
        self.addResponseAssistant(responseAssistant: ImageResponseAssistant(handler: handler))
        return self
    }
    
    public func addJSONResponseHandler(keyPath keyPath:String, option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->APICaller{
        self.addResponseAssistant(responseAssistant: JSONResponseAssistant(forKeyPath: keyPath, option: option, handler: handler))
        return self
    }
    
    public func addJSONResponseHandler(option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->APICaller{
        self.addResponseAssistant(responseAssistant: JSONResponseAssistant(option: option, handler: handler))
        return self
    }
    
    public func addTextResponseHandler(encoding: NSStringEncoding = NSUTF8StringEncoding, handler:TextResponseAssistant.Handler)->APICaller{
        self.addResponseAssistant(responseAssistant: TextResponseAssistant(encoding: encoding, handler: handler))
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
