//
//  MultipartFormSerializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct MultipartFormSerializer: ParametersSerializer {
    
    let boundary = "-----\(Date().timeIntervalSince1970)"
    
    public func serialize(params: Parameters) -> Data? {
        
        let data = NSMutableData()
        
        //URLEncoding add case '+' to encode.
        
        var chars = CharacterSet.urlHostAllowed.inverted
        chars.insert(charactersIn: "+")
        chars.invert()
        
        params.forEach { (parameter) in
            
            data.append("--\(self.boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
            
            if let parameter = parameter as? FormParameter {
                
                switch parameter {
                case .stringValue(let key, let value):
                    
                    let encodedStringValue = value.addingPercentEncoding(withAllowedCharacters: chars) ?? ""
                    data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data())
                    data.append("\(encodedStringValue)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
                    
                case .arrayValue(let key, let arrayValue):
                    //Expend all array value
                    arrayValue.forEach({ (value) in
                        
                        let encodedStringValue = value.addingPercentEncoding(withAllowedCharacters: chars) ?? ""
                        data.append("Content-Disposition: form-data; name=\"\(key)[]\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data())
                        data.append("\(encodedStringValue)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
                        
                    })
                    
                case .dictionaryValue(let key, let dictionaryValue):
                    
                    dictionaryValue.forEach({ (elementKey, value) in
                        let encodedStringValue = value.addingPercentEncoding(withAllowedCharacters: chars) ?? ""
                        data.append("Content-Disposition: form-data; name=\"\(key)[\(elementKey)]\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data())
                        data.append("\(encodedStringValue)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
                    })
                    
                }
                
            }else if let parameter = parameter as? FormDataParameter{
                
                data.append("Content-Disposition: form-data; name=\"\(parameter.key)\"; filename=\"\(parameter.fileName)\"\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
                data.append("Content-Type: \(parameter.MIME)\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
                data.append(parameter.data as Data)
                data.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
                
            }
            
            data.append("--\(self.boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true) ?? Data())
        }
        
        return data.copy() as? Data
    }
    
}
