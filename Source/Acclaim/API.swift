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
    
    public internal(set) var apiURL:NSURL!
    
    public var method:ACMethod = .GET{
        didSet{
            let mutableRequest = self.request.mutableCopy() as! NSMutableURLRequest
            mutableRequest.HTTPMethod = method.rawValue
            self.request = mutableRequest
        }
    }
    
    public var paramsType:ACRequestParamType = .URLParameters
    
    public var timeoutInterval:NSTimeInterval = 30 {
        didSet{
            let mutableRequest = self.request.mutableCopy() as! NSMutableURLRequest
            mutableRequest.timeoutInterval = timeoutInterval
            self.request = mutableRequest
        }
    }
    
    public var cachePolicy:NSURLRequestCachePolicy = .UseProtocolCachePolicy{
        didSet{
            let mutableRequest = self.request.mutableCopy() as! NSMutableURLRequest
            mutableRequest.cachePolicy = cachePolicy
            self.request = mutableRequest
        }
    }
    
    public var HTTPHeaderFields:[String:String] = [:]{
        didSet{
            let mutableRequest = self.request.mutableCopy() as! NSMutableURLRequest
            mutableRequest.allHTTPHeaderFields?.removeAll(keepCapacity: false)
            
            for (key, value) in HTTPHeaderFields {
                mutableRequest.addValue(value, forHTTPHeaderField: key)
            }
            self.request = mutableRequest
        }
    }
    
//    internal var mutableRequest:NSMutableURLRequest
    public internal(set) var request:NSURLRequest
    
    
    public init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method:ACMethod = .GET, paramsType:ACRequestParamType = .URLParameters) throws {
        
        guard let validHostURL = host else {
            
            let reason = "Error: [Host URL] is not found."
            let recoverSuggestion = "Please assign your api host url, or setup '\(ACAPIHostURLInfoKey)' into info.plist."
            
            throw NSError(domain: "API.Constructor", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:reason, NSLocalizedRecoverySuggestionErrorKey:recoverSuggestion])
        }
        
        let apiURL = validHostURL.URLByAppendingPathComponent(api)
        
        self = API(URL: apiURL, method: method, paramsType: paramsType)
        
    }

    public init(URL:NSURL, method:ACMethod = .GET, paramsType:ACRequestParamType = .URLParameters){
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: URL, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        request.HTTPMethod = method.rawValue
        self = API(request: request, paramsType: paramsType)
        
        self.method = method
    }
    
    public init(request:NSURLRequest , paramsType:ACRequestParamType = .URLParameters){
        self.request = request
        self.paramsType = paramsType
        self.apiURL = request.URL
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
        return self.request.hashValue
    }
}

public func ==(lhs:API, rhs:API)->Bool{
    return lhs.hashValue == rhs.hashValue
}