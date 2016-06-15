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
        public internal(set) var bundleForHostURLInfo: Bundle
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
        
        internal var cacheStoragePolicy:CacheStoragePolicy = .allowedInMemoryOnly(renewRule: .notRenewed)
        
        public init(connector: Connector, hostURLInfoKey key: String, bundleForHostURLInfo bundle: Bundle, allowsCellularAccess cellularAccess: Bool = true){
            self.connector = connector
            self.hostURLInfoKey = key
            self.bundleForHostURLInfo = bundle
            self.allowsCellularAccess = cellularAccess
        }
        
        public static var defaultConfiguration: Acclaim.Configuration = {
            let defaultKey = Acclaim.Configuration.defaultHostURLInfoKey
            return Acclaim.Configuration(connector: URLSession(), hostURLInfoKey: defaultKey, bundleForHostURLInfo: Bundle.main())
        }()
        
    }
    
    /// Shows current Acclaim version number. (readonly)
    public static let version = AcclaimVersionNumber
    
    
    public static var sharedRequestParameters: Parameters?
    public static var configuration: Configuration = Configuration.defaultConfiguration
    
    internal static var running:[String:Caller] = [:]
//    internal static var sessionTask: [Caller:NSURLSessionTask] = [:]
    
    internal static func add(runningCaller caller: Caller){
        self.running[caller.identifier] = caller
    }
    
    internal static func remove(runningCaller caller: Caller?){

        if let caller = caller  where self.running.keys.contains(caller.identifier){
            self.running.removeValue(forKey: caller.identifier)
        }
        
        Debug(log: "removeRunningCallerByIdentifier:\(caller?.identifier)")
        
        defer{
            Debug(log: "caller:\(caller)")
            Debug(log: "count of running caller:\(Acclaim.running.count)")
        }
        
    }

    
    internal static var sharedURLCache: URLCache{
        return URLCache.shared()
    }
    
    internal static func cachedResponse(for request: URLRequest) -> CachedURLResponse?{
        return Acclaim.sharedURLCache.cachedResponse(for: request)
    }

    internal static func store(cachedResponse: CachedURLResponse, forRequest request: URLRequest){
        Acclaim.sharedURLCache.storeCachedResponse(cachedResponse, for: request)
    }
    
    internal static func removeAllCachedResponsesSinceDate(_ date: Date){
        Acclaim.sharedURLCache.removeCachedResponses(since: date)
    }
    
    internal static func removeAllCachedResponses(){
        Acclaim.sharedURLCache.removeAllCachedResponses()
    }
    
    
    internal static func removeCachedResponse(_ request: URLRequest){
        return Acclaim.sharedURLCache.removeCachedResponse(for: request)
    }
    
}

extension Acclaim {
    
    public static func hostURLFromInfoDictionary()->URL? {
        
        guard let urlStr = self.configuration.bundleForHostURLInfo.infoDictionary?[Acclaim.Configuration.defaultHostURLInfoKey] as? String else{
            return nil
        }
        
        guard let url = URL(string: urlStr) else {
            return nil
        }
        
        return url
    }
    
}

internal func Debug(log:AnyObject){
    #if DEBUG
    print("[Log]: \(log)")
    #endif
}

internal func Debug(crash:AnyObject){
    #if DEBUG
        print("[Crash]: \(crash)")
    #endif
}
