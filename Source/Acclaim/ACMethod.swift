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

public enum ACMethod {
    
    case GET
    case POST(serializer: Serializer)
    case PUT(serializer: Serializer)
    case DELETE(serializer: Serializer)
    case HEAD(serializer: Serializer)
    case OPTIONS(serializer: Serializer)
    case CONNECT(serializer: Serializer)
    
    internal var serializer: Serializer {
        switch self {
        case let .POST(serializer):
            return serializer
        
        case let .PUT(serializer):
            return serializer
        case let .DELETE(serializer):
            return serializer
        case let .HEAD(serializer):
            return serializer
        case let .OPTIONS(serializer):
            return serializer
        case let .CONNECT(serializer):
            return serializer
        case .GET:
            fallthrough
        default:
            return ACParamsQueryStringSerializer()
        }
    }
    
    public var rawValue: String {
        
        switch self {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        case .PUT:
            return "PUT"
        case .DELETE:
            return "DELETE"
        case .HEAD:
            return "HEAD"
        case .OPTIONS:
            return "OPTIONS"
        case .CONNECT:
            return "CONNECT"
        }
    }
    
}

public func ==(lhs: ACMethod, rhs: ACMethod)->Bool{
    return lhs.rawValue == rhs.rawValue
}
