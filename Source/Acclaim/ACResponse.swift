//
//  ACOutputType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

internal protocol _Response {
    func handle(data:NSData, URLResponse:NSURLResponse?, error:ErrorType?)->Bool
}

internal protocol _ACResponse : _Response {
    typealias DeserializerResultTuple = (item:DeserializerType.InstanceType?, error: ErrorType?)
    
    typealias DeserializerType : Deserializer
    
    var deserializer: DeserializerType { set get }
}

extension _ACResponse {
    
    func handle(data:NSData, URLResponse:NSURLResponse?, error:ErrorType?)->Bool{
        return false
    }
}

public class Response<DeserializerType : Deserializer> : _ACResponse {
    
    internal var deserializer: DeserializerType
    
    let handler: DeserializerType.Handler
    
    public init(deserializer: DeserializerType, handler: DeserializerType.Handler){
        self.handler = handler
        self.deserializer = deserializer
    }
    
    internal func handle(data:NSData, URLResponse:NSURLResponse?, error:ErrorType?)->Bool{
        
        let result:DeserializerResultTuple = self.deserializer.deserialize(data, URLResponse: URLResponse, connectionError: error)
        let error = result.error ?? error
        self.deserializer.handle(result.item, error: error)(handler: self.handler)
        
        if let e = result.error as? NSError {
            ACDebugLog("deserialize error, reason: \(e.debugDescription)")
            return false
        }
        
        return true
    }
    
    
    deinit{
        ACDebugLog("Response(\(DeserializerType.identifier)) : [\(unsafeAddressOf(self))] deinit")
    }
    
}
