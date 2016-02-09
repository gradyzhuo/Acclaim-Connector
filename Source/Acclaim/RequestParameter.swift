//
//  ACParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol ParameterValueType{ }

extension String : ParameterValueType{ /* not implemented.*/ }
extension Int: ParameterValueType{ /* not implemented.*/ }

public enum RequestParameter{
    case StringValue(key: String, value: String)
    case ArrayValue(key: String, value: [String])
    case DictionaryValue(key: String, value: [String:String])
    
    public init(key: String, value: String){
        self = RequestParameter.StringValue(key: key, value: value)
    }

    public init(key: String, value: ParameterValueType){
        self = RequestParameter(key: key, value: String(value))
    }
    
    public init(key: String, value: [ParameterValueType]){
        self = RequestParameter.ArrayValue(key: key, value: value.map { String($0) })
    }
    
    public init(key: String, value: [String:ParameterValueType]){
        
        let dictionValue = value.reduce([String:String]()) { (dict, item) -> [String:String] in
            var value = dict
            value[item.0] = String(item.1)
            return value
        }
        
        self = RequestParameter.DictionaryValue(key: key, value: dictionValue )

    }
    
    internal var key:String{
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


public struct RequestParameters {
    var params:[String:RequestParameter]
    
    public init(){
        self.params = [:]
    }
    
    public init(params:[RequestParameter]){
        self.params = params.reduce([:], combine: { (var params, param) -> [String:RequestParameter] in
            params[param.key] = param
            return params
        })
    }
    
    /// Create an instance initialized with `dictionary elements`.
    public init(dictionary elements: [Key:Value]){
        self = RequestParameters()
        
        elements.forEach {
            self.addParamValue($0.1, forKey: $0.0)
        }
        
    }
    
    public mutating func addParam(param:RequestParameter){
        
        if !self.params.keys.contains(param.key) {
            self.params[param.key] = param
        }
    }
    
    public mutating func addParams(params:RequestParameters){
        for (_, param) in params.params {
            self.addParam(param)
        }
    }
    
    public mutating func removeParam(forKey key:String)->RequestParameter? {
        return self.params.removeValueForKey(key)
    }
    
    public mutating func removeParam(forKeys keys:[String])->[RequestParameter] {
        
        let paramsArray = keys.reduce([], combine: { (var array, key) -> [RequestParameter] in
            if let param = self.params.removeValueForKey(key) {
                array.append(param)
            }
            return array
        })
        
        return paramsArray
    }
    
    public mutating func clearAllParams(){
        self.params.removeAll(keepCapacity: false)
    }
    
    internal func serialize(serializer: ParametersSerializer) -> NSData? {
        return serializer.serialize(self)
    }
    
}

extension RequestParameters : ArrayLiteralConvertible {
    public typealias Element = RequestParameter
    
    /// Create an instance initialized with `elements`.
    public init(arrayLiteral elements: Element...){
        self = RequestParameters(params: elements)
    }
}

extension RequestParameters : DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = ParameterValueType
    
    /// Create an instance initialized with `elements`.
    public init(dictionaryLiteral elements: (Key, Value)...){
        self = []
        
        elements.forEach {
            self.addParam(RequestParameter(key: $0.0, value: $0.1))
//            if let value = $0.1 as? ParameterValueType {
//                self.addParam(RequestParameter(key: $0.0, value: value))
//            }else if let arrayValue = $0.1 as? [ParameterValueType]{
//                let value:[ParameterValueType] = arrayValue.map{ $0  }
//                self.addParam(RequestParameter(key: $0.0, value: value))
//            }else if let dictionaryValue = $0.1 as? [String:ParameterValueType]{
//                self.addParam(RequestParameter(key: $0.0, value: dictionaryValue))
//            }else {
//                ACDebugLog("The type of \($0.1) by key:\($0.0) is not supported.")
//            }
        }
        
    }
    
}

//MARK: - Convenience Methods
extension RequestParameters {
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
        - value: Value by instance of ParameterValueType.
        - forKey key: a string type value be the key.
     - returns: The new RequestParameter generated.
     */
    public mutating func addParamValue(value: ParameterValueType, forKey key:String)->RequestParameter{
        let param = RequestParameter(key: key, value: value)
        self.addParam(param)
        return param
    }
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of Array<ParameterValueType>.
     - forKey key: a string type value be the key.
     - returns: The new RequestParameter generated.
     */
    public mutating func addParamValue(value: [ParameterValueType], forKey key:String)->RequestParameter{
        let param = RequestParameter(key: key, value: value)
        self.addParam(param)
        return param
    }
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of Dictionary<String,ParameterValueType>.
     - forKey key: a string type value be the key.
     - returns: The new RequestParameter generated.
     */
    public mutating func addParamValue(value: [String:ParameterValueType], forKey key:String)->RequestParameter{
        let param = RequestParameter(key: key, value: value)
        self.addParam(param)
        return param
    }
}

