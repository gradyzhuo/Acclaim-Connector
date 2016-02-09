//
//  KeyPathResponseAssistant.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class KeyPathResponseAssistant<DeserializerType : ResponseDeserializer> : ResponseAssistant<DeserializerType>, KeyPathParser {
    public internal(set) var handlers:[String : Handler] = [:]
    
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
        ACDebugLog("KeyPathResponseAssistant(\(DeserializerType.self)) : [\(unsafeAddressOf(self))] deinit")
    }
}

public final class JSONResponseAssistant : KeyPathResponseAssistant<JSONResponseDeserializer> {
    
    public init(forKeyPath keyPath:String? = nil, option: NSJSONReadingOptions = NSJSONReadingOptions.AllowFragments, handler: Handler) {
        super.init(forKeyPath: keyPath, deserializer: JSONResponseDeserializer(options: option), handler: handler)
    }
    
    public override func handle(callback: JSONResponseDeserializer.CallbackType) {
        super.handle(callback)
        
        for (keyPath, handler) in handlers {
            handler(result: (JSONObject: self.parse(callback.JSONObject, forKeyPath: keyPath), connection: callback.connection))
        }
    }
    
    
}
