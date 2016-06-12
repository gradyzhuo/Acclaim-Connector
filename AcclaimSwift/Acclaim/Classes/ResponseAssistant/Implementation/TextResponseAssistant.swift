//
//  TextResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class TextResponseAssistant : ResponseAssistant{
    public typealias DeserializerType = TextDeserializer
    public typealias Handler = (text : TextDeserializer.Outcome, connection: Connection)->Void
    
    public var allowedMIMEs: [MIMEType] = [.Text]
    
    public var deserializer: DeserializerType = DeserializerType()
    
    public var handler : Handler?
    public var failedHandler: FailedHandler?
    
    public required init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public init(encoding: NSStringEncoding, handler: Handler) {
        self.deserializer = TextDeserializer(encoding: encoding)
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: NSError?) {
        
        let result = self.deserializer.deserialize(data: data)
        
        guard let text = result.outcome where result.error == nil else {
            self.failedHandler?(assistant: self, data: data, error: result.error)
            return
        }
        
        self.handler?(text : text, connection: connection)
    }
    
}


extension TextResponseAssistant : AssistantFailedHandleable {
    public typealias AssistantType = TextResponseAssistant
    public typealias FailedHandler = (assistant: AssistantType, data: NSData?, error: ErrorProtocol?)->Void
    
    public func failed(assistantHandler handler: FailedHandler) {
        self.failedHandler = handler
    }
    
}