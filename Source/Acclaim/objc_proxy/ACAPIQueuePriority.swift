//
//  ACAPIQueuePriority.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/26/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

@objc
public enum ACAPIQueuePriority : Int {
    case Default
    case High
    case Medium
    case Low
}

internal func APIQueuePriorityMake(priority: ACAPIQueuePriority)->APIQueuePriority {
    switch priority {
    case .Default:
        return APIQueuePriority.Default
    case .High:
        return APIQueuePriority.High
    case .Medium:
        return APIQueuePriority.Medium
    case .Low:
        return APIQueuePriority.Low
    }
}