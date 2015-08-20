//
//  ACAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

extension ACAPI : StringLiteralConvertible {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
}

public struct  ACAPI {
    
    public internal(set) var apiURL:NSURL!
    
    public var method:ACMethod = .GET{
        didSet{
            let mutableRequest = self.request.mutableCopy() as! NSMutableURLRequest
            mutableRequest.HTTPMethod = method.rawValue
            self.request = mutableRequest
        }
    }
    
    public var paramsType:ACRequestParamType = .KeyValue
    
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
    
    
    public init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method:ACMethod = .GET, paramsType:ACRequestParamType = .KeyValue){
        
        assert(host != nil, "Error: [Host URL] is nil, please assign your api host url, or setup 'ACAPIHostURLInfoKey' into info.plist.")
        
        let apiURL = host.URLByAppendingPathComponent(api)
        
        self = ACAPI(URL: apiURL, method: method, paramsType: paramsType)
        
    }

    public init(URL:NSURL, method:ACMethod = .GET, paramsType:ACRequestParamType = .KeyValue){
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: URL, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        request.HTTPMethod = method.rawValue
        self = ACAPI(request: request, paramsType: paramsType)
        
        self.method = method
    }
    
    public init(request:NSURLRequest , paramsType:ACRequestParamType = .KeyValue){
        self.request = request
        self.paramsType = paramsType
        self.apiURL = request.URL
    }

    
    /// Create an instance initialized to `value`.
    public init(stringLiteral value: StringLiteralType){
        self = ACAPI(api: value)
    }
    
    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType){
        self = ACAPI(stringLiteral: value)
    }
    
    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType){
        self = ACAPI(stringLiteral: value)
    }
    
    
}


extension ACAPI : Hashable {
    public var hashValue: Int {
        return self.request.hashValue
    }
}

public func ==(lhs:ACAPI, rhs:ACAPI)->Bool{
    return lhs.hashValue == rhs.hashValue
}