//
//  ImageResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class ImageResponseAssistant : ResponseAssistant{
    public typealias DeserializerType = ImageDeserializer
    
    public var allowedMIMEs: [MIMEType] = [.Image]
    
    public typealias Handler = (image : ImageDeserializer.Outcome, connection: Connection)->Void
    
    public var deserializer: DeserializerType
    
    public var failedHandler: FailedHandler?
    public var handler : Handler?
    
    public required init(handler: Handler? = nil){
        self.handler = handler
        self.deserializer = DeserializerType()
    }
    
    public init(scale: CGFloat, handler: Handler? = nil){
        self.handler = handler
        self.deserializer = DeserializerType(scale: scale)
    }
    
    public func handle(data: NSData?, connection: Connection, error: NSError?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let image = result.outcome where result.error == nil else {
            self.failedHandler?(assistant: self, data: data, error: error)
            return
        }
        
        self.handler?(image : image, connection: connection)
    }
    
}

extension ImageResponseAssistant : AssistantFailedHandleable{
    public typealias AssistantType = ImageResponseAssistant
    public typealias FailedHandler = (assistant: AssistantType, data: NSData?, error: ErrorType?)->Void
    
    public func failed(assistantHandler failedHandler: FailedHandler) {
        self.failedHandler = failedHandler
    }
}