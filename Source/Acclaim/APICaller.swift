//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//


internal protocol Caller{
    
}

//struct TestResponse {
//    var identifier: String
//    var response : _Response
//}

//extension Response {
//    func getTestResponse()->TestResponse {
//        return TestResponse(identifier: DeserializerType.identifier, response: self)
//    }
//}

//public typealias Response = (request: NSURLRequest, response: NSURLResponse)

public class APICaller : Caller {
    
    public var priority:ACAPIQueuePriority = .Default
    public var cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed
    
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
    public internal(set) var request:NSURLRequest?
    
    public internal(set) var response : NSURLResponse?
    
    //MARK: internal variables
    internal var blockInQueue:dispatch_block_t!
    internal var params:ACRequestParams = ACRequestParams()
    internal var responseHandlers:(normal: [_Response], failed: [_Response]) = ([], [])
    
    internal var connector: Connector
    
    public convenience init(API api:API, params:[String: String], connector: Connector = Acclaim.defaultConnector) {
        self.init(API: api, params: ACRequestParams(dictionary: params), connector: connector)
    }
    
    public convenience init(API api:API, params:[ACRequestParam], connector: Connector = Acclaim.defaultConnector) {
        self.init(API: api, params: ACRequestParams(params: params), connector: connector)
    }
    
    internal init(API api:API, params:ACRequestParams, connector: Connector = Acclaim.defaultConnector) {
        self.api = api
        self.params = params
        self.connector = connector
    }
    
    public func handleProgress()->APICaller{
        return self
    }
    
    
    
    public func run(cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed, priority: ACAPIQueuePriority = .Default)->APICaller{
        
        self.cacheStoragePolicy = cacheStoragePolicy
        self.priority = priority
        
        self.resume()
        
        return self
    }
    
    internal func run(var connector connector: Connector){
        
        if !self.running {
            return
        }
        
        defer {
            self.request = request
        }
        
        let request = self.api.getRequest(self.params)
        
        connector.sendRequest(request) {[weak self] (data, response, error) -> Void in
            guard let weakSelf = self else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            if let response = response{
                let cachedResponse = NSCachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: weakSelf.cacheStoragePolicy)
                Acclaim.storeCachedResponse(cachedResponse, forRequest: request)
            }
            
            weakSelf.handleResponses(data: data, URLResponse: response, error: error)
            
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
    
    internal func handleResponses(data data:NSData, URLResponse: NSURLResponse?, error:ErrorType?){
        
        defer {
            //Remove caller after response completion.
            Acclaim.removeRunningCaller(API: self.api)
        }
        
        if error != nil {
            self.responseHandlers.failed.forEach{ $0.handle(data, URLResponse: URLResponse, error: error) }
        }else{
            self.responseHandlers.normal.forEach{ $0.handle(data, URLResponse: URLResponse, error: error) }
        }
        
    }
    
    public func addResponse<T:Deserializer>(response: Response<T>)->APICaller{
        
        if T.identifier == Failed.identifier {
            self.responseHandlers.failed.append(response)
        }else{
            self.responseHandlers.normal.append(response)
        }
        
        return self
    }
    
    
    internal func addResponse<T:Deserializer>(deserializer: T)->(handler:T.Handler)->APICaller{
        
        return { (handler:T.Handler)->APICaller in
            let response = Response<T>(deserializer: deserializer, handler: handler)
            return self.addResponse(response)
        }
    }

}

// convenience response handler function
extension APICaller {
    
    public func addOriginalDataResponse(handler:OriginalData.Handler)->APICaller{
        self.addResponse(OriginalData())(handler: handler)
        return self
    }
    
    public func addImageResponseHandler(handler:Image.Handler)->APICaller{
        self.addResponse(Image())(handler: handler)
        return self
    }
    
    public func addJSONResponseHandler(handler:JSON.Handler)->APICaller{
        self.addResponse(JSON())(handler: handler)
        return self
    }
    
    public func addTextResponseHandler(handler:Text.Handler)->APICaller{
        self.addResponse(Text())(handler: handler)
        return self
    }
    
    public func addFailedResponseHandler(handler:Failed.Handler)->APICaller{
        self.addResponse(Failed())(handler: handler)
        return self
    }

}

