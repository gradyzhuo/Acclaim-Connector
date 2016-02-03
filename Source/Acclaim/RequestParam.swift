//
//  ACParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public struct Parameter  {
    public internal(set) var key:String
    public internal(set) var value:AnyObject
    
    public init(key: String, value: AnyObject){
        self.key = key
        self.value = value
    }
}

public struct Parameters {
    
    var params:[String:Parameter]
    
    public init(){
        self.params = [:]
    }
    
    public init(params:[Parameter]){
        self.params = params.reduce([:], combine: { (var params, param) -> [String:Parameter] in
            params[param.key] = param
            return params
        })
        
    }
    
    /// Create an instance initialized with `dictionary elements`.
    public init(dictionary elements: [Key:Value]){
        self = Parameters()
        
        elements.forEach {
            self.addParam($0.1, forKey: $0.0)
        }
        
    }
    
    /// Create an instance initialized with `elements`.
    public init(arrayLiteral elements: Element...){
        self = Parameters(params: elements)
    }
    
    /// Create an instance initialized with `elements`.
    public init(dictionaryLiteral elements: (Key, Value)...){
        self = Parameters()
        
        elements.forEach {
            self.addParam($0.1, forKey: $0.0)
        }

    }
    
    
    public mutating func addParam(value: AnyObject, forKey key:String){
        let param = Parameter(key: key, value: value)
        self.addParam(param)
    }
    
    public mutating func addParam(param:Parameter){
        
        if self.params.indexForKey(param.key) == nil {
            self.params[param.key] = param
        }
    }
    
    public mutating func addParams(params:Parameters){
        for (_, param) in params.params {
            self.addParam(param)
        }
    }
    
    public mutating func removeParam(forKey key:String)->Parameter? {
        return self.params.removeValueForKey(key)
    }
    
    public mutating func removeParam(forKeys keys:[String])->[Parameter] {
        
        let paramsArray = keys.reduce([], combine: { (var array, key) -> [Parameter] in
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

extension Parameters : ArrayLiteralConvertible {
    public typealias Element = Parameter
}

extension Parameters : DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = AnyObject
}

