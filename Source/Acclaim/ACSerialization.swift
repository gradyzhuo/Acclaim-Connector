//
//  ACSerialization.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Serializer {
    
    typealias SerialType
    typealias ValueType
    
    static func serialize(object:SerialType) -> ValueType?

}

public protocol Deserializer {
    typealias DeserialType
    typealias Handler = (DeserialType?, NSURLResponse, ErrorType?)->Void
    
    static var identifier: String { get }
    static func deserialize(data:NSData) -> (DeserialType?, ErrorType?)
    
}


typealias Serialization = protocol<Serializer, Deserializer>

struct ACParamsJSONSerializer : Serializer {
    
    typealias SerialType = ACRequestParam
    typealias ValueType = NSData
    
    static func serialize(object: SerialType) -> ValueType? {
        return nil
    }
    
    static func serialize(object: SerialType, option: NSJSONWritingOptions = .PrettyPrinted) -> ValueType? {
        return nil
    }
}


struct ACParamsKeyValueSerializer : Serializer {
    typealias SerialType = ACRequestParam
    typealias ValueType = NSData
    
    static func serialize(object: SerialType) -> ValueType? {
        return nil
    }
}

public typealias OriginalData = ACOriginalDataResponseDeserializer
public struct ACOriginalDataResponseDeserializer : Deserializer{
    public static var identifier: String { return "OriginalData" }
    
    public typealias DeserialType = NSData
    public typealias Handler = (data : NSData?, response:NSURLResponse, error:ErrorType?) -> Void
    
    public static func deserialize(data: NSData) -> (DeserialType?, ErrorType?) {
        return (data, nil)
    }

}

public typealias Failed = ACFailedResponseDeserializer
public struct ACFailedResponseDeserializer : Deserializer{
    
    public static var identifier: String { return "OriginalData" }
    
    public typealias DeserialType = NSData
    public typealias Handler = (data : NSData?, response:NSURLResponse, error:ErrorType?) -> Void
    
    public static func deserialize(data: NSData) -> (DeserialType?, ErrorType?) {
        return (data, nil)
    }
    
}

public typealias Text = ACTextResponseDeserializer
public struct ACTextResponseDeserializer : Deserializer{
    
    public static var identifier: String { return "Text" }
    
    public typealias DeserialType = String
    
    public typealias Handler = (text : DeserialType?, response:NSURLResponse, error:ErrorType?) -> Void
    
    public static func deserialize(data: NSData) -> (DeserialType?, ErrorType?) {
        let text : String? = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        return (text , nil)
    }
}

public typealias JSON = ACJSONResponseDeserializer
public struct ACJSONResponseDeserializer : Deserializer{
    public static var identifier: String { return "JSON" }
    public typealias DeserialType = AnyObject
    
    public typealias Handler = (JSONObject : DeserialType?, response:NSURLResponse, error:ErrorType?) -> Void
    
    public static func deserialize(data: NSData) -> (DeserialType?, ErrorType?) {
        var error:ErrorType?
        let json: AnyObject?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
        } catch let error1 as NSError {
            error = error1
            json = nil
        }
        return (json, error)
    }
}

public typealias Image = ACImageResponseDeserializer
public struct ACImageResponseDeserializer : Deserializer{
    public static var identifier: String { return "Image" }
    public typealias DeserialType = UIImage
    
    public typealias Handler = (image : DeserialType?, response:NSURLResponse, error:ErrorType?) -> Void
    
    public static func deserialize(data: NSData) -> (DeserialType?, ErrorType?) {
        let image = UIImage(data: data)
        let error:NSError? = (image == nil) ? NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."]) : nil
        return (image, error)
    }
}



