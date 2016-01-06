//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//


internal protocol Caller{
    
}

struct TestResponse {
    var identifier: String
    var response : _Response
}

extension Response {
    func getTestResponse()->TestResponse {
        return TestResponse(identifier: T.identifier, response: self)
    }
}

public class ACAPICaller : Caller {
    
    internal static var running:[API:ACAPICaller] = [:]
    
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
    
    internal var response : NSURLResponse?
    
    //MARK: internal variables
    internal var blockInQueue:dispatch_block_t!
    internal var params:ACRequestParams = ACRequestParams()
    internal var responseHandlers:(normal: [_Response], failed: [_Response]) = ([], [])
    
    
    public convenience init(API api:API, params:[ACRequestParam]) {
        self.init(API: api, params: ACRequestParams(params: params))
        
    }
    
    internal init(API api:API, params:ACRequestParams) {
        self.api = api
        self.params = params
        
    }
    
    public func handleProgress()->ACAPICaller{
        return self
    }
    
    public func addResponse<T:Deserializer>(response: Response<T>)->ACAPICaller{
        
        if T.identifier == Failed.identifier {
            self.responseHandlers.failed.append(response)
        }else{
            self.responseHandlers.normal.append(response)
        }
        
        return self
    }
    
    internal func addResponse<T:Deserializer>(deserializer: T.Type, handler:T.Handler)->ACAPICaller{
        
        let response = Response<T>(handler: handler)
        self.addResponse(response)
        return self
    }
    
    public func addOriginalDataResponse(handler:OriginalData.Handler)->ACAPICaller{
        self.addResponse(OriginalData.self, handler: handler)
        return self
    }
    
    public func addImageResponse(handler:Image.Handler)->ACAPICaller{
        self.addResponse(Image.self, handler: handler)
        return self
    }
    
    public func addJSONResponse(handler:JSON.Handler)->ACAPICaller{
        self.addResponse(JSON.self, handler: handler)
        return self
    }
    
    public func addTextResponse(handler:Text.Handler)->ACAPICaller{
        self.addResponse(Text.self, handler: handler)
        return self
    }
    
    public func addFailedResponse(handler:Failed.Handler)->ACAPICaller{
        self.addResponse(Failed.self, handler: handler)
        return self
    }
    
    internal class func removeRunningCaller(API api:API){
        let caller = self.running.removeValueForKey(api)
        caller?.blockInQueue = nil
        caller?.running = false
    }
    
    public func run(cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed, priority: ACAPIQueuePriority = .Default)->ACAPICaller{
        
        self.cacheStoragePolicy = cacheStoragePolicy
        self.priority = priority
        
        self.resume()
        
        return self
    }
    
    internal func runToConnector(){
        
        if !self.running {
            return
        }
        
        let error:ErrorType? = nil
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 3)), dispatch_get_global_queue(0, 0), {[weak self] () -> Void in
            
            if let weakSelf = self {
                let URLResponse = NSURLResponse(URL: weakSelf.api.apiURL, MIMEType: "text/json", expectedContentLength: 0, textEncodingName: "UTF-8")
                let data:NSData! = "{\"key\":\"我\"}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                if error == nil {
                    let cachedResponse = NSCachedURLResponse(response: URLResponse, data: data, userInfo: nil, storagePolicy: weakSelf.cacheStoragePolicy)
                    Acclaim.storeCachedResponse(cachedResponse, forRequest: weakSelf.api.request)
                }
                
                weakSelf.handleResponse(data, URLResponse: URLResponse, error: error)
                
                ACAPICaller.removeRunningCaller(API: weakSelf.api)
            }
            
        })
        
    }
    
    internal func handleResponse(data:NSData, URLResponse:NSURLResponse, error:ErrorType?){
        
        if error != nil {
            self.responseHandlers.failed.forEach{ $0.handle(data, URLResponse: URLResponse, error: error) }
        }else{
            self.responseHandlers.normal.forEach{ $0.handle(data, URLResponse: URLResponse, error: error) }
        }
        
    }
    
    internal func retry(API api:API){
        
    }
    
    public func resume(){
        
        self.running = true
        
        let block = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_DETACHED, priority.qos_class, priority.relative_priority) {[unowned self] () -> Void in
            self.runToConnector()
        }
        
        self.blockInQueue = block
        dispatch_barrier_async(priority.queue, block)
        
        ACAPICaller.running[self.api] = self
        
    }
    
    public func cancel(){
        
        if !running {
            ACDebugLog("Caller is not running. Please perform call() to run your api.")
            return
        }
        
        if !self.cancelled {
            self.running = false
            
            dispatch_block_cancel(self.blockInQueue)
            ACAPICaller.removeRunningCaller(API: self.api)
            ACDebugLog("Caller is cancelled.")
            
        }
    }
    
    
    deinit{
        ACDebugLog("ACAPICaller : [\(unsafeAddressOf(self))] deinit")
        ACDebugLog("count of running caller:\(ACAPICaller.running.count)")
    }
}
