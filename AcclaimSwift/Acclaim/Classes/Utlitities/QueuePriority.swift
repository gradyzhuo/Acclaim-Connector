//
//  ACQueuePriority.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/19/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation


/**
 The queue priority level configure of sending a request. (readonly)
 
 There are 3 levels as below:
 - High
 - Medium
 - Low
 
 Otherwise:
 - Default = Medium
 */
public struct QueuePriority : Equatable {
    
    internal let queue:DispatchQueue
    
    internal let attribute: DispatchQueueAttributes
    internal let relativePriority: Int
    
    internal var identifier:String? {
        let utf8 = QueuePriority.Default.queue.label
        return String(CString: utf8, encoding: String.Encoding.utf8)
    }
    
    internal init(identifier:String, attributes: DispatchQueueAttributes = [.serial, .qosDefault], relativePriority:Int = -1){
        
        self.relativePriority = relativePriority
        self.attribute = attributes
        
        self.queue = DispatchQueue(label: identifier, attributes: attributes)
    }
    
    
    internal var qos: DispatchQoS {
        return self.queue.qos
    }
    
    //MARK: -
    
    public static let Default:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.Default", attributes: [.serial, .qosDefault], relativePriority: 0)
    }()
    
    public static let High:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.HIGH", attributes: [.serial, .qosUserInitiated], relativePriority: 0)
    }()
    
    public static let Medium:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.MEDIUM", attributes: [.serial, .qosUtility], relativePriority: 0)
    }()
    
    public static let Low:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.LOW", attributes: [.serial, .qosBackground], relativePriority: 0)
    }()
}

public func ==(lhs: QueuePriority, rhs: QueuePriority)->Bool{
    return lhs.identifier == rhs.identifier
}
