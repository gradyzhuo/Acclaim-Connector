//
//  ACRequestParameters.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/15/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation


public class ACParameter : NSObject {
    public var key: String = ""
    
    internal func parameter()-> Parameter!{
        return nil
    }
}

@objc
public class ACFormDataParameter : ACParameter {
    public internal(set) var data: NSData = NSData()
    public internal(set) var fileName: String = ""
    public internal(set) var MIME: String = ""
    
    public init(key: String, data: NSData, fileName: String = "", MIME: String = ""){
        super.init()
        
        self.key = key
        self.data = data
        self.fileName = fileName
        self.MIME = MIME
    }
    
    public override func parameter() -> Parameter! {
        return FormDataParameter(key: self.key, data: self.data, fileName: self.fileName, MIME: self.MIME)
    }
}

@objc
public class ACFormStringParameter : ACParameter{
    public internal(set) var value: String = ""
    
    public init(key: String, value: String){
        super.init()
        
        self.key = key
        self.value = value
    }
    
    public override func parameter() -> Parameter! {
        return FormParameter.StringValue(key: self.key, value: self.value)
    }
}


@objc
public class ACFormDictionaryParameter : ACParameter{
    public internal(set) var value: [String:String] = [:]
    
    public init(key: String, value: [String:String]){
        super.init()
        
        self.key = key
        self.value = value
    }
    
    public override func parameter() -> Parameter {
        return FormParameter.DictionaryValue(key: self.key, value: self.value)
    }
}

@objc
public class ACFormArrayParameter : ACParameter{
    public internal(set) var value: [String] = []
    
    public init(key: String, value: [String]){
        super.init()
        
        self.key = key
        self.value = value
    }
    
    public override func parameter() -> Parameter {
        return FormParameter.ArrayValue(key: self.key, value: self.value)
    }
}


@objc
public class ACRequestParameters : NSObject{
    
    var params:[Parameter]
    
    public func requestParameters()->RequestParameters{
        var params = RequestParameters()
        for param in self.params {
            params.addParam(param)
        }
        return params
    }
    
    public override init(){
        self.params = []
    }
    
    internal func addParam(param:ACParameter){
        self.params.append(param.parameter())
    }
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of ParameterValueType.
     - forKey key: a string type value be the key.
     - returns: The new RequestParameter generated.
     */
    public func addFormParamStringValue(value: String, forKey key:String)->ACParameter{
        let param = ACFormStringParameter(key: key, value: value)
        self.addParam(param)
        return param
    }
    
    public func addFormParamIntegerValue(value: Int, forKey key:String)->ACParameter{
        let param = ACFormStringParameter(key: key, value: String(value))
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
    public func addDictionaryParamStringValue(value: [String:String], forKey key:String)->ACParameter{
        let param = ACFormDictionaryParameter(key: key, value: value)
        self.addParam(param)
        return param
    }
    
    public func addFormData(data: NSData?, forKey key: String, fileName: String = "", MIME: String = "")->ACParameter{
        
        let param = ACFormDataParameter(key: key, data: data ?? NSData(), fileName: fileName, MIME: MIME)
        
        self.addParam(param)
        return param
    }
    
}