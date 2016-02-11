//
//  Acclaim.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

//public typealias HTTPMethod = Method
//public typealias Parameter = Parameter

public let ACAPIHostURLInfoKey:String = Acclaim.hostURLInfoKey

public class Acclaim {
    
    public typealias Connection = (request: NSURLRequest, response: NSURLResponse?, cached: Bool)
    public typealias HTTPConnection = (request: NSURLRequest, response: NSHTTPURLResponse?)

    public static let version = AcclaimVersionNumber
    
    public static var allowsCellularAccess: Bool = true
    
    public static var defaultConnector: Connector = URLSession()
    
    internal static let deafultHostURLInfoKey:String = "ACAPIHostURLInfoKey"
    public static var hostURLInfoKey:String = Acclaim.deafultHostURLInfoKey
    
    public static func resetToDeafultHostURLInfoKey(){
        self.hostURLInfoKey = self.deafultHostURLInfoKey
    }
    
    internal static var running:[API:APICaller] = [:]
    
    internal class func addRunningCaller(caller: APICaller){
        self.running[caller.api] = caller
    }
    
    internal class func removeRunningCaller(API api:API){
        weak var caller = self.running[api]
        self.removeRunningCaller(APICaller: caller)
    }

    
    internal class func removeRunningCaller(APICaller caller: APICaller?){

        if let api = caller?.api where self.running.keys.contains(api){
            self.running.removeValueForKey(api)
        }
        
        
        caller?.blockInQueue = nil
        caller?.running = false
        
        ACDebugLog("removeRunningCallerByAPI:\(caller?.api.apiURL)")
        
        defer{
            ACDebugLog("caller:\(caller)")
            ACDebugLog("count of running caller:\(Acclaim.running.count)")
        }
        
    }

    
    internal static var sharedURLCache: NSURLCache{
        return NSURLCache.sharedURLCache()
    }
    
    internal class func cachedResponse(API api: API, parameters: RequestParameters) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponseForRequest(api.generateRequest(parameters))
    }
    
    internal class func cachedResponse(request request: NSURLRequest) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponseForRequest(request)
    }

    internal class func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest){
        Acclaim.sharedURLCache.storeCachedResponse(cachedResponse, forRequest: request)
    }
    
    internal static func removeAllCachedResponsesSinceDate(date: NSDate){
        Acclaim.sharedURLCache.removeCachedResponsesSinceDate(date)
    }
    
    internal static func removeAllCachedResponses(){
        Acclaim.sharedURLCache.removeAllCachedResponses()
    }
    
    
    internal class func removeCachedResponse(request: NSURLRequest){
        return Acclaim.sharedURLCache.removeCachedResponseForRequest(request)
    }
    
    internal class func removeCachedResponse(API api: API, parameters: RequestParameters){
        
        return Acclaim.removeCachedResponse(api.generateRequest(parameters))
    }
    
    ///
    public class func runAPI(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->APICaller{

        let caller = APICaller(API: api, params: params)
        caller.priority = priority
        caller.run()
        
        return caller
    }
    
}

extension Acclaim {
    
    public class func hostURLFromInfoDictionary()->NSURL? {
        
        guard let urlStr = NSBundle.mainBundle().infoDictionary?[ACAPIHostURLInfoKey] as? String else{
            return nil
        }
        
        guard let url = NSURL(string: urlStr) else {
            return nil
        }
        
        return url
    }
    
}

internal func ACDebugLog(log:AnyObject){
    #if DEBUG
    print("[DEBUG]: \(log)")
    #endif
}
