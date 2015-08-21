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
    typealias Handler = (result : DeserialType?, response:NSURLResponse, error: NSError?) -> Void
    
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
//public class ACResponseDeserializer : Deserializer{
//    public typealias DeserialType = AnyObject
//    
//    public class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
//        return (nil, nil)
//    }
//}

public typealias OriginalData = ACOriginalDataResponseDeserializer
public class ACOriginalDataResponseDeserializer : Deserializer{
    public typealias DeserialType = NSData
    public typealias Handler = (data : NSData?, response:NSURLResponse, error:NSError?) -> Void
    
    public class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        return (data, nil)
    }

}

public typealias Failed = ACFailedResponseDeserializer
public class ACFailedResponseDeserializer : ACOriginalDataResponseDeserializer{
}

public typealias Text = ACTextResponseDeserializer
public class ACTextResponseDeserializer : Deserializer{
    public typealias DeserialType = String
    
    public typealias Handler = (text : DeserialType?, response:NSURLResponse, error:NSError?) -> Void
    
    public class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        let text : String? = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        return (text , nil)
    }
}

public typealias JSON = ACJSONResponseDeserializer
public class ACJSONResponseDeserializer : Deserializer{
    public typealias DeserialType = AnyObject
    
    public typealias Handler = (JSONOjbect : DeserialType?, response:NSURLResponse, error:NSError?) -> Void
    
    public class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        var error:NSError?
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &error)
        return (json, error)
    }
}

public typealias Image = ACImageResponseDeserializer
public class ACImageResponseDeserializer : Deserializer{
    
    public typealias DeserialType = UIImage
    
    public typealias Handler = (image : DeserialType?, response:NSURLResponse, error:NSError?) -> Void
    
    public class func deserialize(data: NSData) -> (DeserialType?, NSError?) {
        let image = UIImage(data: data)
        let error:NSError? = image == nil ? NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."]) : nil
        return (image, error)
    }
}



