//
//  ACParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

extension RangeReplaceableCollectionType where Generator.Element == Parameter {
    public typealias Element = Generator.Element
    
    public init(dictionary elements: [String:String]){
        self.init()
        elements.forEach {
            let formParam = FormParameter.StringValue(key: $0, value: $1)
            self.adds(formParam)
        }
    }
    
    public func indexOf(paramKey key: String)->Self.Index?{
        let index = self.indexOf { $0.key == key }
        return index
    }
    
    public func indexOf(param: Element)->Self.Index?{
        let index = self.indexOf { $0.key == param.key }
        return index
    }
    
    public func contains(param: Element) -> Bool {
        return self.contains{ $0.key == param.key }
    }
    
    public mutating func adds(param:Element){

        if !self.contains(param) {
            self.append(param)
        }
        
        
    }
    
    public mutating func removes(forKey key:String)->Element? {
        if let index = self.indexOf(paramKey: key){
            return self.removeAtIndex(index)
        }
        return nil
    }
    
    internal func serialize(serializer: ParametersSerializer) -> NSData? {
        if let parameters = self as? [Element] {
            return serializer.serialize(parameters)
        }
        return nil
    }
    
}


//MARK: - Convenience Methods
extension RangeReplaceableCollectionType where Generator.Element == Parameter {
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of ParameterValueType.
     - forKey key: a string type value be the key.
     - returns: The new RequestParameter generated.
     */
    public mutating func addParamValue(value: ParameterValueType, forKey key:String)->Element{
        let param = FormParameter(key: key, value: value)
        self.adds(param)
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
        self.adds(param)
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
        self.adds(param)
        return param
    }
    
    public mutating func addFormData(data: NSData?, forKey key: String, fileName: String = "", MIME: String = "")->Parameter{
        let param = FormDataParameter(key: key, data: data ?? NSData(), fileName: fileName, MIME: MIME)
        self.adds(param)
        return param
    }
    
}

//
////MARK: -
//public struct RequestParameters {
//    internal var _params:[String:Parameter]{
//        didSet{
//            self.params = _params.map{ $1 } //$0: String, $1: Parameter
//        }
//    }
//    
//    public internal(set) var params:[Parameter] = []
//    
//    public init(){
//        self._params = [:]
//    }
//    
//    public init(params:[Parameter]){
//        self._params = params.reduce([String:Parameter](), combine: { ( params, param) -> [String:Parameter] in
//            var params = params
//            params[param.key] = param
//            return params
//        })
//    }
//    
//    /// Create an instance initialized with `dictionary elements`.
//    public init(dictionary elements: [Key:Value]){
//        self = RequestParameters()
//        
//        elements.forEach {
//            self.addParamValue($0.1, forKey: $0.0)
//        }
//        
//    }
//    
//    public mutating func addParam(param:Parameter){
//        
//        if !self._params.keys.contains(param.key) {
//            self._params[param.key] = param
//        }
//    }
//    
//    public mutating func addParams(params:Parameter...){
//        for param in params {
//            self.addParam(param)
//        }
//    }
//    
//    public mutating func addParams(params:[Parameter]){
//        for param in params {
//            self.addParam(param)
//        }
//    }
//    
//    public mutating func addParams(params:RequestParameters){
//        for (_, param) in params._params {
//            self.addParam(param)
//        }
//    }
//    
//    public mutating func removeParam(forKey key:String)->Parameter? {
//        return self._params.removeValueForKey(key)
//    }
//    
//    public mutating func removeParam(forKeys keys:[String])->[Parameter] {
//        
//        let paramsArray = keys.reduce([], combine: { (array, key) -> [Parameter] in
//            var array = array
//            if let param = self._params.removeValueForKey(key) {
//                array.append(param)
//            }
//            return array
//        })
//        
//        return paramsArray
//    }
//    
//    public mutating func clearAllParams(){
//        self._params.removeAll(keepCapacity: false)
//    }
//    
//    internal func serialize(serializer: ParametersSerializer) -> NSData? {
//        return serializer.serialize(self)
//    }
//    
//}
//
//extension RequestParameters : ArrayLiteralConvertible {
//    public typealias Element = Parameter
//    
//    /// Create an instance initialized with `elements`.
//    public init(arrayLiteral elements: Element...){
//        self = RequestParameters(params: elements)
//    }
//}
//
//extension RequestParameters : DictionaryLiteralConvertible {
//    public typealias Key = String
//    public typealias Value = ParameterValueType
//    
//    /// Create an instance initialized with `elements`.
//    public init(dictionaryLiteral elements: (Key, Value)...){
//        self = []
//        
//        elements.forEach {
//            self.addParam(FormParameter(key: $0.0, value: $0.1))
//        }
//        
//    }
//    
//}
//

