//
//  ACSerialization.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation


public protocol Serializer {
    func serialize(object:ACRequestParams) -> NSData?

}

//FIXME: 未來可以加入錯誤的Key，要如何自已處理的方式。
public protocol Deserializer {
    typealias InstanceType
    typealias Handler = (Self.InstanceType?, NSURLResponse, ErrorType?)->Void
    
    static var identifier: String { get }
    static func deserialize(data:NSData) -> (Self.InstanceType?, ErrorType?)
    
}

typealias Serialization = protocol<Serializer, Deserializer>


public struct ACParamsJSONSerializer : Serializer {
    public var option: NSJSONWritingOptions
    
    public init(option: NSJSONWritingOptions = .PrettyPrinted){
        self.option = option
    }
    
    public func serialize(object: ACRequestParams) -> NSData? {
        return nil
    }
    
}


public struct ACParamsQueryStringSerializer : Serializer {

    public func serialize(object: ACRequestParams) -> NSData? {
        
        let components = NSURLComponents()
        
        components.queryItems = object.params.map { (element) -> NSURLQueryItem in
            return NSURLQueryItem(name: element.1.key, value: element.1.value as? String)
        }
        
        return components.query?.dataUsingEncoding(NSUTF8StringEncoding)
    }
}

public typealias OriginalData = ACOriginalDataResponseDeserializer
public struct ACOriginalDataResponseDeserializer : Deserializer{
    public static var identifier: String { return "OriginalData" }
    
    public typealias DeserialType = NSData
    public typealias Handler = (data : NSData?, response:NSURLResponse?, error:ErrorType?) -> Void
    
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
    
    public typealias Handler = (text : DeserialType?, response:NSURLResponse?, error:ErrorType?) -> Void
    
    public static func deserialize(data: NSData) -> (DeserialType?, ErrorType?) {
        let text : String? = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        return (text , nil)
    }
}

public typealias JSON = ACJSONResponseDeserializer
public struct ACJSONResponseDeserializer : Deserializer{
    public static var identifier: String { return "JSON" }
    public typealias DeserialType = AnyObject
    
    public typealias Handler = (JSONObject : DeserialType?, response:NSURLResponse?, error:ErrorType?) -> Void
    
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
    
    public typealias Handler = (image : DeserialType?, response:NSURLResponse?, error:ErrorType?) -> Void
    
    public static func deserialize(data: NSData) -> (DeserialType?, ErrorType?) {
        let image = UIImage(data: data)
        let error:NSError? = (image == nil) ? NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."]) : nil
        return (image, error)
    }
}



