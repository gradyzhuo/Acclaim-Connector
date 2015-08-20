//
//  ACParamType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias ACRequestParamEncodeHandler = (params:[ACRequestParam])->NSData?


public enum ACRequestParamType : String, StringLiteralConvertible {
    case JSON = "JSON"
    case KeyValue = "KEYVALUE"

    internal func serialize(params:ACRequestParam)->NSData?{
        
        switch self {
        case ACRequestParamType.JSON:
            return ACParamsJSONSerializer.serialize(params)
        case ACRequestParamType.KeyValue:
            return ACParamsKeyValueSerializer.serialize(params)
        }

    }
    
    public init(stringLiteral value: StringLiteralType){
        self = ACRequestParamType(rawValue: value.uppercaseString) ?? ACRequestParamType.KeyValue
    }
    
    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType){
        self = ACRequestParamType(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = ACRequestParamType(stringLiteral: value)
    }
}

//JSON Encoder
extension ACRequestParamType {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
}

extension ACRequestParamType : Printable {
    public var description: String {
        switch self {
        case .JSON:
            return "JSON"
        case .KeyValue:
            return "KeyValue"
        }
//        Acclaim.
    }
    
}
