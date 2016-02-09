//
//  ACSerialization.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public enum SerializerType {
    case QueryString
    case JSON(option: NSJSONWritingOptions)
    case Custom(serializer: ParametersSerializer)
    
    internal var serializer: ParametersSerializer {
        
        switch self {
        case let .JSON(option):
            return JSONParametersSerializer(option: option)
        case .QueryString:
            return QueryStringParametersSerializer()
        case let .Custom(serializer):
            return serializer
        }
        
    }
    
    
}


public protocol ParametersSerializer {
    func serialize(params:RequestParameters) -> NSData?
}

public struct JSONParametersSerializer : ParametersSerializer {
    public var option: NSJSONWritingOptions
    
    public init(option: NSJSONWritingOptions = .PrettyPrinted){
        self.option = option
    }
    
    public func serialize(params: RequestParameters) -> NSData? {

        var JSONObject = [String:AnyObject]()
        params.params.forEach {(_, parameter) -> Void in
            switch parameter {
            case .StringValue(let key, let value):
                JSONObject[key] = value
            case .ArrayValue(let key, let arrayValue):
                let value = arrayValue.map{ $0 }
                JSONObject[key] = value
            case .DictionaryValue(let key, let dictionaryValue):
                let value = dictionaryValue.reduce([String:AnyObject](), combine: { (dict, element:(key: String, value: String)) -> [String:AnyObject] in
                    var dictValue = dict
                    dictValue[element.key] = element.value
                    return dictValue
                })
                JSONObject[key] = value
            }
        }
        
        
        return try? NSJSONSerialization.dataWithJSONObject(JSONObject, options: self.option)
    }
    
}


public struct QueryStringParametersSerializer : ParametersSerializer {

    public func serialize(params: RequestParameters) -> NSData? {
        
        let components = NSURLComponents()
        components.queryItems = [NSURLQueryItem]()
        
        params.params.forEach {(_, parameter) -> Void in
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
        
        let query:String? = components.query
        
        return query?.dataUsingEncoding(NSUTF8StringEncoding)
    }
}




