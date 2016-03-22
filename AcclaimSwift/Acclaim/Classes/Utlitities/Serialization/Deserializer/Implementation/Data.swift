//
//  DataDeserializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct DataDeserializer : Deserializer {
    public typealias Outcome = NSData
    
    public func deserialize(data: NSData?) -> (outcome: Outcome?, error: ErrorType?) {
        return (data, nil)
    }
}