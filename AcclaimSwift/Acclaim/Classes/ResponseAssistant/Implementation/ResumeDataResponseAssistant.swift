//
//  ResumeDataResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct ResumeDataResponseAssistant:ResponseAssistant{
    public typealias DeserializerType = DataDeserializer
    
    public typealias Handler = (resumeData : DataDeserializer.Outcome?, connection: Connection)->Void
    
    public var allowedMIMEs: [MIMEType] = [.All]
    
    public var deserializer: DeserializerType = DataDeserializer()
    
    public var handler : Handler?
    
    public init(handler: Handler? = nil){
        self.handler = handler
    }
    
    public func handle(data: NSData?, connection: Connection, error: ErrorType?) -> (ErrorType?) {
        
        let result = self.deserializer.deserialize(data)
        
        guard let data = result.outcome where result.error == nil else {
            return result.error
        }
        
        self.handler?(resumeData : data, connection: connection)
        return error
    }
    
}
