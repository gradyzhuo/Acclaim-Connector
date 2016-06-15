//
//  MappingResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/15/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class
MappingResponseAssistant<MappingObject:Mappable> : ResponseAssistant{
    public typealias DeserializerType = JSONMappingDeserializer<MappingObject>
    public typealias Handler = (object : JSONMappingDeserializer<MappingObject>.Outcome, connection: Connection)->Void
    
    public var allowedMIMEs: [MIMEType] = [.Text]
    
    public var deserializer: DeserializerType = DeserializerType()
    
    public var handler : Handler?
    public var failedHandler: FailedHandler?
    
    public required init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public init(options: JSONSerialization.ReadingOptions, handler: Handler){
        self.deserializer = JSONMappingDeserializer<MappingObject>(options: options)
        self.handler = handler
    }
    
    public func handle(data: Data?, connection: Connection, error: NSError?) {
        
        let result = self.deserializer.deserialize(data: data)
        
        guard let mappingObject = result.outcome where result.error == nil else {
            self.failedHandler?(assistant: self, data: data, error: result.error)
            return
        }
        
        self.handler?(object : mappingObject, connection: connection)
    }
    
}

extension MappingResponseAssistant : AssistantFailedHandleable {
    public typealias AssistantType = MappingResponseAssistant
    public typealias FailedHandler = (assistant: AssistantType, data: Data?, error: ErrorProtocol?)->Void
    
    public func failed(assistantHandler handler: FailedHandler) {
        self.failedHandler = handler
    }
}
