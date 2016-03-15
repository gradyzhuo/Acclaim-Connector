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
    case MultipartForm
    case Custom(serializer: ParametersSerializer)
    
    internal var serializer: ParametersSerializer {
        
        switch self {
        case let .JSON(option):
            return JSONParametersSerializer(option: option)
        case .QueryString:
            return QueryStringParametersSerializer()
        case .MultipartForm:
            return MultipartFormSerializer()
        case let .Custom(serializer):
            return serializer
        }
        
    }
    
    
}


public protocol ParametersSerializer {
    func serialize(params:RequestParameters) -> NSData?
}


public struct MultipartFormSerializer: ParametersSerializer {
    
    let boundary = "-----\(NSDate().timeIntervalSince1970)"
    
    public func serialize(params: RequestParameters) -> NSData? {
        
        let data = NSMutableData()
        
        //URLEncoding add case '+' to encode.
        let chars = NSCharacterSet.URLPathAllowedCharacterSet().mutableCopy().invertedSet as! NSMutableCharacterSet
        chars.addCharactersInString("+")
        chars.invert()
        
        params.params.forEach { (key, parameter) in
            
            data.appendData("--\(self.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())
            
            if let parameter = parameter as? FormParameter {
                
                switch parameter {
                case .StringValue(let key, let value):
                    
                    let encodedStringValue = value.stringByAddingPercentEncodingWithAllowedCharacters(chars) ?? ""
                    data.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData())
                    data.appendData("\(encodedStringValue)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())

                case .ArrayValue(let key, let arrayValue):
                    //Expend all array value
                    arrayValue.forEach({ (value) in
                        
                        let encodedStringValue = value.stringByAddingPercentEncodingWithAllowedCharacters(chars) ?? ""
                        data.appendData("Content-Disposition: form-data; name=\"\(key)[]\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData())
                        data.appendData("\(encodedStringValue)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())
                        
                    })

                case .DictionaryValue(let key, let dictionaryValue):
                    
                    dictionaryValue.forEach({ (elementKey, value) in
                        let encodedStringValue = value.stringByAddingPercentEncodingWithAllowedCharacters(chars) ?? ""
                        data.appendData("Content-Disposition: form-data; name=\"\(key)[\(elementKey)]\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData())
                        data.appendData("\(encodedStringValue)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())
                    })
                    
                }
                
            }else if let parameter = parameter as? FormDataParameter{
                
                data.appendData("Content-Disposition: form-data; name=\"\(parameter.key)\"; filename=\"\(parameter.fileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())
                data.appendData("Content-Type: \(parameter.MIME)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())
                data.appendData(parameter.data)
                data.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())
                
            }
            
            data.appendData("--\(self.boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) ?? NSData())
        }
        
        return data.copy() as? NSData
    }
    
}

public struct JSONParametersSerializer : ParametersSerializer {
    public var option: NSJSONWritingOptions
    
    public init(option: NSJSONWritingOptions = .PrettyPrinted){
        self.option = option
    }
    
    public func serialize(params: RequestParameters) -> NSData? {

        var JSONObject = [String:AnyObject]()
        params.params.forEach {(_, parameter) -> Void in
            
            if let parameter = parameter as? FormParameter {
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
            
        }
        
        
        return try? NSJSONSerialization.dataWithJSONObject(JSONObject, options: self.option)
    }
    
}


public struct QueryStringParametersSerializer : ParametersSerializer {

    public func serialize(params: RequestParameters) -> NSData? {
        
        let components = NSURLComponents()
        components.queryItems = [NSURLQueryItem]()
        
        params.params.forEach {(_, parameter) -> Void in
            
            if let parameter = parameter as? FormParameter {
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
            
            
        }
        
        let query:String? = components.query
        
        return query?.dataUsingEncoding(NSUTF8StringEncoding)
    }
}




