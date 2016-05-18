//
//  Protocols.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol MIMESupport {
    var allowedMIMEs: [MIMEType] { set get }
}

public protocol Assistant{
    func handle(data:NSData?, connection: Connection, error:ErrorType?)->(ErrorType?)
}

extension Assistant {
    internal func _handle(data:NSData?, connection: Connection, error:ErrorType?)->(ErrorType?){
        if let MIME = connection.responseMIME where connection.requestMIMEs.contains(MIME) {
            return self.handle(data, connection: connection, error: error)
        }
        return nil//NSError(domain: "Assistant.handle", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"responseMIME is not supported for requestMIMEs."])
    }
}

public protocol ResponseAssistant : Assistant, MIMESupport {
    associatedtype Handler
    associatedtype DeserializerType : Deserializer
    
    var handler : Handler? { set get }
    var deserializer: DeserializerType { set get }
    
    init(handler: Handler?)
    
}

public enum ResponseAssistantType:Int {
    case Success
    case Failed
}
