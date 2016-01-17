//
//  API.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public struct  API : StringLiteralConvertible {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    public internal(set) var apiURL:NSURL
    
    public var method:ACMethod = .GET
    
    public var timeoutInterval:NSTimeInterval = 30
    
    public var cachePolicy:NSURLRequestCachePolicy = .UseProtocolCachePolicy
    
    public var HTTPHeaderFields:[String:String] = [:]
    
    internal var identifier: String = String(NSDate().timeIntervalSince1970)
    
    public init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method:ACMethod = .GET) throws {
        
        guard let validHostURL = host else {
            
            let reason = "Error: [Host URL] is not found."
            let recoverSuggestion = "Please assign your api host url, or setup '\(ACAPIHostURLInfoKey)' into info.plist."
            
            throw NSError(domain: "API.Constructor", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:reason, NSLocalizedRecoverySuggestionErrorKey:recoverSuggestion])
        }
        
        let apiURL = validHostURL.URLByAppendingPathComponent(api)
        
        self = API(URL: apiURL, method: method)
        
    }

    public init(URL:NSURL, method:ACMethod = .GET){
        self.apiURL = URL
        self.method = method
        
    }
    
    /// Create an instance initialized to `value`.
    public init(stringLiteral value: StringLiteralType) {
        
        if let components = NSURLComponents(string: value) where components.scheme != nil, let url = components.URL  {
            self = API(URL: url)
        }else{
            self = try! API(api: value)
        }
        
    }
    
    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = API(stringLiteral: value)
    }
    
    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = API(stringLiteral: value)
    }
    
    
}


extension API : Hashable {
    public var hashValue: Int {
        return self.identifier.hashValue
    }
}

public func ==(lhs:API, rhs:API)->Bool{
    return lhs.hashValue == rhs.hashValue
}