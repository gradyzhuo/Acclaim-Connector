//
//  Acclaim.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias HTTPMethod = ACMethod
public typealias RequestParam = ACRequestParam
public typealias APICaller = ACAPICaller

public let ACAPIHostURLInfoKey:String = Acclaim.hostURLInfoKey

public class Acclaim {
    
    public static let version = AcclaimVersionNumber
    
    public static var allowsCellularAccess: Bool = true
    
    public static var defaultConnector: Connector = URLSession()
    
    internal static let deafultHostURLInfoKey:String = "ACAPIHostURLInfoKey"
    public static var hostURLInfoKey:String = Acclaim.deafultHostURLInfoKey
    
    internal static var sharedURLCache: NSURLCache{
        return NSURLCache.sharedURLCache()
    }
    
    public class func cachedResponseForRequest(request: NSURLRequest) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponseForRequest(request)
    }

    public class func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest){
        Acclaim.sharedURLCache.storeCachedResponse(cachedResponse, forRequest: request)
    }
    
    public class func runAPI(API api:API, params:ACRequestParams, priority: ACAPIQueuePriority = .Default)->ACAPICaller{
        let caller = ACAPICaller(API: api, params: params)
        caller.run()
        return caller
    }
    
}

extension Acclaim {
    
    internal class func hostURLFromInfoDictionary()->NSURL? {
        
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
