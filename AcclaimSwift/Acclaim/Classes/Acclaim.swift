//
//  Acclaim.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public class Acclaim {
    
    /**
     The Configuration for setting prefered connector, hostURLInfoKey, bundleForHostURLInfo, and allowsCellularAccess.
     */
    public struct Configuration{
        
        /// Default key setting for API Host URL in the Info.plist.
        public static let defaultHostURLInfoKey:String = "ACAPIHostURLInfoKey"
        
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
        
        internal var cacheStoragePolicy:CacheStoragePolicy = .allowedInMemoryOnly(renewRule: .NotRenewed)
        
        public init(connector: Connector, hostURLInfoKey key: String, bundleForHostURLInfo bundle: NSBundle, allowsCellularAccess cellularAccess: Bool = true){
            self.connector = connector
            self.hostURLInfoKey = key
            self.bundleForHostURLInfo = bundle
            self.allowsCellularAccess = cellularAccess
        }
        
        public static var defaultConfiguration: Acclaim.Configuration = {
            let defaultKey = Acclaim.Configuration.defaultHostURLInfoKey
            return Acclaim.Configuration(connector: URLSession(), hostURLInfoKey: defaultKey, bundleForHostURLInfo: NSBundle.main())
        }()
        
    }
    
    /// Shows current Acclaim version number. (readonly)
    public static let version = AcclaimVersionNumber
    
    
    public static var sharedRequestParameters: Parameters?
    public static var configuration: Configuration = Configuration.defaultConfiguration
    
    internal static var running:[String:Caller] = [:]
//    internal static var sessionTask: [Caller:NSURLSessionTask] = [:]
    
    internal static func addRunningCaller(caller: Caller){
        self.running[caller.identifier] = caller
    }
    
    internal static func removeRunningCaller(caller: Caller?){

        if let caller = caller  where self.running.keys.contains(caller.identifier){
            self.running.removeValue(forKey: caller.identifier)
        }
        
        ACDebugLog(log: "removeRunningCallerByIdentifier:\(caller?.identifier)")
        
        defer{
            ACDebugLog(log: "caller:\(caller)")
            ACDebugLog(log: "count of running caller:\(Acclaim.running.count)")
        }
        
    }

    
    internal static var sharedURLCache: NSURLCache{
        return NSURLCache.shared()
    }
    
    internal static func cachedResponse(request: NSURLRequest) -> NSCachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponse(for: request)
    }

    internal static func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest){
        Acclaim.sharedURLCache.storeCachedResponse(cachedResponse, for: request)
    }
    
    internal static func removeAllCachedResponsesSinceDate(date: NSDate){
        Acclaim.sharedURLCache.removeCachedResponses(since: date)
    }
    
    internal static func removeAllCachedResponses(){
        Acclaim.sharedURLCache.removeAllCachedResponses()
    }
    
    
    internal static func removeCachedResponse(request: NSURLRequest){
        return Acclaim.sharedURLCache.removeCachedResponse(for: request)
    }
    
}

extension Acclaim {
    
    public static func hostURLFromInfoDictionary()->NSURL? {
        
        guard let urlStr = self.configuration.bundleForHostURLInfo.infoDictionary?[Acclaim.Configuration.defaultHostURLInfoKey] as? String else{
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
