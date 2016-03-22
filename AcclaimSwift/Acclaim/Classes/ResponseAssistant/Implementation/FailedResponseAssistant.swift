//
//  File.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct FailedResponseAssistant : ResponseAssistant{
    public typealias DeserializerType = DataDeserializer
    public typealias Handler = (originalData : DataDeserializer.Outcome?, connection: Connection, error: ErrorType?)->Void
    
    public var deserializer: DeserializerType
    
    public internal(set) var handler: Handler?
    public internal(set) var handlers:[Int : Handler] = [:]
    
    public init(statusCode:Int, deserializer: DataDeserializer = DataDeserializer(), handler: Handler) {
        self.handlers[statusCode] = handler
        self.deserializer = deserializer
    }
    
    public init(deserializer: DataDeserializer = DataDeserializer(), handler: Handler){
        self.deserializer = deserializer
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: ErrorType?) -> (ErrorType?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let data = result.outcome where result.error == nil else {
            return result.error
        }
        
        if let httpResponse = connection.response as? NSHTTPURLResponse, let handler = self.handlers[httpResponse.statusCode]{
            handler(originalData: data, connection: connection, error: error)
        }else{
            self.handler?(originalData: data, connection: connection, error: error)
        }
        
        return error
    }
    
}
