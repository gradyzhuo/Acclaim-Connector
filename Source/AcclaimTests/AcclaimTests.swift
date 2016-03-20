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
    
    func testAcclaimRunningCallers(){
        
    }
    
    func testAPIURL(){
        let string = ["test":"123"]
        let data = try? NSJSONSerialization.dataWithJSONObject(string, options: .PrettyPrinted)
        let result = JSONDeserializer(options: .AllowFragments).deserialize(data, keyPath: "test")
        print("outcome:\(result.outcome)")
    }
    
    override func setUp() {
        let bundle = NSBundle(forClass: AcclaimTests.self)
        Acclaim.configuration.bundleForHostURLInfo = bundle
    }
    
    func testMethodStringLiteralConverted() {
        // This is an example of a functional test case.
        typealias JSONResult = JSONResponseAssistant.DeserializerType.Outcome
        
        let expectation = self.expectationWithDescription("test")
        
        let api:API = "fling"
        
        
        let caller = Acclaim.call(API: api,  params: ["fling_hash":"dQAXWbcv"])
        .addFailedResponseHandler { (result) in
            print("failed:\(result.error)")
        }.addJSONResponseHandler { (result) in
            expectation.fulfill()
        }.addResponseAssistant(forType: .Failed, responseAssistant: TextResponseAssistant(handler: { (text, connection) in
            print("text: \(text)")
        }))
        
        XCTAssert(caller.responseAssistants.count == 1, "ResponseAssistants count is failed.")
//        caller.failedResponseAssistants.count == 1
        
        self.waitForExpectationsWithTimeout(self.timeoutInterval) { (error) in
            XCTAssertNil(error)
        }
        
        
    }

    func testResponseType() {
//        let testJSON = ["key":"value"]
        // This is an example of a functional test case.
//        let JSONType = ACAPIResponse.JSON { (result) -> Void in
//            XCTAssertNotNil(result as? AnyObject, "not nil")
//            XCTAssertEqual(result as! AnyObject, testJSON, "pass")
//        }
        
//        JSONType.handle(testJSON)
        
        
//        let testText = "result"
        
//        let TextType = ACResponseHandler.Text { (result) -> Void in
//            XCTAssertNotNil(result, "not nil")
//            XCTAssertEqual(result!, testText, "pass")
//        }

//        TextType.handle(testText)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
        
    }
}
