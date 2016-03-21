//
//  KeyPathable.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/5/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

    


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
