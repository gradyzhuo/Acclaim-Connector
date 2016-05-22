//
//  SendingProcessHandlable.swift
//  Pods
//
//  Created by Grady Zhuo on 5/20/16.
//
//

public protocol SendingProcessHandlable:class {
    var sendingProcessHandler: ProcessHandler? { get }
    
    func observer(sendingProcess handler: ProcessHandler) -> Self
}