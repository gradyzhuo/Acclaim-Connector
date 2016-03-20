//
//  JSONDeserializerTests.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import XCTest
@testable import Acclaim

class DeserializerTests: BaseDeserializerTests {
    
    let encoding = NSUTF8StringEncoding
    
    override func setUp() {
        super.setUp()
        
        let jsonString =
        "{\"success\":true,\"data\":{\"id\":\"2831\",\"status\":\"OK\",\"layout\":\"TWO_HORIZONTAL\",\"type\":\"IMAGE\",\"hash\":\"dQAXWbcv\",\"member\":{\"id\":\"82\",\"account\":\"3140357046@twitter.com\",\"name\":\"Amanda Zales\",\"gender\":\"\",\"profile_image_urls\":{\"default\":\"http://pbs.twimg.com/profile_images/584728878800773121/W_F6f07D_400x400.jpg\",\"mini\":\"http://pbs.twimg.com/profile_images/584728878800773121/W_F6f07D_normal.jpg\",\"small\":\"http://pbs.twimg.com/profile_images/584728878800773121/W_F6f07D_bigger.jpg\",\"normal\":\"http://pbs.twimg.com/profile_images/584728878800773121/W_F6f07D_200x200.jpg\",\"large\":\"http://pbs.twimg.com/profile_images/584728878800773121/W_F6f07D_400x400.jpg\"},\"email\":\"3140357046@twitter.com\"},\"content\":{\"subject\":\"Which dessert looks yummy?\",\"image\":{\"id\":\"9222\",\"member_id\":\"82\",\"status\":\"OK\",\"url\":\"http://cdn.flin.gy/fling/f80c08dd829acf734fa4f68c56173f49.jpg\",\"thumb_url\":\"http://cdn.flin.gy/fling/thumb/f80c08dd829acf734fa4f68c56173f49.jpg\"}},\"options\":{\"position_0\":{\"id\":\"4729\",\"title\":\"\",\"vote\":\"63\"},\"position_1\":{\"id\":\"4730\",\"title\":\"\",\"vote\":\"63\"}},\"comments_count\":\"0\",\"geo_point\":{\"lat\":\"0\",\"lon\":\"0\"},\"cdate\":\"2015-12-29 06:44:38\"}}"
        self.data = jsonString.dataUsingEncoding(encoding)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.data = nil
    }

    
    func testJSONDeserializerForKeyPathSuccess() {
        let result = JSONDeserializer(options: .AllowFragments).deserialize(self.data, keyPath: "data.content.subject")
        let outcome = result.outcome as? String
        
        XCTAssertNil(result.error)
        XCTAssertEqual(outcome, "Which dessert looks yummy?")
    }
    
    func testJSONDeserializerForSingleKeyPathSuccess() {
        let result = JSONDeserializer(options: .AllowFragments).deserialize(self.data, keyPath: "success")
        let success = result.outcome as? Bool
        
        XCTAssertNil(result.error)
        XCTAssertEqual(success, true)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
