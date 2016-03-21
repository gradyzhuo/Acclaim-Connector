//
//  KeyPathable.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/5/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct KeyPath {
    public typealias ExpectedType = String
    
    public internal(set) var path: String
    public internal(set) var separater:String
    
    public init(path: String, separater:String = "."){
        self.path = path
        self.separater = separater
    }
    
}

extension KeyPath : Hashable {
    public var hashValue: Int{
        return self.path.hash
    }
}

public func ==(lhs: KeyPath, rhs: KeyPath)->Bool{
    return lhs.path == rhs.path
}

extension KeyPath : StringLiteralConvertible {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = KeyPath(path: value, separater: ".")
        
    }
    
    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
}


public protocol KeyPathParser{
    static func parse<T>(value:AnyObject?, forKeyPath keyPath:KeyPath)->T?
}

extension KeyPathParser{
    
    public static func parse<T>(value:AnyObject?, forKeyPath keyPath:KeyPath)->T?{

        let keyPathes = keyPath.path.componentsSeparatedByString(keyPath.separater)
        let result = keyPathes.reduce(value) { (parsedObject, key) -> AnyObject? in
            return parsedObject?[key]
        }
        
        return result as? T
    }
}
