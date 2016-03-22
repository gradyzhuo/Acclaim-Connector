//
//  ACAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/25/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation
import Acclaim

@objc
public class ACAPI : NSObject {
    internal var api: API!
    
    public var apiURL:NSURL{
        return self.api.apiURL
    }
    
    public var method:ACHTTPMethod = .GET{
        didSet{
            self.api.requestTaskType = RequestTaskType.DataTask(method: ACMethodMake(method, serializerType: nil))
        }
    }
    
    public var serialType: ACSerializerType = .QueryString {
        didSet{
            self.api.requestTaskType.method = ACMethodMake(self.method, serializerType: serialType)
        }
    }
    
    public var timeoutInterval:NSTimeInterval{
        set{
            self.api.timeoutInterval = newValue
        }
        get{
            return self.api.timeoutInterval
        }
    }
    
    public var cachePolicy:NSURLRequestCachePolicy{
        set{
            self.api.cachePolicy = newValue
        }
        get{
            return self.api.cachePolicy
        }
    }
    
    public class var HTTPHeaderFieldsForAllRequest:[String:String]{
        set{
            API.HTTPHeaderFieldsForAllRequest = newValue
        }
        get{
            return API.HTTPHeaderFieldsForAllRequest
        }
    }
    
    public var cookies:[NSHTTPCookie]{
        return self.api.cookies
    }
    
    public static func APIWith(Path api:String, baseHost host:NSURL, HTTPMethod method:ACHTTPMethod)->ACAPI{
        return ACAPI(api: api, host: host, method: method)
    }
    
    public static func APIWith(Path api:String, HTTPMethod method:ACHTTPMethod)->ACAPI{
        return ACAPI(api: api, host: Acclaim.hostURLFromInfoDictionary(), method: method)
    }
    
    public init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method:ACHTTPMethod = .GET) {
        super.init()
        
        let method = ACMethodMake(method, serializerType: nil)
        let taskType = RequestTaskType.DataTask(method: method)
        
        self.api = try! API(api: api, host: host, taskType: taskType)
    }
    
    public init(URL:NSURL, method:ACHTTPMethod){
        super.init()
        
        let method = ACMethodMake(method, serializerType: nil)
        let taskType = RequestTaskType.DataTask(method: method)
        
        self.api = API(URL: URL, taskType: taskType)
    }
    
    internal init(_ api: API){
        super.init()
        self.api = api
    }
    
}