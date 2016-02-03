//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

internal protocol Caller{
    
}

public typealias Connection = (request: NSURLRequest, response: NSHTTPURLResponse?)

public class APICaller : Caller {
    
    public internal(set) var priority:APIQueuePriority = .Default
    public internal(set) var cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed
    
    /** (read only) */
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
    internal var params:Parameters = Parameters()
    
    internal var responseAssistants:[_ResponseAssistantProtocol] = []
    internal var failedResponseAssistant:_ResponseAssistantProtocol?
    
    internal var connector: Connector
    
    public convenience init(API api:API, params:[String: String], connector: Connector = Acclaim.defaultConnector) {
        self.init(API: api, params: Parameters(dictionary: params), connector: connector)
    }
    
    public convenience init(API api:API, params:[Parameter], connector: Connector = Acclaim.defaultConnector) {
        self.init(API: api, params: Parameters(params: params), connector: connector)
    }
    
    internal init(API api:API, params:Parameters, connector: Connector = Acclaim.defaultConnector) {
        self.api = api
        self.params = params
        self.connector = connector
    }
    
    public func handleProgress()->APICaller{
        return self
    }
    
    public func run(cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed, priority: APIQueuePriority = .Default)->APICaller{
        
        self.cacheStoragePolicy = cacheStoragePolicy
        self.priority = priority
        
        self.resume()
        
        return self
    }
    
    internal func run(var connector connector: Connector){
        
        if !self.running {
            return
        }
        
        let request = self.api.getRequest(self.params)
        
        connector.sendRequest(request) {[weak self] (data, response, error) -> Void in

            guard let weakSelf = self else {
                return
            }
            
            weakSelf.handleResponses(data: data, connection: Connection(request, response as? NSHTTPURLResponse), error: error)
            
        }
        
    }
    
    internal func retry(API api:API){
        
    }
    
    public func resume(){
        
        self.running = true
        
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
    

    internal func handleResponses(data data:NSData?, connection: Connection, error:ErrorType?)->Void{
        
        defer {
            //Remove caller after response completion.
            Acclaim.removeRunningCaller(API: self.api)
        }
        
        guard error == nil else {
            self.failedResponseAssistant?.handle(data, connection: connection, error: error)
            return
        }
        
        if let response = connection.response, let data = data{
            let cachedResponse = NSCachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: self.cacheStoragePolicy)
            Acclaim.storeCachedResponse(cachedResponse, forRequest: connection.request)
        }
        
        self.responseAssistants.forEach { reciver in
            
            if let error = reciver.handle(data, connection: connection, error: error) as? NSError {
                self.failedResponseAssistant?.handle(data, connection: connection, error: error)
            }
        }
        
        
        
    }
    
    public func addResponseAssistant<T:ResponseAssistantProtocol>(responseAssistant assistant: T)->APICaller{
        self.responseAssistants.append(assistant)
        return self
    }
    
}

// convenience response handler function
extension APICaller {
    
    public func setFailedResponseHandler(handler:FailedResponseAssistant.Handler)->APICaller{
        self.failedResponseAssistant = FailedResponseAssistant(handler: handler)
        return self
    }
    
    public func addOriginalDataResponseHandler(handler:OriginalDataResponseAssistant.Handler)->APICaller{
        self.addResponseAssistant(responseAssistant: OriginalDataResponseAssistant(handler: handler))
        return self
    }
    
    public func addImageResponseHandler(handler:ImageResponseAssistant.Handler)->APICaller{
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

