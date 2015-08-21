//
//  ACOutputType.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Response {
    var identifier:String { get }
    
    func handle(data:NSData, response:NSURLResponse, error:NSError?)->Bool
}

public typealias ACResponseIdentifier = String

public class ACResponse : Response {
    
    public var identifier:String{
        return ""
    }
    
    public func handle(data: NSData, response: NSURLResponse, error: NSError?) -> Bool {
        return false
    }
    
    public class func OriginalData(handler: ACOriginalDataResponseDeserializer.Handler)->ACResponse{
        let core = ACResponseCore<ACOriginalDataResponseDeserializer>(identifier: "OriginalData",  handler: handler)
        return ACOriginalDataResponse(core: core)
    }
    
    public class func Text(handler: ACTextResponseDeserializer.Handler)->ACResponse{
        let core = ACResponseCore<ACTextResponseDeserializer>(identifier: "JSON",  handler: handler)
        return ACTextResponse(core: core)
    }
    
    public class func JSON(handler: ACJSONResponseDeserializer.Handler)->ACResponse{
        let core = ACResponseCore<ACJSONResponseDeserializer>(identifier: "JSON",  handler: handler)
        return ACJSONResponse(core: core)
    }
    
    public class func Image(handler: ACImageResponseDeserializer.Handler)->ACResponse{
        let core = ACResponseCore<ACImageResponseDeserializer>(identifier: "Image",  handler: handler)
        return ACImageResponse(core: core)
    }
    
    public class func Failed(handler: ACFailedResponseDeserializer.Handler)->ACResponse{
        let core = ACResponseCore<ACFailedResponseDeserializer>(identifier: "Failed",  handler: handler)
        return ACFailedResponse(core: core)
    }
    
}

struct ACResponseCore<T:Deserializer> : Response{
    
    typealias Handler = (result : T.DeserialType?, response:NSURLResponse, error: NSError?) -> Void
    
    let identifier:String
    let deserialier: T.Type
    let handler: Handler
    
    init(identifier:String, handler: Handler){
        self.identifier = identifier
        self.deserialier = T.self
        self.handler = handler
    }
    
    internal func handle(data:NSData, response:NSURLResponse, error:NSError?)->Bool{
        
        let e:NSError?
        
        let object:T.DeserialType?
        (object, e) = T.deserialize(data)
        
        if e == nil {
            self.handler(result: object, response: response, error: error)
        }else{
            ACDebugLog("deserialize error, reason: \(e?.debugDescription)")
            return false
        }

        return true
        

    }

}

//public func ==(lhs: Response, rhs:Response) -> Bool {
//    return lhs.identifier == rhs.identifier
//}


class ACOriginalDataResponse : ACResponse {
    
    var core : ACResponseCore<ACOriginalDataResponseDeserializer>
    
    override func handle(data: NSData, response: NSURLResponse, error: NSError?) -> Bool {
        return self.core.handle(data, response: response, error: error)
    }
    
    init(core: ACResponseCore<ACOriginalDataResponseDeserializer>) {
        self.core = core
    }
}

class ACJSONResponse : ACResponse {
    var core : ACResponseCore<ACJSONResponseDeserializer>

    override func handle(data: NSData, response: NSURLResponse, error: NSError?) -> Bool {
        return self.core.handle(data, response: response, error: error)
    }
    
    init(core: ACResponseCore<ACJSONResponseDeserializer>) {
        self.core = core
    }
}

class ACImageResponse : ACResponse {
    var core : ACResponseCore<ACImageResponseDeserializer>
    
    override func handle(data: NSData, response: NSURLResponse, error: NSError?) -> Bool {
        return self.core.handle(data, response: response, error: error)
    }
    
    init(core: ACResponseCore<ACImageResponseDeserializer>) {
        self.core = core
    }
}

class ACTextResponse : ACResponse {
    var core : ACResponseCore<ACTextResponseDeserializer>
    
    override func handle(data: NSData, response: NSURLResponse, error: NSError?) -> Bool {
        return self.core.handle(data, response: response, error: error)
    }
    
    init(core: ACResponseCore<ACTextResponseDeserializer>) {
        self.core = core
    }
}

class ACFailedResponse : ACResponse {
    var core : ACResponseCore<ACFailedResponseDeserializer>
    
    override func handle(data: NSData, response: NSURLResponse, error: NSError?) -> Bool {
        return self.core.handle(data, response: response, error: error)
    }
    
    init(core: ACResponseCore<ACFailedResponseDeserializer>) {
        self.core = core
    }
    
}





//public enum ACResponse : ACResponsable {
//    case OriginalData(handler : ACResponseDataHandler)
//    case Text(handler : ACResponseTextHandler)
//    case JSON(handler : ACResponseObjectHandler)
//    case Image(handler : ACResponseImageHandler)
//    case Failed(handler : ACResponseFailedHandler)
//    case Custom(deserializer:ACResponseDeserializer, handler: ACResponseCustomHandler)
//    
//    internal var identifier:String{
//        
//        switch self {
//            
//        case .OriginalData:
//            return "OriginalData"
//        case .Text:
//            return "Text"
//        case .JSON:
//            return "JSON"
//        case .Image:
//            return "Image"
//        case .Failed:
//            return "Failed"
//        case .Custom:
//            return "Custom"
//        }
//    }
//    
//    internal func handle(data:NSData, response:NSURLResponse, error:NSError?)->Bool{
//        
//        ACResponse2.JSON { (result, response) -> Void in
//            
//        }
//        
//        ACResponse2.Failed { (data, response, error) -> Void in
//            
//        }
//        
//        
//        let e:NSError?
//        
//        switch self{
//        case .OriginalData(let handler):
//            let object:ACOrialDataResponseDeserializer.DeserialType?
//            (object, e) = ACOrialDataResponseDeserializer.deserialize(data)
//            
//            if e == nil {
//                handler(data: object, response: response)
//            }
//            
//        case .Text(let handler):
//            let object:ACTextResponseDeserializer.DeserialType?
//            (object, e) = ACTextResponseDeserializer.deserialize(data)
//            
//            if e == nil {
//                handler(text: object, response: response)
//            }
//            
//        case .JSON(let handler):
//            let object:ACJSONResponseDeserializer.DeserialType?
//            (object, e) = ACJSONResponseDeserializer.deserialize(data)
//            
//            if e == nil {
//                handler(object: object, response: response)
//            }
//            
//        case .Image(let handler):
//            let object:ACImageResponseDeserializer.DeserialType?
//            (object, e) = ACImageResponseDeserializer.deserialize(data)
//            
//            if e == nil {
//                handler(image: object, response: response)
//            }
//            
//        case .Failed(let handler):
//            let object:ACFailedResponseDeserializer.DeserialType?
//            (object, e) = ACFailedResponseDeserializer.deserialize(data)
//            
//            if e == nil {
//                handler(data: object, response: response, error: error)
//            }
//            
//        case let .Custom( deserializer, handler):
//            let object:ACResponseDeserializer.DeserialType?
//            (object, e) = ACResponseDeserializer.deserialize(data)
//            
//            handler(result: object, response: response, error: error)
//        }
//        
//        if e != nil {
//            ACDebugLog("deserialize error, reason: \(e?.debugDescription)")
//            return false
//        }
//        
//        
//        return true
//    }
//    
//    
//}
//
//public func ==(lhs: ACResponse, rhs:ACResponse) -> Bool {
//    return lhs.identifier == rhs.identifier
//}
//
//public func ==(lhs: ACResponse, rhs:ACResponseIdentifier) -> Bool {
//    return lhs.identifier == rhs
//}

////MARK: - ACResponseCore
//internal struct ACResponseCore {
//    
//    internal var identifier:ACResponseIdentifier
//    
//    internal static var OriginalData = ACResponseCore(identifier: "OriginalData")
//    internal static var Text = ACResponseCore(identifier: "Text")
//    internal static var JSON = ACResponseCore(identifier: "JSON")
//    internal static var Image = ACResponseCore(identifier: "Image")
//    internal static var Failed = ACResponseCore(identifier: "Failed")
//}

//extension ACResponseCore : Printable {
//    
//    internal var description:String {
//        return self.identifier
//    }
//    
//}
//
//extension ACResponseCore : Hashable {
//    
//    var hashValue: Int {
//        return self.identifier.hashValue
//    }
//    
//}
//
//extension ACResponseCore : Equatable { }
//func ==(lhs: ACResponseCore, rhs: ACResponseCore)->Bool{
//    return lhs.hashValue == rhs.hashValue
//}
