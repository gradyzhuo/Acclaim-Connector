//
//  File.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct FailedResponseAssistant<DeserializerType:Deserializer> : ResponseAssistant{
    public typealias Handler = (outcome : DeserializerType.Outcome?, connection: Connection, error: NSError?)->Void
    
    public var allowedMIMEs: [MIMEType] = [.All]
    
    public var deserializer : DeserializerType = DeserializerType()
    
    public var handler: Handler?
    public internal(set) var handlers:[Int : Handler] = [:]
    
    public init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: NSError?) {
        
        let result = self.deserializer.deserialize(data)
        
        if let handler = self.handler {
            handler(outcome: result.outcome, connection: connection, error: error)
        }
        
        if let httpResponse = connection.response as? NSHTTPURLResponse,
            let handler = self.handlers[httpResponse.statusCode]{
            handler(outcome: result.outcome, connection: connection, error: error)
        }
        
    }
    
    public mutating func addHandler(forStatusCode statusCode: Int, handler: Handler)->FailedResponseAssistant{
        self.handlers[statusCode] = handler
        return self
    }
    
}
