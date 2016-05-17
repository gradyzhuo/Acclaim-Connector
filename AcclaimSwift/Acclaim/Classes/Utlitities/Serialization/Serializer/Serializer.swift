//
//  Protocol.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Serializer {}

public protocol ParametersSerializer:Serializer {
    func serialize(params:RequestParameters) -> NSData?
    func serialize(params:[Parameter]) -> NSData?
}

public enum SerializerType {
    case QueryString
    case JSON(option: NSJSONWritingOptions)
    case MultipartForm
    case Custom(serializer: ParametersSerializer)
    
    internal var serializer: ParametersSerializer {
        
        switch self {
        case let .JSON(option):
            return JSONParametersSerializer(option: option)
        case .QueryString:
            return QueryStringParametersSerializer()
        case .MultipartForm:
            return MultipartFormSerializer()
        case let .Custom(serializer):
            return serializer
        }
        
    }
    
    
}

