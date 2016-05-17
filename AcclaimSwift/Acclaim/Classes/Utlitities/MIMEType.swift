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
    
    
    internal init(type: String, subtype: String){
        self.type = type.lowercaseString
        self.subtype = subtype.lowercaseString
    }
    
    internal init(MIME: String) throws {
        let components = MIME.lowercaseString.componentsSeparatedByString("/")
        guard components.count == 2 else {
            throw NSError(domain: "MIMEType", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"MIME is not formated by [type/subtype]"])
        }
        
        self = MIMEType(type: components[0], subtype: components[1])
    }
    
    public var MIMEString: String {
        return "\(type)/\(subtype)"
    }
    
    public var description: String{
        return self.MIMEString
    }
}


extension MIMEType {
    
    public static func All(subtype subtype: String)->MIMEType{
        return MIMEType(type: "*", subtype: subtype)
    }
    
    public static func Text(subtype subtype: String)->MIMEType{
        return MIMEType(type: "text", subtype: subtype)
    }
    public static func Multipart(subtype subtype: String)->MIMEType{
        return MIMEType(type: "multipart", subtype: subtype)
    }
    public static func Application(subtype subtype: String)->MIMEType{
        return MIMEType(type: "application", subtype: subtype)
    }
    public static func Message(subtype subtype: String)->MIMEType{
        return MIMEType(type: "message", subtype: subtype)
    }
    public static func Image(subtype subtype: String)->MIMEType{
        return MIMEType(type: "image", subtype: subtype)
    }
    public static func Audio(subtype subtype: String)->MIMEType{
        return MIMEType(type: "audio", subtype: subtype)
    }
    public static func Video(subtype subtype: String)->MIMEType{
        return MIMEType(type: "video", subtype: subtype)
    }
    
    public static let All: MIMEType = MIMEType.All(subtype: "*")
    
    public static let Text: MIMEType = .Text(subtype: "*")
    public static let Multipart: MIMEType = .Multipart(subtype: "*")
    public static let Application: MIMEType = .Application(subtype: "*")
    public static let Message: MIMEType = .Message(subtype: "*")
    public static let Image: MIMEType = .Image(subtype: "*")
    public static let Audio: MIMEType = .Audio(subtype: "*")
    public static let Video: MIMEType = .Video(subtype: "*")
    
    public func isKindOf(otherMIME other: MIMEType)->Bool{
        let otherType = other.type == "*" ? ".+" : other.type
        return RE.Pattern(otherType).isMatch(inString: self.type)
    }
    
    public func isSubtypeKindOf(otherMIME other: MIMEType)->Bool{
        let otherType = other.subtype == "*" ? ".+" : other.subtype
        return RE.Pattern(otherType).isMatch(inString: self.type)
    }
    
}

public func ==(lhs: MIMEType, rhs: MIMEType)->Bool{
    if lhs.type == "*"  {
        if lhs.subtype == "*" {
            return rhs.isKindOf(otherMIME: lhs) && rhs.isSubtypeKindOf(otherMIME: lhs)
        }else{
            return rhs.isKindOf(otherMIME: lhs) && lhs.isSubtypeKindOf(otherMIME: rhs)
        }
    }else{
        if lhs.subtype == "*" {
            return lhs.isKindOf(otherMIME: rhs) && rhs.isSubtypeKindOf(otherMIME: lhs)
        }else{
            return lhs.isKindOf(otherMIME: rhs) && lhs.isSubtypeKindOf(otherMIME: rhs)
        }
    }
}

//extension
extension RangeReplaceableCollectionType where Generator.Element == MIMEType {
    public func contains(element: MIMEType) -> Bool {
        return self.contains({ (type) -> Bool in
            return type == element
        })
    }
}

