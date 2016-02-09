//
//  ACAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/25/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

@objc
public class ACAPI : NSObject {
    internal var api: API!
    
    public var apiURL:NSURL{
        return self.api.apiURL
    }
    
    public var method:ACHTTPMethod = .GET{
        didSet{
            self.api.method = ACMethodMake(method, serializerType: nil)
        }

    }
    
    public var serialType: ACSerializerType = .QueryString {
        didSet{
            self.api.method = ACMethodMake(self.method, serializerType: serialType)
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
    
    public static func APIWith(Path api:String, baseHost host:NSURL!, HTTPMethod method:ACHTTPMethod)->ACAPI{
        if let host = host {
            return ACAPI(api: api, host: host, method: method)
        }else{
            return ACAPI(api: api, host: Acclaim.hostURLFromInfoDictionary(), method: method)
        }
        
    }
    
    public init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method:ACHTTPMethod = .GET) {
        super.init()
        
        self.api = try! API(api: api, host: host, method: ACMethodMake(method, serializerType: nil))
    }
    
    public init(URL:NSURL, method:HTTPMethod = .GET){
        super.init()
        self.api = API(URL: URL, method: method)
    }
    
    internal init(_ api: API){
        super.init()
        self.api = api
    }
    
}