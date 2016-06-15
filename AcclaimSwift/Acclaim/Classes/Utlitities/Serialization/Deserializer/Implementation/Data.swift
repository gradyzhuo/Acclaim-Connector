//
//  DataDeserializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct DataDeserializer : Deserializer {
    public typealias Outcome = Data
    
    public func deserialize(data: Data?) -> (outcome: Outcome?, error: NSError?) {
        return (data, nil)
    }
    
    public init(){
        
    }
}
