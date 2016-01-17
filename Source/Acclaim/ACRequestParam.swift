//
//  ACRequestParam.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

extension ACRequestParams : ArrayLiteralConvertible {
    public typealias Element = ACRequestParam
}

extension ACRequestParams : DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = AnyObject
}

public struct ACRequestParams {
    
    var params:[String:ACRequestParam]
    
    public init(){
        self = ACRequestParams(params: [])
    }
    
    public init(params:[ACRequestParam]){
        self.params = [:]
        
        self.params = params.reduce([:], combine: { (var params, param) -> [String:ACRequestParam] in
            params[param.key] = param
            return params
        })
        
    }
    
    /// Create an instance initialized with `dictionary elements`.
    public init(dictionary elements: [Key:Value]){
        self = ACRequestParams()
        
        elements.forEach {
            self.addParam($0.1, forKey: $0.0)
        }
        
    }
    
    /// Create an instance initialized with `elements`.
    public init(arrayLiteral elements: Element...){
        self = ACRequestParams(params: elements)
    }
    
    /// Create an instance initialized with `elements`.
    public init(dictionaryLiteral elements: (Key, Value)...){
        self = ACRequestParams()
        
        elements.forEach {
            self.addParam($0.1, forKey: $0.0)
        }

    }
    
    
    public mutating func addParam(value: AnyObject, forKey key:String){
        let param = ACRequestParam(key: key, value: value)
        self.addParam(param)
    }
    
    public mutating func addParam(param:ACRequestParam){
        
        if self.params.indexForKey(param.key) == nil {
            self.params[param.key] = param
        }
    }
    
    public mutating func addParams(params:ACRequestParams){
        for (_, param) in params.params {
            self.addParam(param)
        }
    }
    
    public mutating func removeParam(forKey key:String)->ACRequestParam? {
        return self.params.removeValueForKey(key)
    }
    
    public mutating func removeParam(forKeys keys:[String])->[ACRequestParam] {
        
        let paramsArray = keys.reduce([], combine: { (var array, key) -> [ACRequestParam] in
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
    
    internal func serialize(serializer: Serializer) -> NSData? {
        return serializer.serialize(self)
    }
    
}


public struct ACRequestParam  {
    public internal(set) var key:String
    public internal(set) var value:AnyObject
    
    public init(key: String, value: AnyObject){
        self.key = key
        self.value = value
    }
}
