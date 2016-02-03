//
//  ACOutputType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol _ResponseAssistantProtocol{
    func handle(data:NSData?, connection: Connection, error:ErrorType?)->(ErrorType?)
}

public protocol ResponseAssistantProtocol : _ResponseAssistantProtocol {
    
    typealias DeserializerType : Deserializer

    var deserializer: DeserializerType { set get }
    func handle(callback:DeserializerType.CallbackType)
}

extension ResponseAssistantProtocol {
    func test<T:ResponseAssistantProtocol>()->T?{
        return self as? T
    }
}


extension ResponseAssistantProtocol{
    
    public func handle(data: NSData?, connection: Connection, error: ErrorType?) -> (ErrorType?) {
        let result:(callback:DeserializerType.CallbackType?, error: ErrorType?) = self.deserializer.deserialize(data, connection: connection, connectionError: error)
        
        guard let callback = result.callback where result.error == nil else {
            return result.error
        }
        
        self.handle(callback)
        return error
    }
    
    
    
}

public class ResponseAssistant<DeserializerType : Deserializer> : ResponseAssistantProtocol {
    
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
        ACDebugLog("Response(\(DeserializerType.identifier)) : [\(unsafeAddressOf(self))] deinit")
    }
}

public class KeyPathResponseAssistant<DeserializerType : Deserializer> : ResponseAssistant<DeserializerType> {
    public typealias Handler = (result:DeserializerType.CallbackType)->Void
    
    public internal(set) var handlers:[String : Handler] = [:]
    
    public override init(deserializer: DeserializerType = DeserializerType()){
        super.init(deserializer: deserializer)
    }

    public init(forKeyPath keyPath:String? = nil, deserializer: DeserializerType = DeserializerType(), handler: Handler) {
        super.init(deserializer: deserializer)
        
        if let keyPath = keyPath {
            self.handlers[keyPath] = handler
        }else{
            self.handler = handler
        }
        
    }
    
    public func addHandler(forKeyPath keyPath: String, handler: Handler)->KeyPathResponseAssistant<DeserializerType>{
        self.handlers[keyPath] = handler
        return self
    }
    
    deinit{
        ACDebugLog("KeyPathResponseAssistant(\(DeserializerType.identifier)) : [\(unsafeAddressOf(self))] deinit")
    }
}

//public enum ResponseAssistantType {
//    case OriginalData(handler: (data: NSData, connection: Connection)->Void)
//    case JSON(keyPath: String, option: NSJSONReadingOptions, handler: (JSONObject: AnyObject?, connection: Connection)->Void)
//    case Image(handler: (image: UIImage, connection: Connection)->Void)
//    case Text(handler: (text: String, connection: Connection)->Void)
//
//    public func responseAssistant<T:Deserializer>(deserializer: T)->ResponseAssistant<T> {
//        return ResponseAssistant<T>(deserializer: deserializer)
//    }
//}

public final class OriginalDataResponseAssistant:ResponseAssistant<OriginalDataResponseDeserializer>{
    public init(handler: Handler) {
        super.init(handler: handler)
    }
}

public final class FailedResponseAssistant : ResponseAssistant<FailedResponseDeserializer>{
    public init(handler: Handler) {
        super.init(handler: handler)
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

public final class JSONResponseAssistant : KeyPathResponseAssistant<JSONResponseDeserializer> {
    
    public init(forKeyPath keyPath:String? = nil, option: NSJSONReadingOptions = NSJSONReadingOptions.AllowFragments, handler: Handler) {
        super.init(forKeyPath: keyPath, deserializer: JSONResponseDeserializer(options: option), handler: handler)
    }
    
    public override func handle(callback: JSONResponseDeserializer.CallbackType) {
        super.handle(callback)
        
        
        for (keyPath, handler) in handlers {
            handler(result: (JSONObject: callback.JSONObject?[keyPath], connection: callback.connection))
        }
    }

    
}
