//
//  API.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public class  API : StringLiteralConvertible {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    public internal(set) var apiURL:NSURL
    
    public var method:ACMethod = .GET
    
    public var timeoutInterval:NSTimeInterval = 30
    
    public var cachePolicy:NSURLRequestCachePolicy = .UseProtocolCachePolicy
    
    public var HTTPHeaderFields:[String:String] = [:]
    
    internal var identifier: String = String(NSDate().timeIntervalSince1970)
    
    public convenience init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method:ACMethod = .GET) throws {
        
        guard let validHostURL = host else {
            
            let reason = "Error: [Host URL] is not found."
            let recoverSuggestion = "Please assign your api host url, or setup '\(ACAPIHostURLInfoKey)' into your project info.plist."
            
            throw NSError(domain: "API.Constructor", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:reason, NSLocalizedRecoverySuggestionErrorKey:recoverSuggestion])
        }
        
        let apiURL = validHostURL.URLByAppendingPathComponent(api)
        
        self.init(URL: apiURL, method: method)
        
    }

    public init(URL:NSURL, method:ACMethod = .GET){
        self.apiURL = URL
        self.method = method
        
    }
    
    public required convenience init(stringLiteral value: StringLiteralType) {
        
        if let components = NSURLComponents(string: value) where components.scheme != nil, let url = components.URL  {
            self.init(URL: url)
        }else{
            try! self.init(api: value)
        }
        
    }
    
    /// Create an instance initialized to `value`.
    public required convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    /// Create an instance initialized to `value`.
    public required convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    
}

extension API {
    
    internal func getRequest(params: ACRequestParams)->NSURLRequest {
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: self.apiURL, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        
        let body = self.method.serializer.serialize(params)
        
        if let body = body where self.method == ACMethod.GET {
            let components = NSURLComponents(URL: self.apiURL, resolvingAgainstBaseURL: false)
            components?.query = String(data: body, encoding: NSUTF8StringEncoding)
            request.URL = (components?.URL)!
        }else{
            request.HTTPBody = body
        }
        
        request.HTTPMethod = self.method.rawValue
        request.allowsCellularAccess = Acclaim.allowsCellularAccess
        
        self.HTTPHeaderFields.forEach { (field:(key:String, value: String)) -> () in
            request.addValue(field.value, forHTTPHeaderField: field.key)
        }
        
        return request.copy() as! NSURLRequest
        
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