//
//  APICallerProtocol.swift
//  Acclaim
//
//  Created by Grady Zhuo on 5/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol _Caller {
    var identifier: String     { set get }
    var running:Bool           { get }
    var isCancelled: Bool      { get }
    
    func resume()
    func cancel()
}
