//
//  JSONParametersSerializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct JSONParametersSerializer : ParametersSerializer {
    public var option: JSONSerialization.WritingOptions
    
    public init(option: JSONSerialization.WritingOptions = .prettyPrinted){
        self.option = option
    }
    
    public func serialize(params: Parameters) -> Data? {
        
        var JSONObject = [String:AnyObject]()
        params.forEach {(parameter) -> Void in
            
            if let parameter = parameter as? FormParameter {
                switch parameter {
                case .stringValue(let key, let value):
                    JSONObject[key] = value
                case .arrayValue(let key, let arrayValue):
                    let value = arrayValue.map{ $0 }
                    JSONObject[key] = value
                case .dictionaryValue(let key, let dictionaryValue):
                    let value = dictionaryValue.reduce([String:AnyObject](), combine: { (dict, element:(key: String, value: String)) -> [String:AnyObject] in
                        var dictValue = dict
                        dictValue[element.key] = element.value
                        return dictValue
                    })
                    JSONObject[key] = value
                }
                
            }
            
        }
        
        
        return try? JSONSerialization.data(withJSONObject: JSONObject, options: self.option)
    }
    
}
