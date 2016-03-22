//
//  QueryStringParametersSerializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct QueryStringParametersSerializer : ParametersSerializer {
    
    public func serialize(params: RequestParameters) -> NSData? {
        
        let components = NSURLComponents()
        components.queryItems = [NSURLQueryItem]()
        
        params.params.forEach {(_, parameter) -> Void in
            
            if let parameter = parameter as? FormParameter {
                switch parameter {
                case .StringValue(let key, let value):
                    components.queryItems?.append(NSURLQueryItem(name: key, value: value))
                case .ArrayValue(let key, let arrayValue):
                    let queryItems = arrayValue.map{ NSURLQueryItem(name: "\(key)[]", value: $0) }
                    components.queryItems?.appendContentsOf(queryItems)
                case .DictionaryValue(let key, let dictionaryValue):
                    dictionaryValue.forEach { (element:(key:String, value:String)) in
                        components.queryItems?.append(NSURLQueryItem(name: "\(key)[\(element.key)]", value: element.value))
                    }
                }
            }
            
            
        }
        
        let query:String? = components.query
        
        return query?.dataUsingEncoding(NSUTF8StringEncoding)
    }
}