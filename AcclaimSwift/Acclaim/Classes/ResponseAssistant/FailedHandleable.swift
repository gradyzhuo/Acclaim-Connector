//
//  FailedSupport.swift
//  Pods
//
//  Created by Grady Zhuo on 5/27/16.
//
//

import Foundation

public protocol AssistantFailedHandleable {
    associatedtype AssistantType:ResponseAssistant
    associatedtype FailedHandler = (assistant: AssistantType, data: NSData?, error: ErrorType?)->Void
    var failedHandler: FailedHandler? { get }
    
    mutating func failed(assistantHandler handler: FailedHandler)
}