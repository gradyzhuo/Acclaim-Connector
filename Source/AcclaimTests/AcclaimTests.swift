//
//  AcclaimTests.swift
//  AcclaimTests
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import XCTest
#if DEBUG
@testable import Acclaim
#else
import Acclaim
#endif

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

        
//        XCTAssertEqual("POST", ACMethod.POST, "pass")
//        XCTAssertEqual("GET", ACMethod.GET, "pass")
//        XCTAssertEqual("G", ACMethod.GET, "If method not found, 'GET' instead.")
        
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
