//
//  AssistantTests.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/27/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import XCTest
@testable import Acclaim

class FailedAssistantTests: AcclaimTests {
    
    func testStatusCodeFatchedSuccess() {
        
        let request = NSURLRequest()
        let httpResponse = NSHTTPURLResponse(URL: NSURL(), statusCode: 404, HTTPVersion: "HTTPVersion", headerFields: nil)
        let data = NSData()
        
        let passString = "Success!!"
        var test: String = ""
        
        let connection = Connection(originalRequest: request, currentRequest: request, response: httpResponse, cached: false)
        
        self.measureBlock {
            var assistant = FailedResponseAssistant()
            assistant.addHandler(forStatusCode: 404) { (originalData, connection, error) in
                test = passString
            }
            assistant.handle(data, connection: connection, error: nil)
        }
        
        XCTAssertEqual(test, passString)
        
    }
    
    func testStatusCodeFatchedFailed() {

        let request = NSURLRequest()
        let httpResponse = NSHTTPURLResponse(URL: NSURL(), statusCode: 405, HTTPVersion: "HTTPVersion", headerFields: nil)
        let data = NSData()
        
        let passString = "Success!!"
        var test: String = ""
        
        let connection = Connection(originalRequest: request, currentRequest: request, response: httpResponse, cached: false)
        
        self.measureBlock {
            var assistant = FailedResponseAssistant()
            assistant.addHandler(forStatusCode: 404) { (originalData, connection, error) in
                test = passString
            }
            assistant.handle(data, connection: connection, error: nil)
        }

        XCTAssertNotEqual(test, passString)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
