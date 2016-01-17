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
}

extension _ACResponse {
    
    func handle(data:NSData, URLResponse:NSURLResponse?, error:ErrorType?)->Bool{
        return false
    }
}

public typealias ACResponseIdentifier = String

public class Response<T : Deserializer> : _ACResponse {

    internal typealias DeserializerType = T
    
    let handler: DeserializerType.Handler
    
    public init(handler: DeserializerType.Handler){
        self.handler = handler
        
    }
    
    internal func handle(data:NSData, URLResponse:NSURLResponse?, error:ErrorType?)->Bool{
        
        guard let handler = self.handler as? (result: DeserializerType.InstanceType?, URLResponse: NSURLResponse?, error: ErrorType?)->Void else {
            fatalError("Deserializer.Handler must be a closure by the formal type : (result: DeserializerType.InstanceType?, URLResponse: NSURLResponse, error: ErrorType?).")
        }
        
        let result:DeserializerResultTuple = DeserializerType.deserialize(data)
        let error = result.error ?? error
        handler(result: result.item, URLResponse: URLResponse, error: error)
        
        if let e = result.error as? NSError {
            ACDebugLog("deserialize error, reason: \(e.debugDescription)")
            return false
        }
        
        return true
    }
    
    
    deinit{
        ACDebugLog("Response(\(T.identifier)) : [\(unsafeAddressOf(self))] deinit")
    }
    
}
