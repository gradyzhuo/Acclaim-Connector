//
//  Caller.swift
//  Pods
//
//  Created by Grady Zhuo on 5/20/16.
//
//

public protocol Caller : class {
    var identifier: String     { set get }
    var running:Bool           { get }
    var isCancelled: Bool      { get }
    
    func suspend()
    func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?)->Void)?)
    func cancel()
}
extension Caller {
    public func resume(){
        self.resume(completion: nil)
    }
}