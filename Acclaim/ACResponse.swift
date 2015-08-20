//
//  ACOutputType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias ACResponseIdentifier = String

public typealias ACResponseObjectHandler = (object : AnyObject?, response:NSURLResponse) -> Void
public typealias ACResponseDataHandler = (data : NSData?, response:NSURLResponse) -> Void
public typealias ACResponseTextHandler = (text : String?, response:NSURLResponse) -> Void
public typealias ACResponseImageHandler = (image : UIImage?, response:NSURLResponse) -> Void
public typealias ACResponseFailedHandler = (data : NSData?, response:NSURLResponse, error:NSError?) -> Void


public enum ACResponse : Equatable {
    case OriginalData(handler : ACResponseDataHandler)
    case Text(handler : ACResponseTextHandler)
    case JSON(handler : ACResponseObjectHandler)
    case Image(handler : ACResponseImageHandler)
    case Failed(handler : ACResponseFailedHandler)
    
    internal var core:ACResponseCore{
        switch self {

        case .OriginalData:
            return ACResponseCore.OriginalData
        case .Text:
            return ACResponseCore.Text
        case .JSON:
            return ACResponseCore.JSON
        case .Image:
            return ACResponseCore.Image
        case .Failed:
            return ACResponseCore.Failed
        }
    }
    
    internal func handle(data:NSData, response:NSURLResponse, error:NSError?)->Bool{
        
        let e:NSError?
        
        switch self{
        case .OriginalData(let handler):
            let object:ACOrialDataResponseDeserializer.DeserialType?
            (object, e) = ACOrialDataResponseDeserializer.deserialize(data)
            
            if e == nil {
                handler(data: object, response: response)
            }
            
        case .Text(let handler):
            let object:ACTextResponseDeserializer.DeserialType?
            (object, e) = ACTextResponseDeserializer.deserialize(data)
            
            if e == nil {
                handler(text: object, response: response)
            }
            
        case .JSON(let handler):
            let object:ACJSONResponseDeserializer.DeserialType?
            (object, e) = ACJSONResponseDeserializer.deserialize(data)
            
            if e == nil {
                handler(object: object, response: response)
            }
            
        case .Image(let handler):
            let object:ACImageResponseDeserializer.DeserialType?
            (object, e) = ACImageResponseDeserializer.deserialize(data)
            
            if e == nil {
                handler(image: object, response: response)
            }
            
        case .Failed(let handler):
            let object:ACFailedResponseDeserializer.DeserialType?
            (object, e) = ACFailedResponseDeserializer.deserialize(data)
            
            if e == nil {
                handler(data: object, response: response, error: error)
            }
        }
        
        if e != nil {
            ACDebugLog("deserialize error, reason: \(e?.debugDescription)")
            return false
        }
        
        return true
    }
    
    public var identifier:ACResponseIdentifier {
        return self.core.identifier
    }
    
}

public func ==(lhs: ACResponse, rhs:ACResponse) -> Bool {
    return lhs.identifier == rhs.identifier
}

public func ==(lhs: ACResponse, rhs:ACResponseIdentifier) -> Bool {
    return lhs.identifier == rhs
}

//MARK: - ACResponseCore
internal struct ACResponseCore {
    
    internal var identifier:ACResponseIdentifier
    
    internal static var OriginalData = ACResponseCore(identifier: "OriginalData")
    internal static var Text = ACResponseCore(identifier: "Text")
    internal static var JSON = ACResponseCore(identifier: "JSON")
    internal static var Image = ACResponseCore(identifier: "Image")
    internal static var Failed = ACResponseCore(identifier: "Failed")
}

extension ACResponseCore : Printable {
    
    internal var description:String {
        return self.identifier
    }
    
}

extension ACResponseCore : Hashable {
    
    var hashValue: Int {
        return self.identifier.hashValue
    }
    
}

extension ACResponseCore : Equatable { }
func ==(lhs: ACResponseCore, rhs: ACResponseCore)->Bool{
    return lhs.hashValue == rhs.hashValue
}
