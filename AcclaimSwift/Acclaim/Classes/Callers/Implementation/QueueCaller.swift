//
//  QueueCaller.swift
//  Acclaim
//
//  Created by Grady Zhuo on 5/5/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

typealias CarryingHandler = (data: Data?, connection: Connection, error: NSError?) -> Void

public class QueueCaller : Caller {
    public var identifier: String = String(Date().timeIntervalSince1970)
    public internal(set) var priority:QueuePriority = QueuePriority.Default
    public internal(set) var running:Bool  = false
    public internal(set) var isCancelled:Bool = false
    
    internal var _waittingCallers: [String : Caller] = [:]{
        didSet{
            self.waittingCallers = _waittingCallers.map{ $1 }
        }
    }
    
    internal var carryingHandlers: [String:CarryingHandler] = [:]
    
    public internal(set) var waittingCallers: [Caller]
    public internal(set) var targetCaller: Caller
    
    internal let group : DispatchGroup = DispatchGroup()
    internal let queue : DispatchQueue
    
    public convenience init(targetCaller caller:Caller, waitting callers: Caller...){
        self.init(targetCaller: caller, waitting: callers)
    }
    
    public init(targetCaller caller:Caller, waitting callers: [Caller]){
        self.queue = DispatchQueue(label: identifier, attributes: DispatchQueueAttributes.serial)
        self.targetCaller = caller
        self.waittingCallers = callers
    }
    
    
    public func resume() {
        
//        for caller in self.waittingCallers {
//            
//            dispatch_group_enter(self.group)
//            caller.resume {[unowned self] (data, connection, error) in
//                
//                if let handler = self.carryingHandlers[caller.identifier]{
//                    handler(data: data, connection: connection, error: error)
//                }
//                
//                dispatch_group_leave(self.group)
//            }
//            
//        }
//        
//        dispatch_group_notify(self.group, self.queue) {[unowned self] in
//            self.targetCaller.resume(completion: completion)
//        }
        
    }
    
    public func suspend() {
        
    }

    public func cancel(){
        
    }
    
    public func setCarryingHandler(forWattingIdentifier identifier: String, handler: (data: Data?, connection: Connection, error: NSError?) -> Void){
        self.carryingHandlers[identifier] = handler
    }
    
}
