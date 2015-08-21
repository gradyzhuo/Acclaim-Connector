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

public let ACAPIHostURLInfoKey:String = "ACAPIHostURLInfoKey"

public class Acclaim {
    
    internal static var sharedURLCache: NSURLCache{
//        let cache = NSURLCache(memoryCapacity: 128, diskCapacity: 128, diskPath: "")
//        NSURLCache.setSharedURLCache(cache)
        return NSURLCache.sharedURLCache()
    }
    
    public class func cachedResponseForRequest(request: NSURLRequest) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponseForRequest(request)
    }

    public class func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest){
        Acclaim.sharedURLCache.storeCachedResponse(cachedResponse, forRequest: request)
    }
    
    internal class func hostURLFromInfoDictionary()->NSURL? {
        var urlStr = NSBundle.mainBundle().infoDictionary?[ACAPIHostURLInfoKey] as? String ?? ""
        return NSURL(string: urlStr)
    }
    
}

extension Acclaim {
    
    
//    typealias ACAPICallerCompletionHandler = (request:NSURLRequest, )
    
    
}

func ACDebugLog(log:AnyObject){
    #if DEBUG
    println("[DEBUG]: \(log)")
    #endif
}
