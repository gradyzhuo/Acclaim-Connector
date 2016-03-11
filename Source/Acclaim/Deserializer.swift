//
//  Deserializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/1/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

//FIXME: 未來可以加入錯誤的Key，要如何自已處理的方式。
public protocol ResponseDeserializer {
    associatedtype CallbackType

    func deserialize(data:NSData?, connection: Acclaim.Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?)
    
    init()
}


public struct OriginalDataResponseDeserializer : ResponseDeserializer {
    public typealias CallbackType = (data : NSData, connection: Acclaim.Connection)

    public func deserialize(data: NSData?, connection: Acclaim.Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
        let callback = CallbackType(data: data ?? NSData(), connection: connection)
        return (callback, connectionError)
    }
    
    public init(){
        
    }
    
}

public struct FailedResponseDeserializer : ResponseDeserializer{
    public typealias CallbackType = (originalData : NSData?, connection: Acclaim.HTTPConnection, error:ErrorType?)

    public func deserialize(data: NSData?, connection: Acclaim.Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
        let callback = (originalData: data, connection: (request: connection.request, response: connection.response as? NSHTTPURLResponse), error: connectionError)
        return (callback, nil)
    }
    
    public init(){
        
    }
}

public struct TextResponseDeserializer : ResponseDeserializer{
    public typealias CallbackType = (text : String, connection: Acclaim.Connection)
    
    public var encoding:NSStringEncoding
    
    public func deserialize(data: NSData?, connection: Acclaim.Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
        guard let data = data else {
            return (nil, error: NSError(domain: "ACTextResponseDeserializer", code: 9, userInfo: [NSLocalizedFailureReasonErrorKey:"Original Data is nil."]))
        }
        
        guard let text : String = String(data: data , encoding: NSUTF8StringEncoding) else {
            return (nil, error: NSError(domain: "ACTextResponseDeserializer", code: 8, userInfo: [NSLocalizedFailureReasonErrorKey:"Can't convert data to string."]))
        }
        
        let callback = CallbackType(text: text, connection: connection)
        return (callback, nil)
    }
    
    public init(){
        self.encoding = NSUTF8StringEncoding
    }
    
    public init(encoding:NSStringEncoding){
        self.encoding = encoding
    }
}

public struct JSONResponseDeserializer : ResponseDeserializer, KeyPathParser{
    internal var options: NSJSONReadingOptions
    public typealias CallbackType = (JSONObject : AnyObject?, connection: Acclaim.Connection)
    public var keyPath:String?
    
    public func deserialize(data: NSData?, connection: Acclaim.Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {

        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: self.options)
            if let keyPath = keyPath {
                return ((JSONObject: self.parse(json, forKeyPath: keyPath), connection: connection), nil)
            }
            return ((JSONObject: json, connection: connection), nil)
        } catch let error as NSError {
            return (nil, error)
        }
        
    }
    
    public init() {
        self.options = .AllowFragments
    }
    
    public init(options: NSJSONReadingOptions){
        self.options = options
    }
    
    public init(keyPath:String, options: NSJSONReadingOptions){
        self.keyPath = keyPath
        self.options = options
    }
    
    
    
}

public struct ImageResponseDeserializer : ResponseDeserializer{
    public typealias CallbackType = (image : UIImage, connection: Acclaim.Connection)
    
    public func deserialize(data: NSData?, connection: Acclaim.Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
        guard let data = data else {
            return (nil, error: NSError(domain: "ACImageResponseDeserializer", code: 9, userInfo: [NSLocalizedFailureReasonErrorKey:"Original Data is nil."]))
        }
        
        guard let image = UIImage(data: data) else {
            let error = NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."])
            return (nil, error)
        }
        
        let callback = CallbackType(image: image, connection: connection)
        return (callback, nil)

    }
    
    public init(){
        
    }

}
