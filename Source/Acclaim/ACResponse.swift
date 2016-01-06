//
//  ACOutputType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

internal protocol _Response {
    func handle(data:NSData, URLResponse:NSURLResponse, error:ErrorType?)->Bool
}

internal protocol _ACAPIResponse : _Response {
    typealias DeserializerType : Deserializer
}

extension _ACAPIResponse {
    func handle(data:NSData, URLResponse:NSURLResponse, error:ErrorType?)->Bool{
        return false
    }
}

public typealias ACResponseIdentifier = String

public struct Response<T : Deserializer> : _ACAPIResponse {
    
    public typealias DeserializerType = T
    
    let handler: DeserializerType.Handler
    
    public init(handler: DeserializerType.Handler){
        self.handler = handler
    }
    
    internal func handle(data:NSData, URLResponse:NSURLResponse, error:ErrorType?)->Bool{
        
        guard let handler = self.handler as? (result: DeserializerType.DeserialType?, URLResponse: NSURLResponse, error: ErrorType?)->Void else {
            return false
        }
        
        let (object, e) = DeserializerType.deserialize(data)
        handler(result: object, URLResponse: URLResponse, error: e)
        
        if let e = e as? NSError {
            ACDebugLog("deserialize error, reason: \(e.debugDescription)")
            return false
        }
        
        return true
    }
    
}
