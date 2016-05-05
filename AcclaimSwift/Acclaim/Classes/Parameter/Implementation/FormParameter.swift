//
//  FormParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public enum FormParameter : Parameter{
    case StringValue(key: String, value: String)
    case ArrayValue(key: String, value: [String])
    case DictionaryValue(key: String, value: [String:String])
    
    public init(key: String, value: String){
        self = FormParameter.StringValue(key: key, value: value)
    }
    
    public init(key: String, value: ParameterValueType){
        self = FormParameter(key: key, value: String(value))
    }
    
    public init(key: String, value: [ParameterValueType]){
        self = FormParameter.ArrayValue(key: key, value: value.map { String($0) })
    }
    
    public init(key: String, value: [String:ParameterValueType]){
        
        let dictionValue = value.reduce([String:String]()) { (dict, item) -> [String:String] in
            var value = dict
            value[item.0] = String(item.1)
            return value
        }
        
        self = FormParameter.DictionaryValue(key: key, value: dictionValue )
        
    }
    
    public var key:String{
        switch self {
        case .StringValue(let key, _):
            return key
        case .ArrayValue(let key, _):
            return key
        case .DictionaryValue(let key, _):
            return key
        }
    }
    
}