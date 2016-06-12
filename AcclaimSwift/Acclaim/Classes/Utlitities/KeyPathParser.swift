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
    
    public init(_ path: String){
        self = KeyPath(path: path)
    }
    
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

public protocol Command:class {
    func handle(value: AnyObject?)->AnyObject?
}

public protocol KeyPathParser{
    static func parse<T>(value:AnyObject?, forKeyPath keyPath:KeyPath)->T?
    static func handle(command:String, value: AnyObject?)->AnyObject?
}

extension KeyPathParser{
    
    public static func parse<T>(value:AnyObject?, forKeyPath keyPath:KeyPath)->T?{
        
        guard keyPath != "" else{
            return value as? T
        }
        
        let pString = "^(?:\\@(\\w+)\\()?([\\w\\d\\\(keyPath.separater)]+)(?:\\))?$"
        let pattern = RE.Pattern(pString)
        
        guard let matchResult = pattern.firstMatch(inString: keyPath.path) else {
            return nil
        }
        
        let command = matchResult.substring(matchIndex: 1)?.lowercased()
        let path:String = matchResult.substring(matchIndex: 2) ?? ""
        
        
        let keyPathes = path.components(separatedBy: keyPath.separater)
        
        let result = keyPathes.reduce(value) { (parsedObject, key) -> AnyObject? in
            
            if let result = parsedObject?[key] where result != nil{
                return result
            }else{
                if key == "self" || key == "" {
                    return parsedObject
                }else if let items = parsedObject as? [AnyObject], let index = Int(key) where items.indices.contains(index) {
                    return items[index]
                }else if let commandResult = self.handle(command: key, value: parsedObject) {
                    return commandResult
                }else{
                    return nil
                }
            }
            
        }
        
        if let command = command {
            return self.handle(command: command, value: result) as? T
        }
        
        return result as? T
    }
    
    
}
