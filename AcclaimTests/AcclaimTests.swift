//
//  AcclaimTests.swift
//  AcclaimTests
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import XCTest
import Acclaim

class AcclaimTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMethodStringLiteralConverted() {
        // This is an example of a functional test case.

        
        XCTAssertEqual("POST", ACMethod.POST, "pass")
        XCTAssertEqual("GET", ACMethod.GET, "pass")
        XCTAssertEqual("G", ACMethod.GET, "If method not found, 'GET' instead.")
        
    }

    func testResponseType() {
        let testJSON = ["key":"value"]
        // This is an example of a functional test case.
        let JSONType = Response.JSON { (result) -> Void in
//            XCTAssertNotNil(result as? AnyObject, "not nil")
//            XCTAssertEqual(result as! AnyObject, testJSON, "pass")
        }
        
//        JSONType.handle(testJSON)
        
        
        let testText = "result"
        
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
        
        
        let paramType : ACRequestParamType = "JSON"
        print("paramType.identifier:\(paramType.identifier)")
    }
    
    func testConfig() {
        
        var config = ACAPICallerConfigure.defaultConfigure
        
        let caller = ACAPICaller(API: "test")
        let response = ACResponse.HTML(handler: { (result) -> Void in
            
        })
        

        XCTAssert(response == "HTML", "pass")
        
//        ACAPICaller.makeCall("test").addResponse(ACResponse.JSON(handler: { (result, response) -> Void in
//            
//        })).addResponse(ACResponse.Failed(handler: { (result, response) -> Void in
//            
//        }))
        
        XCTAssertNotNil(caller.API?.getAPIURL(), "")
        
        if let paramType = caller.API?.paramsType {
            
            XCTAssertEqual(paramType, ACRequestParamType.KeyValue, "")
            
        }
        
        
//        XCTAssert(caller.responseHandlers.count == 2, "")
//        println("caller.responseHandlers:\(caller.responseHandlers)")
    }
    
}
