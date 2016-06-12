//
//  JSONResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class JSONResponseAssistant : ResponseAssistant{
    public typealias DeserializerType = JSONDeserializer
    public typealias Handler = (JSONObject : JSONDeserializer.Outcome?, connection: Connection)->Void
    
    public var allowedMIMEs: [MIMEType] = [.All(subtype: "json"), .All(subtype: "plain")]
    
    public var deserializer: DeserializerType = DeserializerType(options: .allowFragments)
    
    public internal(set) var handlers:[KeyPath : Handler] = [:]
    public var handler : Handler?
    public var failedHandler : FailedHandler?
    
    public init(forKeyPath keyPath:KeyPath, options: NSJSONReadingOptions = NSJSONReadingOptions.allowFragments, handler: Handler) {
        
        self.deserializer = JSONDeserializer(options: options)
        _ = self.addHandler(forKeyPath: keyPath, handler: handler)
    }
    
    public required init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public init(options: NSJSONReadingOptions, handler: Handler? = nil){
        self.deserializer = JSONDeserializer(options: options)
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: NSError?) {
        
        let result = self.deserializer.deserialize(data: data)
        
        guard let JSON = result.outcome where result.error == nil else {
            self.failedHandler?(assistant: self, data: data, error: result.error)
            return
        }
        
        self.handler?(JSONObject : JSON, connection: connection)

        for (keyPath, handler) in handlers {
            handler(JSONObject: JSONDeserializer.parse(value: JSON, forKeyPath: keyPath), connection: connection)
        }
        
    }
    
    public func addHandler(forKeyPath keyPath: KeyPath, handler: Handler)->JSONResponseAssistant{
        self.handlers[keyPath] = handler
        return self
    }
    
}

extension JSONResponseAssistant : AssistantFailedHandleable {
    public typealias AssistantType = JSONResponseAssistant
    public typealias FailedHandler = (assistant: AssistantType, data: NSData?, error: ErrorProtocol?)->Void
    
    public func failed(assistantHandler handler: FailedHandler) {
        self.failedHandler = handler
    }
}
