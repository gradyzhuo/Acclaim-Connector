//
//  Protocols.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Assistant{
    func handle(data:NSData?, connection: Connection, error:ErrorType?)->(ErrorType?)
}

public protocol ResponseAssistant : Assistant {
    associatedtype DeserializerType : Deserializer
    var deserializer: DeserializerType { set get }
}

public enum ResponseAssistantType:Int {
    case Normal
    case Failed
}
