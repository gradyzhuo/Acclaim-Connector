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
    
    internal let queue:dispatch_queue_t
    
    internal var queue_attr:dispatch_queue_attr_t!
    internal var qos_class:qos_class_t
    internal var relative_priority:Int32
    
    internal var identifier:String? {
        let utf8 = dispatch_queue_get_label(QueuePriority.Default.queue)
        return String(CString: utf8, encoding: NSUTF8StringEncoding)
    }
    
    internal init(identifier:String, queue_attr: dispatch_queue_attr_t! = DISPATCH_QUEUE_SERIAL, qos_class:qos_class_t = QOS_CLASS_DEFAULT, relative_priority:Int32 = -1){
        let priorityAttr = dispatch_queue_attr_make_with_qos_class(queue_attr, qos_class, relative_priority)
        let queue = dispatch_queue_create(identifier, priorityAttr)
        
        self.queue_attr = queue_attr
        self.qos_class = qos_class
        self.relative_priority = relative_priority
        
        self.queue = queue!
    }
    
    
    public static let Default:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.Default", queue_attr: DISPATCH_QUEUE_SERIAL, qos_class: QOS_CLASS_DEFAULT, relative_priority: 0)
        }()
    
    public static let High:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.HIGH", queue_attr: DISPATCH_QUEUE_SERIAL, qos_class: QOS_CLASS_USER_INITIATED, relative_priority: 0)
        }()
    
    public static let Medium:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.MEDIUM", queue_attr: DISPATCH_QUEUE_SERIAL, qos_class: QOS_CLASS_UTILITY, relative_priority: 0)
        }()
    
    public static let Low:QueuePriority = {
        return QueuePriority(identifier:"ACAPIQueue.LOW", queue_attr: DISPATCH_QUEUE_SERIAL, qos_class: QOS_CLASS_BACKGROUND, relative_priority: 0)
        }()
}

public func ==(lhs: QueuePriority, rhs: QueuePriority)->Bool{
    return lhs.identifier == rhs.identifier
}
