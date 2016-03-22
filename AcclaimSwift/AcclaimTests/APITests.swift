//
//  APITests.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/21/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import XCTest
@testable import Acclaim

class APITests: AcclaimTests {
    
    func testStringLiteralConvertibleByCompleteURLString(){
        let api: API = "http://www.google.com"
        
        XCTAssertEqual(String(api.dynamicType), "API")
        XCTAssertEqual(api.apiURL.absoluteString, "http://www.google.com")
        XCTAssertEqual(api.method.rawValue, HTTPMethod.GET.rawValue)
    }
    
    func testStringLiteralConvertible(){
        let api: API = "fling"
        
        XCTAssertEqual(String(api.dynamicType), "API")
        XCTAssertEqual(api.apiURL.absoluteString, "http://api.flin.gy/rest/fling")
    }
    
    func testDefaultMethod(){
        let api: API = "fling"
        XCTAssertEqual(api.method.rawValue, HTTPMethod.GET.rawValue)
    }
    
    func testDataTaskWithMethodPOST(){
        let api: API = "fling"
        api.requestTaskType = RequestTaskType.DataTask(method: .POST)
        XCTAssertEqual(api.method.rawValue, HTTPMethod.POST.rawValue)
    }
    
    func testGenRequest() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
