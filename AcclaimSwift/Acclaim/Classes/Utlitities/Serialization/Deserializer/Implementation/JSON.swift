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

    public func deserialize(data: NSData?) -> (outcome: Outcome?, error: NSError?) {
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: self.options)
            return (json, nil)
        } catch let error as NSError {
            return (nil, error)
        }
        
    }
    
    //TIP: Only that simply deserializing with keypath. This function will not be used by 'ResponseAssistant'.
    public func deserialize(data: NSData?, keyPath:KeyPath) -> (outcome: Outcome?, error: NSError?) {
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: self.options)
            let keyPathJSON:AnyObject? = JSONDeserializer.parse(json, forKeyPath: keyPath)
            return (keyPathJSON, nil)
            
        } catch let error as NSError {
            return (nil, error)
        }
        
    }
    
    
    public init(){
        self.options = .AllowFragments
    }
    
    public init(options: NSJSONReadingOptions){
        self.options = options
    }
    
    public static func handle(command command: String, value: AnyObject?) -> AnyObject? {
        
        guard let value = value else{
            return 0
        }
        
        if command == "count" {
            if let items = value as? [AnyObject]  {
                return items.count
            }else if let dict = value as? [String:AnyObject] {
                return dict.count
            }else if let strValue = value as? String{
                return strValue.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            }
            return 1
        }
        
        if command == "keys" {
            if let dict = value as? [String:AnyObject] {
                return dict.keys.map{ $0 }
            }
        }
        
        if command == "indices" || command == "ranges" {
            if let items = value as? [AnyObject]  {
                return items.indices.description
            }else if let dict = value as? [String:AnyObject] {
                return dict.keys.map{ $0 }.indices.description
            }else if let strValue = value as? String{
                return (strValue.startIndex..<strValue.endIndex).description
            }else if let intValue = value as? Int {
                return (0..<intValue).description
            }
        }
        
        return nil
    }
    
}
