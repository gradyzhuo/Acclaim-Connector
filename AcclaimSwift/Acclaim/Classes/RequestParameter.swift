//
//  ACParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Parameter {
    var key: String { get }
}

public protocol ParameterValueType{ }

extension String : ParameterValueType{ /* not implemented.*/ }
extension Int: ParameterValueType{ /* not implemented.*/ }

public struct FormDataParameter : Parameter {
    public internal(set) var key: String
    public internal(set) var data: NSData
    public internal(set) var fileName: String
    public internal(set) var MIME: String
    
    public init(key: String, data: NSData, fileName: String = "", MIME: String = ""){
        self.key = key
        self.data = data
        self.fileName = fileName
        self.MIME = MIME
    }
}


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


public struct RequestParameters {
    var params:[String:Parameter]
    
    public init(){
        self.params = [:]
    }
    
    public init(params:[Parameter]){
        self.params = params.reduce([:], combine: { ( params, param) -> [String:Parameter] in
            var params = params
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
    
    public mutating func addParam(param:Parameter){
        
        if !self.params.keys.contains(param.key) {
            self.params[param.key] = param
        }
    }
    
    public mutating func addParams(params:RequestParameters){
        for (_, param) in params.params {
            self.addParam(param)
        }
    }
    
    public mutating func removeParam(forKey key:String)->Parameter? {
        return self.params.removeValueForKey(key)
    }
    
    public mutating func removeParam(forKeys keys:[String])->[Parameter] {
        
        let paramsArray = keys.reduce([], combine: { (array, key) -> [Parameter] in
            var array = array
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
    public typealias Element = Parameter
    
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
            self.addParam(FormParameter(key: $0.0, value: $0.1))
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
    public mutating func addParamValue(value: ParameterValueType, forKey key:String)->Parameter{
        let param = FormParameter(key: key, value: value)
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
    public mutating func addParamValue(value: [ParameterValueType], forKey key:String)->Parameter{
        let param = FormParameter(key: key, value: value)
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
    public mutating func addParamValue(value: [String:ParameterValueType], forKey key:String)->Parameter{
        let param = FormParameter(key: key, value: value)
        self.addParam(param)
        return param
    }
    
    public mutating func addFormData(data: NSData?, forKey key: String, fileName: String = "", MIME: String = "")->Parameter{
        let param = FormDataParameter(key: key, data: data ?? NSData(), fileName: fileName, MIME: MIME)
        self.addParam(param)
        return param
    }
    
}

