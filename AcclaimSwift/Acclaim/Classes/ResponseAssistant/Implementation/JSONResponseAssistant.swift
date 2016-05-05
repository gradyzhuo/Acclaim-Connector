//
//  JSONResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct JSONResponseAssistant : ResponseAssistant{
    public typealias DeserializerType = JSONDeserializer
    public typealias Handler = (JSONObject : JSONDeserializer.Outcome?, connection: Connection)->Void
    
    public var deserializer: DeserializerType = DeserializerType(options: .AllowFragments)
    
    public internal(set) var handlers:[KeyPath : Handler] = [:]
    public var handler : Handler?
    
    public init(forKeyPath keyPath:KeyPath, options: NSJSONReadingOptions = NSJSONReadingOptions.AllowFragments, handler: Handler) {
        
        self.deserializer = JSONDeserializer(options: options)
        self.addHandler(forKeyPath: keyPath, handler: handler)
        
    }
    
    public init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public init(options: NSJSONReadingOptions, handler: Handler){
        self.deserializer = JSONDeserializer(options: options)
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: ErrorType?) -> (ErrorType?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let JSON = result.outcome where result.error == nil else {
            return result.error
        }
        
        self.handler?(JSONObject : JSON, connection: connection)

        for (keyPath, handler) in handlers {
            handler(JSONObject: JSONDeserializer.parse(JSON, forKeyPath: keyPath), connection: connection)
        }
        
        return error
    }
    
    public mutating func addHandler(forKeyPath keyPath: KeyPath, handler: Handler)->JSONResponseAssistant{
        self.handlers[keyPath] = handler
        return self
    }
    
}
