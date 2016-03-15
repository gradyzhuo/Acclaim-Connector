//
//  MIME.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/12/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct MIME  {
//    /// Convert from a value of `RawValue`, succeeding unconditionally.
//    public init(rawValue: Self.RawValue)
    
    public internal(set) var major: String
    public internal(set) var minor: String
    
    
    public init(major: String, minor: String){
        self.major = major
        self.minor = minor
    }
    
}

extension MIME : OptionSetType {
    
    public typealias RawValue = String
    
    public var rawValue: RawValue{
        return "\(self.major)/\(self.minor)"
    }
    
    public init(rawValue: MIME.RawValue){
        self = MIME(rawValue: rawValue)
    }
    
    public init() {
        self = MIME(rawValue: "")
    }
    
    public mutating func unionInPlace(other: MIME){
        self = self.union(other)
    }
    
    public mutating func intersectInPlace(other: MIME){
        self = self.intersect(other)
    }

    public mutating func exclusiveOrInPlace(other: MIME){
        self = self.exclusiveOr(other)
    }
    
}

//extension MIME {
//    public static var PNG : MIME = MIME(MIMEType: "image/png")
//    public static var JPEG : MIME = MIME(MIMEType: "image/jpeg")
//    
//}


//extension MIME : CustomStringConvertible{
//    public var description: String{
//        return self.MIMEType
//    }
//}

