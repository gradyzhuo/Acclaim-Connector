//
//  Acclaim.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

/// Default key setting for API Host URL in the Info.plist.
public let ACAPIHostURLInfoKey:String = "ACAPIHostURLInfoKey"

public class Acclaim {
    
    /**
     The Configuration for setting prefered connector, hostURLInfoKey, bundleForHostURLInfo, and allowsCellularAccess.
     */
    public struct Configuration{
        /**
         The connector what performs network connection. (readonly) <br />
         - seealso:
         - [URLSession](URLSession)
         */
        public internal(set) var connector: Connector
        public internal(set) var hostURLInfoKey: String
        public internal(set) var bundleForHostURLInfo: NSBundle
        public internal(set) var allowsCellularAccess: Bool
        
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
        
        internal var cacheStoragePolicy:CacheStoragePolicy = .AllowedInMemoryOnly(renewRule: .NotRenewed)
        
        public init(connector: Connector, hostURLInfoKey key: String, bundleForHostURLInfo bundle: NSBundle, allowsCellularAccess cellularAccess: Bool = true){
            self.connector = connector
            self.hostURLInfoKey = key
            self.bundleForHostURLInfo = bundle
            self.allowsCellularAccess = cellularAccess
        }
        
        public static var defaultConfiguration: Acclaim.Configuration = {
            return Acclaim.Configuration(connector: URLSession(), hostURLInfoKey: ACAPIHostURLInfoKey, bundleForHostURLInfo: NSBundle.mainBundle())
        }()
        
    }
    
    /// Shows current Acclaim version number. (readonly)
    public static let version = AcclaimVersionNumber
    
    
    public static var sharedRequestParameters: RequestParameters?
    public static var configuration: Acclaim.Configuration = Acclaim.Configuration.defaultConfiguration
    
    internal static var running:[String:Caller] = [:]
    
    internal static func addRunningCaller(caller: Caller){
        self.running[caller.identifier] = caller
    }
    
    internal static func removeRunningCaller(caller: Caller?){

        if let caller = caller  where self.running.keys.contains(caller.identifier){
            self.running.removeValueForKey(caller.identifier)
        }
        
        ACDebugLog("removeRunningCallerByIdentifier:\(caller?.identifier)")
        
        defer{
            ACDebugLog("caller:\(caller)")
            ACDebugLog("count of running caller:\(Acclaim.running.count)")
        }
        
    }

    
    internal static var sharedURLCache: NSURLCache{
        return NSURLCache.sharedURLCache()
    }
    
    internal static func cachedResponse(API api: API, parameters: RequestParameters, configuration: Acclaim.Configuration) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponseForRequest(api.generateRequest(configuration: configuration, params: parameters))
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
    
    internal static func removeCachedResponse(API api: API, parameters: RequestParameters, configuration: Acclaim.Configuration){
        return Acclaim.removeCachedResponse(api.generateRequest(configuration: configuration, params: parameters))
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
