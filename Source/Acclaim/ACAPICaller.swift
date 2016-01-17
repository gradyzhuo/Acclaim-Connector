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
    
    internal var connector: Connector
    
    public convenience init(API api:API, params:[String: AnyObject], connector: Connector = Acclaim.defaultConnector) {
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
    

    internal func addResponse<T:Deserializer>(deserializer: T.Type)->(handler:T.Handler)->ACAPICaller{

        return { (handler:T.Handler)->ACAPICaller in
            let response = Response<T>(handler: handler)
            return self.addResponse(response)
        }
    }
    
    internal class func removeRunningCaller(API api:API){
        
        ACDebugLog("removeRunningCallerByAPI:\(api.apiURL)")
        
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
    
    internal func run(var connector connector: Connector){
        
        if !self.running {
            return
        }
        
        defer {
            self.request = request
        }
        
        let request = ACAPICaller.URLRequest(self.api, params: self.params)
        
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
    
    internal func handleResponses(data data:NSData, URLResponse: NSURLResponse?, error:ErrorType?){
        
        defer {
            //Remove caller after response completion.
            ACAPICaller.removeRunningCaller(API: self.api)
        }
        
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
            self.run(connector: self.connector)
        }
        
        self.blockInQueue = block
        dispatch_barrier_async(priority.queue, block)
        
        ACAPICaller.running[self.api] = self
        
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
        ACAPICaller.removeRunningCaller(API: self.api)
        ACDebugLog("Caller is cancelled.")
    }
    
    
    deinit{
        ACDebugLog("ACAPICaller : [\(unsafeAddressOf(self))] deinit")
        ACDebugLog("count of running caller:\(ACAPICaller.running.count)")
    }
}

extension ACAPICaller {
    
    internal static func URLRequest(api: API, params: ACRequestParams)->NSURLRequest{
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: api.apiURL, cachePolicy: api.cachePolicy, timeoutInterval: api.timeoutInterval)
        
        let body = api.method.serializer.serialize(params)
        
        if let body = body where api.method == ACMethod.GET {
            let components = NSURLComponents(URL: api.apiURL, resolvingAgainstBaseURL: false)
            components?.query = String(data: body, encoding: NSUTF8StringEncoding)
            request.URL = (components?.URL)!
        }else{
            request.HTTPBody = body
        }
        
        request.HTTPMethod = api.method.rawValue
        request.allowsCellularAccess = Acclaim.allowsCellularAccess
        
        api.HTTPHeaderFields.forEach { (field:(key:String, value: String)) -> () in
            request.addValue(field.value, forHTTPHeaderField: field.key)
        }
        
        return request.copy() as! NSURLRequest
    }

    
}


// convenience response handler function
extension ACAPICaller {
    
    public func addOriginalDataResponse(handler:OriginalData.Handler)->ACAPICaller{
        self.addResponse(OriginalData.self)(handler: handler)
        return self
    }
    
    public func addImageResponseHandler(handler:Image.Handler)->ACAPICaller{
        self.addResponse(Image.self)(handler: handler)
        return self
    }
    
    public func addJSONResponseHandler(handler:JSON.Handler)->ACAPICaller{
        self.addResponse(JSON.self)(handler: handler)
        return self
    }
    
    public func addTextResponseHandler(handler:Text.Handler)->ACAPICaller{
        self.addResponse(Text.self)(handler: handler)
        return self
    }
    
    public func addFailedResponseHandler(handler:Failed.Handler)->ACAPICaller{
        self.addResponse(Failed.self)(handler: handler)
        return self
    }

}