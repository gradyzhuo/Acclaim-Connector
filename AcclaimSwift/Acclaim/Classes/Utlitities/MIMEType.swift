//
//  MIME.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/12/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct MIMEType : CustomStringConvertible  {
    
    public internal(set) var type: String
    public internal(set) var subtype: String
    
    
    public init(type: String, subtype: String){
        self.type = type.lowercaseString
        self.subtype = subtype.lowercaseString
    }
    
    public init(MIME: String) throws {
        let components = MIME.lowercaseString.componentsSeparatedByString("/")
        guard components.count == 2 else {
            throw NSError(domain: "MIMEType", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"MIME is not formated by [type/subtype]"])
        }
        
        self = MIMEType(type: components[0], subtype: components[1])
    }
    
    public var description: String{
        return "\(type)/\(subtype)"
    }
}


extension MIMEType {
    
    public static let All: MIMEType = MIMEType(type: "*", subtype: "*")
    
    public static let Text: MIMEType = MIMEType(type: "text", subtype: "*")
    public static let Multipart: MIMEType = MIMEType(type: "multipart", subtype: "*")
    public static let Application: MIMEType = MIMEType(type: "application", subtype: "*")
    public static let Message: MIMEType = MIMEType(type: "message", subtype: "*")
    public static let Image: MIMEType = MIMEType(type: "image", subtype: "*")
    public static let Audio: MIMEType = MIMEType(type: "audio", subtype: "*")
    public static let Video: MIMEType = MIMEType(type: "video", subtype: "*")
    
    
    public func isKindOf(otherMIME other: MIMEType)->Bool{
        let otherType = other.type == "*" ? ".+" : other.type
        return RE.Pattern(otherType).isMatch(inString: self.type)
    }
    
}

public func ==(lhs: MIMEType, rhs: MIMEType)->Bool{
    return (lhs.type == rhs.type) && (lhs.subtype == rhs.subtype)
}

//extension
extension CollectionType where Generator.Element == MIMEType {
    public func contains(element: MIMEType) -> Bool {
        return self.contains({ (type) -> Bool in
            return type == element
        })
    }
}

