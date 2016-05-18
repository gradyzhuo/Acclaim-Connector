//
//  QueueCaller.swift
//  Acclaim
//
//  Created by Grady Zhuo on 5/5/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

typealias CarryingHandler = (data: NSData?, connection: Connection, error: NSError?) -> Void

public class QueueCaller : Caller {
    public var identifier: String = String(NSDate().timeIntervalSince1970)
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
    
    internal let group : dispatch_group_t = dispatch_group_create()
    internal let queue : dispatch_queue_t
    
    public convenience init(targetCaller caller:Caller, waitting callers: Caller...){
        self.init(targetCaller: caller, waitting: callers)
    }
    
    public init(targetCaller caller:Caller, waitting callers: [Caller]){
        self.queue = dispatch_queue_create(identifier, DISPATCH_QUEUE_SERIAL)
        self.targetCaller = caller
        self.waittingCallers = callers
    }
    
    
    public func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?) -> Void)?) {
        
        for caller in self.waittingCallers {
            
            dispatch_group_enter(self.group)
            caller.resume {[unowned self] (data, connection, error) in
                
                if let handler = self.carryingHandlers[caller.identifier]{
                    handler(data: data, connection: connection, error: error)
                }
                
                dispatch_group_leave(self.group)
            }
            
        }
        
        dispatch_group_notify(self.group, self.queue) {[unowned self] in
            self.targetCaller.resume(completion: completion)
        }
        
        
    }

    public func cancel(){
        
    }
    
    public func setCarryingHandler(forWattingIdentifier identifier: String, handler: (data: NSData?, connection: Connection, error: NSError?) -> Void){
        self.carryingHandlers[identifier] = handler
    }
    
}