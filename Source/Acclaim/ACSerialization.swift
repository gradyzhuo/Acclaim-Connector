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
    typealias Handler = (result: Self.InstanceType?, error: ErrorType?)->Void
    
    static var identifier: String { get }
    
    func deserialize(data:NSData, URLResponse: NSURLResponse?, connectionError: ErrorType?) -> (Self.InstanceType?, ErrorType?)
    
    init()
}

extension Deserializer {
    
    internal func handle(result: Self.InstanceType?, error: ErrorType?)->(handler: Self.Handler)->Void{
        return {(handler: Self.Handler)->Void in
            
            guard let handler = handler as? (result: Self.InstanceType?, error: ErrorType?)->Void else {
                fatalError("Deserializer.Handler must be a closure by the formal type : (result: DeserializerType.InstanceType?, URLResponse: NSURLResponse, error: ErrorType?).")
            }
            
            handler(result: result, error: error)
        }
    }
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
public struct ACOriginalDataResponseDeserializer : Deserializer {
    public static var identifier: String { return "OriginalData" }
    
    public typealias InstanceType = NSData
    public typealias Handler = (data : NSData?, error:ErrorType?) -> Void
    
    public func deserialize(data: NSData, URLResponse: NSURLResponse?, connectionError: ErrorType?) -> (InstanceType?, ErrorType?) {
        return (data, nil)
    }
    
    public init(){
        
    }

}

public typealias Failed = ACFailedResponseDeserializer
public struct ACFailedResponseDeserializer : Deserializer{
    
    public static var identifier: String { return "Failed" }
    
    public typealias InstanceType = NSData
    public typealias Handler = (data : NSData?, error:ErrorType?) -> Void
    
    public func deserialize(data: NSData, URLResponse: NSURLResponse?, connectionError: ErrorType?) -> (InstanceType?, ErrorType?) {
        return (data, nil)
    }
    
    public init(){
        
    }
}

public typealias Text = ACTextResponseDeserializer
public struct ACTextResponseDeserializer : Deserializer{
    
    public static var identifier: String { return "Text" }
    
    public typealias InstanceType = String
    
    public typealias Handler = (text : InstanceType?, error:ErrorType?) -> Void
    
    public func deserialize(data: NSData, URLResponse: NSURLResponse?, connectionError: ErrorType?) -> (InstanceType?, ErrorType?) {
        let text : String? = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        return (text , nil)
    }
    
    public init(){
        
    }
}

public typealias JSON = ACJSONResponseDeserializer
public struct ACJSONResponseDeserializer : Deserializer{
    internal var options: NSJSONReadingOptions
    
    public static var identifier: String { return "JSON" }
    public typealias InstanceType = AnyObject
    
    public typealias Handler = (JSONObject : InstanceType?, error:ErrorType?) -> Void
    
    public func deserialize(data: NSData, URLResponse: NSURLResponse?, connectionError: ErrorType?) -> (InstanceType?, ErrorType?) {
        var error:ErrorType?
        let json: AnyObject?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: self.options)
        } catch let error1 as NSError {
            error = error1
            json = nil
        }
        return (json, error)
    }
    
    public init() {
        self.options = .AllowFragments
    }
    
    public init(options: NSJSONReadingOptions){
        self.options = options
    }
}

public typealias Image = ACImageResponseDeserializer
public struct ACImageResponseDeserializer : Deserializer{
    public static var identifier: String { return "Image" }
    public typealias InstanceType = UIImage
    
    public typealias Handler = (image : InstanceType?, error:ErrorType?) -> Void
    
    public func deserialize(data: NSData, URLResponse: NSURLResponse?, connectionError: ErrorType?) -> (InstanceType?, ErrorType?) {
        let image = UIImage(data: data)
        let error:NSError? = (image == nil) ? NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."]) : nil
        return (image, error)
    }
    
    public init(){
        
    }
}



