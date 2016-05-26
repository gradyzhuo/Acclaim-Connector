//
//  FailedSupport.swift
//  Pods
//
//  Created by Grady Zhuo on 5/27/16.
//
//

import Foundation

public protocol FailedHandleable {
    associatedtype FailedHandler = (data: NSData?, error: ErrorType?)->Void
    
    var failedHandler: FailedHandler? { get }
    
    mutating func failed(handle handler: FailedHandler)
}