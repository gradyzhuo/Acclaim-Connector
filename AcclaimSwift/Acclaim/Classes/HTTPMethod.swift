//
//  Method.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

/// The method of HTTP request.
public enum Method {
    
    public typealias RawValue = String

    case get
    
    case post
    case put
    case delete
    case head
    case options
    case connect
    
    case postWith(serializer: SerializerType)
    case putWith(serializer: SerializerType)
    case deleteWith(serializer: SerializerType)
    case headWith(serializer: SerializerType)
    case optionsWith(serializer: SerializerType)
    case connectWith(serializer: SerializerType)
    
    internal var serializer: ParametersSerializer {
        switch self {
        case let .postWith(serialize):
            return serialize.serializer
        
        case let .putWith(serialize):
            return serialize.serializer
        case let .deleteWith(serialize):
            return serialize.serializer
        case let .headWith(serialize):
            return serialize.serializer
        case let .optionsWith(serialize):
            return serialize.serializer
        case let .connectWith(serialize):
            return serialize.serializer
        default:
            return SerializerType.queryString.serializer
        }
    }
    
    public func replaced(bySerializerType serializer: SerializerType)->Method {
        
        switch self {
        
        case .post:
            return .postWith(serializer: serializer)
        case .put:
            return .putWith(serializer: serializer)
        case .delete:
            return .deleteWith(serializer: serializer)
        case .head:
            return .headWith(serializer: serializer)
        case .options:
            return .optionsWith(serializer: serializer)
        case .connect:
            return .connectWith(serializer: serializer)
        
        case .postWith:
            fallthrough
        case .putWith:
            fallthrough
        case .deleteWith:
            fallthrough
        case .optionsWith:
            fallthrough
        case .connectWith:
            return self
            
        default:
            Debug(log: "[Failed]: The method of itself, \(self.rawValue) can't append a serializer to serialize.")
            return self
        }
        
    }
    
}

//MARK: - RawRepresentable Extension
extension Method : RawRepresentable {
    public init?(rawValue: Method.RawValue) {
        switch rawValue.uppercased() {
        case "GET":
            self = .get
        case "POST":
            self = .post
        case "PUT":
            self = .put
        case "DELETE":
            self = .delete
        case "HEAD":
            self = .head
        case "OPTIONS":
            self = .options
        case "CONNECT":
            self = .connect
        default:
            Debug(log: "The rawvalue your input : '\(rawValue)' can't be accepted. It will be GET instead.")
            self = .get
        }
    }
    
    public var rawValue: String {
        
        switch self {
        case .get:
            return "GET"
            
        case .postWith:
            fallthrough
        case .post:
            return "POST"
            
        case .putWith:
            fallthrough
        case .put:
            return "PUT"
            
        case .deleteWith:
            fallthrough
        case .delete:
            return "DELETE"
            
        case .headWith:
            fallthrough
        case .head:
            return "HEAD"
            
        case .optionsWith:
            fallthrough
        case .options:
            return "OPTIONS"
            
        case .connectWith:
            fallthrough
        case .connect:
            return "CONNECT"
        }
    }
}

public func ==(lhs: Method, rhs: Method)->Bool{
    return lhs.rawValue == rhs.rawValue
}

//typealias
extension Method : StringLiteralConvertible {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    /// Create an instance initialized to `value`.
    public init(stringLiteral value: Method.StringLiteralType){
        self = Method(rawValue: value)!
    }
    
    public init(unicodeScalarLiteral value: Method.UnicodeScalarLiteralType) {
        self = Method(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: Method.ExtendedGraphemeClusterLiteralType) {
        self = Method(stringLiteral: value)
    }
}
