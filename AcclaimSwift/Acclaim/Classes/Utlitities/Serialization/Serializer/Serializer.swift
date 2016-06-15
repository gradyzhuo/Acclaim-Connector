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
    func serialize(params: Parameters) -> Data?
}

public enum SerializerType {
    case queryString
    case json(option: JSONSerialization.WritingOptions)
    case multipartForm
    case custom(serializer: ParametersSerializer)
    
    internal var serializer: ParametersSerializer {
        
        switch self {
        case let .json(option):
            return JSONParametersSerializer(option: option)
        case .queryString:
            return QueryStringParametersSerializer()
        case .multipartForm:
            return MultipartFormSerializer()
        case let .custom(serializer):
            return serializer
        }
        
    }
    
    
}

