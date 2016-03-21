//
//  JSONDeserialier.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation


public struct JSONDeserializer : Deserializer, KeyPathParser{
    internal var options: NSJSONReadingOptions
    public typealias Outcome = AnyObject

    public func deserialize(data: NSData?) -> (outcome: Outcome?, error: ErrorType?) {
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: self.options)
            return (json, nil)
        } catch let error as NSError {
            return (nil, error)
        }
        
    }
    
    //TIP: Only that simply deserializing with keypath. This function will not be used by 'ResponseAssistant'.
    public func deserialize(data: NSData?, keyPath:KeyPath) -> (outcome: Outcome?, error: ErrorType?) {
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: self.options)
            let keyPathJSON:AnyObject? = JSONDeserializer.parse(json, forKeyPath: keyPath)
            return (keyPathJSON, nil)
            
        } catch let error as NSError {
            return (nil, error)
        }
        
    }
    
    
    public init(options: NSJSONReadingOptions){
        self.options = options
    }
    
}
