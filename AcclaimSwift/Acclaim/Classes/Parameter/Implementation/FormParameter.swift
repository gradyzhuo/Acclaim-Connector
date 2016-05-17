//
//  FormParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public enum FormParameter : Parameter, CustomStringConvertible{
    case StringValue(key: String, value: String)
    case ArrayValue(key: String, value: [String])
    case DictionaryValue(key: String, value: [String:String])
    
    public init<T:ParameterValue>(key: String, value: T){
        self = FormParameter.StringValue(key: key, value: String(value))
    }
    
    public init<T:ParameterValue>(key: String, value: [T]){
        self = FormParameter.ArrayValue(key: key, value: value.map { String($0) })
    }
    
    public init<T:ParameterValue>(key: String, value: [String:T]){
        
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
    
    
    public var description: String{
        
        switch self {
        case .StringValue(let key, let value):
            return "StringValue(\(key):\(value))"
        case .ArrayValue(let key, let value):
            return "ArrayValue(\(key):\(value.joinWithSeparator(",")))"
        case .DictionaryValue(let key, let value):
            let valueString = value.map({ (element) -> String in
                let key = "\(element.0)"
                let value = "\(element.1)"
                return "(\(key):(\(value))"
            })
            return "DictionaryValue(key:\(key),value:\(valueString))"
        }

    }
    
}