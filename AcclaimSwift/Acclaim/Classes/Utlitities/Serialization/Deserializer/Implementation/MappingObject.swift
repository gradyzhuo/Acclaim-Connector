//
//  MappingObject.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/15/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Mappable:class {
    
    static var mappingTable:[String:String] { get }
    
    init()
}

public struct JSONMappingDeserializer<Outcome:Mappable> : Deserializer {
    internal var options: JSONSerialization.ReadingOptions
    
    public func deserialize(data: Data?) -> (outcome: Outcome?, error: NSError?) {
        
        func mappingObjectMake<T: Mappable>(dataObject: AnyObject!)->T {
            
            let mappingObject = T.init()
            
            for (key, value) in T.mappingTable{
                let ivar = class_getInstanceVariable(T.self, value)
                let newValue = dataObject[key]
                object_setIvar(mappingObject, ivar, newValue!)
            }
            
            return mappingObject
        }
        
        let result = JSONDeserializer(options: .allowFragments).deserialize(data: data)
        let outcome:Outcome = mappingObjectMake(dataObject: result.outcome)
        return (outcome, nil)
    }
    
    public init(){
        self.options = .allowFragments
    }
    
    public init(options: JSONSerialization.ReadingOptions){
        self.options = options
    }
}
