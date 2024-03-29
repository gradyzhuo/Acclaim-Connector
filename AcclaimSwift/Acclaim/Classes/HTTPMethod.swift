//
//  Method.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

/// The method of HTTP request.
public enum HTTPMethod {
    
    public typealias RawValue = String

    case GET
    
    case POST
    case PUT
    case DELETE
    case HEAD
    case OPTIONS
    case CONNECT
    
    case POSTWith(serializer: SerializerType)
    case PUTWith(serializer: SerializerType)
    case DELETEWith(serializer: SerializerType)
    case HEADWith(serializer: SerializerType)
    case OPTIONSWith(serializer: SerializerType)
    case CONNECTWith(serializer: SerializerType)
    
    internal var serializer: ParametersSerializer {
        switch self {
        case let .POSTWith(serialize):
            return serialize.serializer
        
        case let .PUTWith(serialize):
            return serialize.serializer
        case let .DELETEWith(serialize):
            return serialize.serializer
        case let .HEADWith(serialize):
            return serialize.serializer
        case let .OPTIONSWith(serialize):
            return serialize.serializer
        case let .CONNECTWith(serialize):
            return serialize.serializer
        default:
            return SerializerType.QueryString.serializer
        }
    }
    
    public func HTTPMethodByReplaceSerializer(serializer: SerializerType)->HTTPMethod {
        
        switch self {
        
        case .POST:
            return .POSTWith(serializer: serializer)
        case .PUT:
            return .PUTWith(serializer: serializer)
        case .DELETE:
            return .DELETEWith(serializer: serializer)
        case .HEAD:
            return .HEADWith(serializer: serializer)
        case .OPTIONS:
            return .OPTIONSWith(serializer: serializer)
        case .CONNECT:
            return .CONNECTWith(serializer: serializer)
        
        case .POSTWith:
            fallthrough
        case .PUTWith:
            fallthrough
        case .DELETEWith:
            fallthrough
        case .OPTIONSWith:
            fallthrough
        case .CONNECTWith:
            return self
            
        default:
            ACDebugLog("[Failed]: The method of itself, \(self.rawValue) can't append a serializer to serialize.")
            return self
        }
        
    }
    
}

//MARK: - RawRepresentable Extension
extension HTTPMethod : RawRepresentable {
    public init?(rawValue: HTTPMethod.RawValue) {
        switch rawValue.uppercaseString {
        case "GET":
            self = .GET
        case "POST":
            self = .POST
        case "PUT":
            self = .PUT
        case "DELETE":
            self = .DELETE
        case "HEAD":
            self = .HEAD
        case "OPTIONS":
            self = .OPTIONS
        case "CONNECT":
            self = .CONNECT
        default:
            ACDebugLog("The rawvalue your input : '\(rawValue)' can't be accepted. It will be GET instead.")
            self = .GET
        }
    }
    
    public var rawValue: String {
        
        switch self {
        case .GET:
            return "GET"
            
        case .POSTWith:
            fallthrough
        case .POST:
            return "POST"
            
        case .PUTWith:
            fallthrough
        case .PUT:
            return "PUT"
            
        case .DELETEWith:
            fallthrough
        case .DELETE:
            return "DELETE"
            
        case .HEADWith:
            fallthrough
        case .HEAD:
            return "HEAD"
            
        case .OPTIONSWith:
            fallthrough
        case .OPTIONS:
            return "OPTIONS"
            
        case .CONNECTWith:
            fallthrough
        case .CONNECT:
            return "CONNECT"
        }
    }
}

public func ==(lhs: HTTPMethod, rhs: HTTPMethod)->Bool{
    return lhs.rawValue == rhs.rawValue
}

//typealias
extension HTTPMethod : StringLiteralConvertible {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    /// Create an instance initialized to `value`.
    public init(stringLiteral value: HTTPMethod.StringLiteralType){
        self = HTTPMethod(rawValue: value)!
    }
    
    public init(unicodeScalarLiteral value: HTTPMethod.UnicodeScalarLiteralType) {
        self = HTTPMethod(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: HTTPMethod.ExtendedGraphemeClusterLiteralType) {
        self = HTTPMethod(stringLiteral: value)
    }
}
