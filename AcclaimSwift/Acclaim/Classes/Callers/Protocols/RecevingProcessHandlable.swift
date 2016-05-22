//
//  RecevingProcessHandlable.swift
//  Pods
//
//  Created by Grady Zhuo on 5/20/16.
//
//

public protocol RecevingProcessHandlable:class {
    var recevingProcessHandler: ProcessHandler? { get }
    
    func observer(recevingProcess handler: ProcessHandler) -> Self
}
