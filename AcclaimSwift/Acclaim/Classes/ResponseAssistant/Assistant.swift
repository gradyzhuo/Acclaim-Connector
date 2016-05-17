//
//  Protocols.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol MIMESupport {
    var allowedMIMEs: [MIMEType] { get }
}

public protocol Assistant{
    func handle(data:NSData?, connection: Connection, error:ErrorType?)->(ErrorType?)
}

public protocol ResponseAssistant : Assistant, MIMESupport {
    associatedtype Handler
    associatedtype DeserializerType : Deserializer
    
    var handler : Handler? { set get }
    var deserializer: DeserializerType { set get }
    
    init(handler: Handler?)
    
}

public enum ResponseAssistantType:Int {
    case Normal
    case Failed
}
