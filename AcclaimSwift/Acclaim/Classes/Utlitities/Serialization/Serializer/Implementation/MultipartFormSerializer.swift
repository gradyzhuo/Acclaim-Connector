//
//  MultipartFormSerializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct MultipartFormSerializer: ParametersSerializer {
    
    let boundary = "-----\(NSDate().timeIntervalSince1970)"
    
    public func serialize(params: Parameters) -> NSData? {
        
        let data = NSMutableData()
        
        //URLEncoding add case '+' to encode.
        let chars = NSCharacterSet.URLPathAllowedCharacterSet().mutableCopy().invertedSet as! NSMutableCharacterSet
        chars.addCharactersInString("+")
        chars.invert()
        
        params.forEach { (parameter) in
            
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
