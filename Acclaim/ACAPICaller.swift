//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//


protocol ACCaller{
    
}

public class ACAPICaller {
    
    internal static var running:[ACAPI:ACAPICaller] = [:]
    
    public var priority:ACAPIQueuePriority = .Default
    public var cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed
    internal var blockInQueue:dispatch_block_t!
    
    public internal(set) var API:ACAPI!
    
    internal var params:ACRequestParams = ACRequestParams()
    internal var responseHandlers:[ACResponseIdentifier : ACResponse] = [:]
    
    public internal(set) var running:Bool = false
    public  var cancelled:Bool {
        if let queue = self.blockInQueue {
            let testResult = dispatch_block_testcancel(queue)
            return Bool(testResult)
        }
        return false
    }
    
    public internal(set) var request:NSURLRequest?
    
    public init(API:ACAPI, params:ACRequestParams) {
        self.API = API
        self.params = params
    }
    
    public func handleProgress()->ACAPICaller{
        return self
    }
    
    public func addResponse(response:ACResponse)->ACAPICaller{
        self.responseHandlers[response.identifier] = response
        return self
    }
    
    internal class func removeRunningCaller(API:ACAPI){
        let caller = self.running.removeValueForKey(API)
        caller?.blockInQueue = nil
        caller?.running = false
    }
    
    public class func makeCall(#API:ACAPI, params:ACRequestParams, priority: ACAPIQueuePriority = .Default)->ACAPICaller{
        let caller = ACAPICaller(API: API, params: params)
        caller.run()
        
        return caller
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
        
        if let cachedResponse = Acclaim.cachedResponseForRequest(self.API.request) {
            self.handleResponse(cachedResponse.data, response: cachedResponse.response, error: nil)
        }
        
        let error:NSError? = nil//NSError()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 3)), dispatch_get_global_queue(0, 0), {[weak self] () -> Void in
            
            
            if let weakSelf = self {
                let response = NSURLResponse(URL: weakSelf.API.apiURL, MIMEType: "text/json", expectedContentLength: 0, textEncodingName: "UTF-8")
                let data:NSData! = "{\"key\":\"我\"}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                if error == nil {
                    let cachedResponse = NSCachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: weakSelf.cacheStoragePolicy)
                    Acclaim.storeCachedResponse(cachedResponse, forRequest: weakSelf.API.request)
                }
                
                weakSelf.handleResponse(data, response: response, error: error)
                
                ACAPICaller.removeRunningCaller(weakSelf.API)
            }
            
            
            
        })
        
    }
    
    internal func handleResponse(data:NSData, response:NSURLResponse, error:NSError?){
        
        var handlers = self.responseHandlers
        let failedResponseHandler = handlers.removeValueForKey("Failed")
        
        if error != nil {
            failedResponseHandler?.handle(data, response: response, error: error)
        }else{
            for (_, value) in handlers {
                value.handle(data, response: response, error: error)
            }
        }
        
    }
    
    internal func retry(API:ACAPI){
        
    }
    
    public func resume(){
        
        self.running = true
        
        let block = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_DETACHED, priority.qos_class, priority.relative_priority) {[unowned self] () -> Void in
            self.runToConnector()
        }
        
        self.blockInQueue = block
        dispatch_barrier_async(priority.queue, block)
        
        ACAPICaller.running[self.API] = self
        
    }
    
    public func cancel(){
        
        if !running {
            ACDebugLog("Caller is not running. Please perform call() to run your api.")
            return
        }
        
        if !self.cancelled {
            self.running = false
            
            dispatch_block_cancel(self.blockInQueue)
            ACAPICaller.removeRunningCaller(self.API)
            ACDebugLog("Caller is cancelled.")
            
        }
    }
    
    
    deinit{
        ACDebugLog("count of running caller:\(ACAPICaller.running.count)")
        ACDebugLog("ACAPICaller : [\(unsafeAddressOf(self))] deinit")
    }
}
