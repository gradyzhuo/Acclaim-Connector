//
//  ACSerialization.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

protocol Serializer {
    
    typealias SerialType
    typealias ValueType
    
    static func serialize(object:SerialType) -> ValueType?

}

protocol Deserializer {
    
    typealias DeserialType
    
    static func deserialize(data:NSData) -> (DeserialType?, NSError?)
    
}

typealias Serialization = protocol<Serializer, Deserializer>

//
class ACParamsSerializer : Serializer {
    
    typealias SerialType = ACRequestParam
    typealias ValueType = NSData
    
    class func serialize(object: SerialType) -> ValueType? {
        return nil
    }

}

class ACParamsJSONSerializer : ACParamsSerializer {
    
}


class ACParamsKeyValueSerializer : ACParamsSerializer {
    
}

//
class ACOrialDataResponseDeserializer : Deserializer{
    typealias DeserialType = NSData
    
    class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        return (data, nil)
    }

}

class ACFailedResponseDeserializer : ACOrialDataResponseDeserializer{
    
}

class ACTextResponseDeserializer : Deserializer{
    
    typealias DeserialType = String
    
    class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        let text : String? = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        return (text , nil)
    }
}

class ACJSONResponseDeserializer : Deserializer{
    
    typealias DeserialType = AnyObject
    
    class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        var error:NSError?
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &error)
        return (json, error)
    }
}

class ACImageResponseDeserializer : Deserializer{
    
    typealias DeserialType = UIImage
    
    class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        let image = UIImage(data: data)
        let error:NSError? = image == nil ? NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."]) : nil
        return (image, error)
    }
}



