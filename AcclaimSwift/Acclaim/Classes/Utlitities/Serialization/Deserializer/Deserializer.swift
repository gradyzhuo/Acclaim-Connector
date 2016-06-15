//
//  Protocols.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

//FIXME: 未來可以加入錯誤的Key，要如何自已處理的方式。
public protocol Deserializer {
    associatedtype Outcome
    func deserialize(data:Data?) -> (outcome: Outcome?, error: NSError?)
    
    init()
}
