//
//  Deserializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/1/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

//FIXME: 未來可以加入錯誤的Key，要如何自已處理的方式。
public protocol Deserializer {
    typealias CallbackType
    static var identifier: String { get }

    func deserialize(data:NSData?, connection: Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?)
    
    init()
}

//public protocol ModelDeserializer {
//    typealias CallbackType
//    static var identifier: String { get }
//    
//    func deserialize(data:[String:AnyObject], connection: Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?)
//    
//    init()
//}


public struct OriginalDataResponseDeserializer : Deserializer {
    public static var identifier: String { return "OriginalData" }
    public typealias CallbackType = (data : NSData, connection: Connection)

    public func deserialize(data: NSData?, connection: Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
        let callback = CallbackType(data: data ?? NSData(), connection: connection)
        return (callback, connectionError)
    }
    
    public init(){
        
    }
    
}

public struct FailedResponseDeserializer : Deserializer{
    public static var identifier: String { return "Failed" }
    public typealias CallbackType = (originalData : NSData?, connection: Connection, error:ErrorType?)

    public func deserialize(data: NSData?, connection: Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
        let callback = (originalData: data, connection: connection, error: connectionError)
        return (callback, nil)
    }
    
    
    public init(){
        
    }
}

public struct TextResponseDeserializer : Deserializer{
    
    public static var identifier: String { return "Text" }
    public typealias CallbackType = (text : String, connection: Connection)
    
    public var encoding:NSStringEncoding
    
    public func deserialize(data: NSData?, connection: Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
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

public struct JSONResponseDeserializer : Deserializer{
    internal var options: NSJSONReadingOptions
    public static var identifier: String { return "JSON" }
    public typealias CallbackType = (JSONObject : AnyObject?, connection: Connection)

    public func deserialize(data: NSData?, connection: Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {

        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data ?? NSData(), options: self.options)
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
    
}

public struct ImageResponseDeserializer : Deserializer{
    public static var identifier: String { return "Image" }
    public typealias CallbackType = (image : UIImage?, connection: Connection)
    
    public func deserialize(data: NSData?, connection: Connection, connectionError: ErrorType?) -> (CallbackType?, ErrorType?) {
        guard let data = data else {
            return (nil, error: NSError(domain: "ACImageResponseDeserializer", code: 9, userInfo: [NSLocalizedFailureReasonErrorKey:"Original Data is nil."]))
        }
        
        let image = UIImage(data: data )
        let error:NSError? = (image == nil) ? NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."]) : nil
        
        guard error == nil else {
            return (nil, error)
        }
        
        let callback = CallbackType(image: image, connection: connection)
        return (callback, nil)

    }
    
    public init(){
        
    }

}
