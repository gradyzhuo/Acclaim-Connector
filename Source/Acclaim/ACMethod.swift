//
//  Method.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

//typealias
extension ACMethod {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
}

public enum ACMethod : String, StringLiteralConvertible{
    
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case CONNECT = "CONNECT"
    
    /// Create an instance initialized to `value`.
    public init(stringLiteral value: StringLiteralType){
        
        if let method = ACMethod(rawValue: value.uppercaseString){
            self = method
        }else{
            
            print("method [\(value)] is not supported, it will be [GET] instead.")
            self = .GET
        }
    }
    
    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType){
        self = ACMethod(stringLiteral: value)
    }
    
    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType){
        self = ACMethod(stringLiteral: value)
    }
    
}