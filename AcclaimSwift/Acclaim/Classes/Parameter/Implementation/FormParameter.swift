//
//  FormParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public enum FormParameter : Parameter, CustomStringConvertible{
    case stringValue(key: String, value: String)
    case arrayValue(key: String, value: [String])
    case dictionaryValue(key: String, value: [String:String])
    
    public init<T:ParameterValue>(key: String, value: T){
        self = FormParameter.stringValue(key: key, value: String(value))
    }
    
    public init<T:ParameterValue>(key: String, value: [T]){
        self = FormParameter.arrayValue(key: key, value: value.map { String($0) })
    }
    
    public init<T:ParameterValue>(key: String, value: [String:T]){
        
        let dictionValue = value.reduce([String:String]()) { (dict, item) -> [String:String] in
            var value = dict
            value[item.0] = String(item.1)
            return value
        }
        
        self = FormParameter.dictionaryValue(key: key, value: dictionValue )
        
    }
    
    public var key:String{
        switch self {
        case .stringValue(let key, _):
            return key
        case .arrayValue(let key, _):
            return key
        case .dictionaryValue(let key, _):
            return key
        }
    }
    
    
    public var description: String{
        
        switch self {
        case .stringValue(let key, let value):
            return "StringValue(\(key):\(value))"
        case .arrayValue(let key, let value):
            return "ArrayValue(\(key):\(value.joined(separator: ",")))"
        case .dictionaryValue(let key, let value):
            let valueString = value.map({ (element) -> String in
                let key = "\(element.0)"
                let value = "\(element.1)"
                return "(\(key):(\(value))"
            })
            return "DictionaryValue(key:\(key),value:\(valueString))"
        }

    }
    
}
