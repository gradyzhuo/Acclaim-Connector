//
//  AcclaimTests.swift
//  AcclaimTests
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import XCTest

@testable import Acclaim
 
class AcclaimTests: XCTestCase {
    
    let timeoutInterval: NSTimeInterval = 30
    
    override func setUp() {
        let bundle = NSBundle(forClass: AcclaimTests.self)
        Acclaim.configuration.bundleForHostURLInfo = bundle
    }
    
}
