//
//  ModelDeserializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class MappingModel {
    let dataDict:AnyObject
    init(dataDict: AnyObject){
        self.dataDict = dataDict
    }
}

public protocol ModelDeserializer {
    typealias ModelType:MappingModel
    static var identifier: String { get }
    
    func deserialize(data:AnyObject) -> (ModelType?, ErrorType?)
    
    init()
}

