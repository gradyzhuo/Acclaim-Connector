//
//  TextDeserializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct TextDeserializer : Deserializer{
    public typealias Outcome = String
    
    public var encoding:NSStringEncoding
    
    public func deserialize(data: NSData?) -> (outcome: Outcome?, error: ErrorType?) {
        guard let data = data else {
            return (nil, error: NSError(domain: "ACTextResponseDeserializer", code: 9, userInfo: [NSLocalizedFailureReasonErrorKey:"Original Data is nil."]))
        }
        
        guard let text : String = String(data: data , encoding: NSUTF8StringEncoding) else {
            return (nil, error: NSError(domain: "ACTextResponseDeserializer", code: 8, userInfo: [NSLocalizedFailureReasonErrorKey:"Can't convert data to string."]))
        }
        
        return (text, nil)
    }
    
    public init(){
        self.encoding = NSUTF8StringEncoding
    }
    
    public init(encoding:NSStringEncoding){
        self.encoding = encoding
    }
}