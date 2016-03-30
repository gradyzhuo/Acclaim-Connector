//
//  APIBundle.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/16/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol APIBundle : class{
    var api: API { get }
    var params: RequestParameters { get }
    var priority: QueuePriority { get }
    
    var connector: Connector { set get }
    
    func prepare()
}

extension APIBundle {
    
    public var connector: Connector {
        return Acclaim.configuration.connector
    }
    
    public func prepare() { /* do nothing */}
}


