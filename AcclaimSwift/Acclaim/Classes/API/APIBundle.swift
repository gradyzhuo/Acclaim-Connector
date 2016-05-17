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
    var params: Parameters { get }
    var priority: QueuePriority { get }
    
    var connector: Connector { set get }
    
    func prepare()
}

extension APIBundle {
    public func prepare() { /* do nothing */}
}


//internal class ACAPIBundle : APIBundle {
//    internal var api: API
//    public var params: RequestParameters
//    public var priority: QueuePriority
//    
//    public var connector: Connector
//    
//    
//    public init(api: API, params: RequestParameters, priority: QueuePriority, connector: Connector = Acclaim.configuration.connector){
//        self.api = api
//        self.params = params
//        self.priority = priority
//        
//        self.connector = connector
//    }
//    
//    public func prepare() {
//        
//    }
//}