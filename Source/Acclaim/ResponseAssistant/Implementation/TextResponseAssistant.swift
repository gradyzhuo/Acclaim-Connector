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
    
    public var deserializer: DeserializerType
    
    public internal(set) var handler : Handler?
    
    public init(deserializer: TextDeserializer = TextDeserializer(), handler: Handler){
        self.deserializer = deserializer
        self.handler = handler
    }
    
    public init(encoding: NSStringEncoding, handler: Handler) {
        self.deserializer = TextDeserializer(encoding: encoding)
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: ErrorType?) -> (ErrorType?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let image = result.outcome where result.error == nil else {
            return result.error
        }
        
        self.handler?(text : image, connection: connection)
        return error
    }
    
}
