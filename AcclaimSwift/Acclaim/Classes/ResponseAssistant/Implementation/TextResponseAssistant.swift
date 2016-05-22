//
//  TextResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct TextResponseAssistant : ResponseAssistant{
    public typealias DeserializerType = TextDeserializer
    public typealias Handler = (text : TextDeserializer.Outcome, connection: Connection)->Void
    
    public var allowedMIMEs: [MIMEType] = [.Text]
    
    public var deserializer: DeserializerType = DeserializerType()
    
    public var handler : Handler?
    
    public init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public init(encoding: NSStringEncoding, handler: Handler) {
        self.deserializer = TextDeserializer(encoding: encoding)
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: NSError?) -> (NSError?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let text = result.outcome where result.error == nil else {
            return result.error
        }
        
        self.handler?(text : text, connection: connection)
        return error
    }
    
}
