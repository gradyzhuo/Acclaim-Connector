//
//  OriginalDataResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct OriginalDataResponseAssistant : ResponseAssistant {
    public typealias DeserializerType = DataDeserializer
    
    public typealias Handler = (data : DataDeserializer.Outcome?, connection: Connection)->Void
    
    public var deserializer: DeserializerType
    
    public internal(set) var handler : Handler?
    
    public init(deserializer: DataDeserializer = DataDeserializer(), handler: Handler){
        self.deserializer = deserializer
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: ErrorType?) -> (ErrorType?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let data = result.outcome where result.error == nil else {
            return result.error
        }
        
        self.handler?(data : data, connection: connection)
        
        return error
    }
    
}