//
//  ACParamType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias ACRequestParamEncodeHandler = (params:[ACRequestParam])->NSData?


//public enum ACRequestParamType : String, StringLiteralConvertible {
//    case URLParameters = "URLParameters"
//    case JSON = "JSON"
//
//    internal func serialize(params:ACRequestParam)->NSData?{
//        
//        switch self {
//        case .JSON:
//            return ACParamsJSONSerializer.serialize(params)
//        case .URLParameters:
//            return ACParamsQueryStringSerializer.serialize(params)
//        }
//
//    }
//    
//    public init(stringLiteral value: StringLiteralType){
//        self = ACRequestParamType(rawValue: value.uppercaseString) ?? ACRequestParamType.URLParameters
//    }
//    
//    /// Create an instance initialized to `value`.
//    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType){
//        self = ACRequestParamType(stringLiteral: value)
//    }
//    
//    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
//        self = ACRequestParamType(stringLiteral: value)
//    }
//}

////JSON Encoder
//extension ACRequestParamType {
//    
//    public typealias StringLiteralType = String
//    public typealias ExtendedGraphemeClusterLiteralType = String
//    public typealias UnicodeScalarLiteralType = String
//    
//}
//
//extension ACRequestParamType : CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .JSON:
//            return "JSON"
//        case .URLParameters:
//            return "URLParameters"
//        }
////        Acclaim.
//    }
//    
//}
