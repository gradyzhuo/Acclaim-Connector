//
//  MappingResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/15/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct MappingResponseAssistant<MappingObject:Mappable> : ResponseAssistant{
    public typealias DeserializerType = JSONMappingDeserializer<MappingObject>
    public typealias Handler = (object : JSONMappingDeserializer<MappingObject>.Outcome, connection: Connection)->Void
    
    public var allowedMIMEs: [MIMEType] = [.Text]
    
    public var deserializer: DeserializerType = DeserializerType()
    
    public var handler : Handler?
    
    public init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public init(options: NSJSONReadingOptions, handler: Handler){
        self.deserializer = JSONMappingDeserializer<MappingObject>(options: options)
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: NSError?) -> (NSError?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let mappingObject = result.outcome where result.error == nil else {
            return result.error
        }
        
        self.handler?(object : mappingObject, connection: connection)
        return error
    }
    
}
