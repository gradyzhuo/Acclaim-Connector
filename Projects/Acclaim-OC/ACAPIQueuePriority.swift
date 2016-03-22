//
//  ACQueuePriority.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/26/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation
import Acclaim

@objc
public enum ACQueuePriority : Int {
    case Default
    case High
    case Medium
    case Low
}

internal func QueuePriorityMake(priority: ACQueuePriority)->QueuePriority {
    switch priority {
    case .Default:
        return QueuePriority.Default
    case .High:
        return QueuePriority.High
    case .Medium:
        return QueuePriority.Medium
    case .Low:
        return QueuePriority.Low
    }
}