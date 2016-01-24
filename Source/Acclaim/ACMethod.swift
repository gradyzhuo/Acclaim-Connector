//
//  Method.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public enum SerializerType {
    case QueryString
    case JSON(option: NSJSONWritingOptions)
    case Custom(serializer: Serializer)
    
    internal var serializer: Serializer {
        
        switch self {
        case let .JSON(option):
            return ACParamsJSONSerializer(option: option)
        case .QueryString:
            return ACParamsQueryStringSerializer()
        case let .Custom(serializer):
            return serializer
        }
        
    }

    
}

//typealias
extension ACMethod : StringLiteralConvertible {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    /// Create an instance initialized to `value`.
    public init(stringLiteral value: ACMethod.StringLiteralType){
        self = ACMethod(rawValue: value)!
    }
    
    public init(unicodeScalarLiteral value: ACMethod.UnicodeScalarLiteralType) {
        self = ACMethod(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ACMethod.ExtendedGraphemeClusterLiteralType) {
        self = ACMethod(stringLiteral: value)
    }
}

public enum ACMethod {
    
    public typealias RawValue = String

    case GET
    
    case POST
    case PUT
    case DELETE
    case HEAD
    case OPTIONS
    case CONNECT
    
    case POSTWith(serialize: SerializerType)
    case PUTWith(serialize: SerializerType)
    case DELETEWith(serialize: SerializerType)
    case HEADWith(serialize: SerializerType)
    case OPTIONSWith(serialize: SerializerType)
    case CONNECTWith(serialize: SerializerType)
    
    internal var serializer: Serializer {
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
    
    
    
}


extension ACMethod : RawRepresentable {
    public init?(rawValue: ACMethod.RawValue) {
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

public func ==(lhs: ACMethod, rhs: ACMethod)->Bool{
    return lhs.rawValue == rhs.rawValue
}
