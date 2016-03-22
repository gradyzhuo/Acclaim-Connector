//
//  ImageResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct ImageResponseAssistant : ResponseAssistant{
    
    public typealias DeserializerType = ImageDeserializer
    
    public typealias Handler = (image : ImageDeserializer.Outcome, connection: Connection)->Void
    
    public var deserializer: DeserializerType
    
    public internal(set) var handler : Handler?
    
    public init(deserializer: ImageDeserializer = ImageDeserializer(), handler: Handler){
        self.deserializer = deserializer
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: ErrorType?) -> (ErrorType?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let image = result.outcome where result.error == nil else {
            return result.error
        }
        
        self.handler?(image : image, connection: connection)
        return error
    }
    
}