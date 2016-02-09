//
//  KeyPathable.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/5/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

internal protocol KeyPathParser{
    
}

extension KeyPathParser{
    func parse(value:AnyObject?, forKeyPath keyPath:String, separater:String = ".")->AnyObject?{
        let keyPathes = keyPath.componentsSeparatedByString(separater)
        let result = keyPathes.reduce(value) { (parsedObject, key) -> AnyObject? in
            return parsedObject?[key]
        }
        return result
    }
}
