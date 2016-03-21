//
//  Acclaim.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

//FIXME: 需要加入 ParameterTable，就以指定什麼Key是必填，什麼Key是選填
//FIXME: 可能還可以加入 ResponseTable 去驗證回傳的JSON是否正確

public let ACAPIHostURLInfoKey:String = "ACAPIHostURLInfoKey"

public struct AcclaimConfiguration{
    var connector: Connector
    var hostURLInfoKey: String
    var bundleForHostURLInfo: NSBundle
    
    public init(connector: Connector, hostURLInfoKey key: String, bundleForHostURLInfo bundle: NSBundle){
        self.connector = connector
        self.hostURLInfoKey = key
        self.bundleForHostURLInfo = bundle
    }
    
    public static var defaultConfiguration: AcclaimConfiguration = {
        return AcclaimConfiguration(connector: URLSession(), hostURLInfoKey: ACAPIHostURLInfoKey, bundleForHostURLInfo: NSBundle.mainBundle())
    }()
    
}

public class Acclaim {
    
//    public typealias Connection = (request: NSURLRequest, response: NSURLResponse?, cached: Bool)

    public static let version = AcclaimVersionNumber
    
    public static var allowsCellularAccess: Bool = true
    
    public static var configuration: AcclaimConfiguration = AcclaimConfiguration.defaultConfiguration
    
    internal static var running:[String:APICaller] = [:]
    
    internal static func addRunningCaller(caller: APICaller){
        self.running[caller.identifier] = caller
    }
    
    internal static func removeRunningCaller(APICaller caller: APICaller?){

        
        if let caller = caller  where self.running.keys.contains(caller.identifier){
            self.running.removeValueForKey(caller.identifier)
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
    
    internal static func cachedResponse(API api: API, parameters: RequestParameters) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponseForRequest(api.generateRequest(parameters))
    }
    
    internal static func cachedResponse(request request: NSURLRequest) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponseForRequest(request)
    }

    internal static func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest){
        Acclaim.sharedURLCache.storeCachedResponse(cachedResponse, forRequest: request)
    }
    
    internal static func removeAllCachedResponsesSinceDate(date: NSDate){
        Acclaim.sharedURLCache.removeCachedResponsesSinceDate(date)
    }
    
    internal static func removeAllCachedResponses(){
        Acclaim.sharedURLCache.removeAllCachedResponses()
    }
    
    
    internal static func removeCachedResponse(request: NSURLRequest){
        return Acclaim.sharedURLCache.removeCachedResponseForRequest(request)
    }
    
    internal static func removeCachedResponse(API api: API, parameters: RequestParameters){
        
        return Acclaim.removeCachedResponse(api.generateRequest(parameters))
    }
    
}

extension Acclaim {
    
    public static func hostURLFromInfoDictionary()->NSURL? {
        
        guard let urlStr = self.configuration.bundleForHostURLInfo.infoDictionary?[ACAPIHostURLInfoKey] as? String else{
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
