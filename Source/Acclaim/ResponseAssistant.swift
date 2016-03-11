//
//  ACOutputType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol _ResponseAssistantProtocol{
    func handle(data:NSData?, connection: Acclaim.Connection, error:ErrorType?)->(ErrorType?)
}

public protocol ResponseAssistantProtocol : _ResponseAssistantProtocol {
    
    associatedtype DeserializerType : ResponseDeserializer

    var deserializer: DeserializerType { set get }
    func handle(callback:DeserializerType.CallbackType)
}

extension ResponseAssistantProtocol {
    func test<T:ResponseAssistantProtocol>()->T?{
        return self as? T
    }
}


extension ResponseAssistantProtocol{
    
    public func handle(data: NSData?, connection: Acclaim.Connection, error: ErrorType?) -> (ErrorType?) {
        let result:(callback:DeserializerType.CallbackType?, error: ErrorType?) = self.deserializer.deserialize(data, connection: connection, connectionError: error)
        
        guard let callback = result.callback where result.error == nil else {
            return result.error
        }
        
        self.handle(callback)
        return error
    }
    
    
    
}

public class ResponseAssistant<DeserializerType : ResponseDeserializer> : ResponseAssistantProtocol {
    
    public typealias Handler = (result:DeserializerType.CallbackType)->Void
    
    public var deserializer: DeserializerType
    public internal(set) var handler : Handler?
    
    internal init(deserializer: DeserializerType = DeserializerType()){
        self.deserializer = deserializer
    }
    
    public init(deserializer: DeserializerType = DeserializerType(), handler: Handler){
        self.deserializer = deserializer
        self.handler = handler
    }
    
    public func handle(callback:DeserializerType.CallbackType) {
        self.handler?(result: callback)
    }
    
    deinit{
        ACDebugLog("Response(\(DeserializerType.self)) : [\(unsafeAddressOf(self))] deinit")
    }
}


public final class OriginalDataResponseAssistant:ResponseAssistant<OriginalDataResponseDeserializer>{
    public init(handler: Handler) {
        super.init(handler: handler)
    }
}

public final class HTTPResponseAssistant : ResponseAssistant<FailedResponseDeserializer>{
    public internal(set) var handlers:[Int : Handler] = [:]
    
    public init(statusCode:Int? = nil, handler: Handler) {
        super.init()
        
        if let statusCode = statusCode {
            self.handlers[statusCode] = handler
        }else{
            self.handler = handler
        }
    }
    
    
    public override func handle(callback: FailedResponseDeserializer.CallbackType) {
        let connection = callback.connection
        
        if let statusCode = connection.response?.statusCode where self.handlers.keys.contains(statusCode) {
            self.handlers[statusCode]?(result: callback)
        }else{
            self.handler?(result: callback)
        }
        
    }
    
}

public final class ImageResponseAssistant : ResponseAssistant<ImageResponseDeserializer>{
    public init(handler: Handler) {
        super.init(handler: handler)
    }
}

public final class TextResponseAssistant : ResponseAssistant<TextResponseDeserializer>{
    public init(encoding: NSStringEncoding = NSUTF8StringEncoding ,handler: Handler) {
        super.init(deserializer: TextResponseDeserializer(encoding: encoding), handler: handler)
    }
}
