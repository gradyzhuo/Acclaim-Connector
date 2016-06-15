//
//  QueryStringParametersSerializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct QueryStringParametersSerializer : ParametersSerializer {
    
    public func serialize(params: Parameters) -> Data? {
        
        var components = URLComponents()
        components.queryItems = [URLQueryItem]()
        
        params.forEach {(parameter) -> Void in
            
            if let parameter = parameter as? FormParameter {
                switch parameter {
                case .stringValue(let key, let value):
                    components.queryItems?.append(URLQueryItem(name: key, value: value))
                case .arrayValue(let key, let arrayValue):
                    let queryItems = arrayValue.map{ URLQueryItem(name: "\(key)[]", value: $0) }
                    components.queryItems?.append(contentsOf: queryItems)
                case .dictionaryValue(let key, let dictionaryValue):
                    dictionaryValue.forEach { (element:(key:String, value:String)) in
                        components.queryItems?.append(URLQueryItem(name: "\(key)[\(element.key)]", value: element.value))
                    }
                }
            }
            
            
        }
        
        let query:String? = components.query
        
        return query?.data(using: String.Encoding.utf8)
    }
}
