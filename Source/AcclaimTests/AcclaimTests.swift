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
    
//    func testMethodStringLiteralConverted() {
//        // This is an example of a functional test case.
//        typealias JSONResult = JSONResponseAssistant.DeserializerType.Outcome
//        
//        let expectation = self.expectationWithDescription("test")
//        
//        let api:API = "fling"
//        
//        
//        let caller = Acclaim.call(API: api,  params: ["fling_hash":"dQAXWbcv"])
//        .addFailedResponseHandler { (result) in
//            print("failed:\(result.error)")
//        }.addJSONResponseHandler { (result) in
//            expectation.fulfill()
//        }.addResponseAssistant(forType: .Failed, responseAssistant: TextResponseAssistant(handler: { (text, connection) in
//            print("text: \(text)")
//        }))
//        
//        XCTAssert(caller.responseAssistants.count == 1, "ResponseAssistants count is failed.")
////        caller.failedResponseAssistants.count == 1
//        
//        self.waitForExpectationsWithTimeout(self.timeoutInterval) { (error) in
//            XCTAssertNil(error)
//        }
//        
//        
//    }
}
