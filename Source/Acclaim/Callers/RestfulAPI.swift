//
//  RestfulAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class RestfulAPI : APICaller {
    
    public func addTextResponseHandler(encoding: NSStringEncoding = NSUTF8StringEncoding, handler:TextResponseAssistant.Handler)->Self{
        self.addResponseAssistant(responseAssistant: TextResponseAssistant(encoding: encoding, handler: handler))
        return self
    }
    
    public func addJSONResponseHandler(keyPath keyPath:String, option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->Self{
        self.addResponseAssistant(responseAssistant: JSONResponseAssistant(forKeyPath: keyPath, option: option, handler: handler))
        return self
    }
    
    public func addJSONResponseHandler(option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->Self{
        self.addResponseAssistant(responseAssistant: JSONResponseAssistant(option: option, handler: handler))
        return self
    }
    
}

extension Acclaim {
    ///
    public static func call(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->RestfulAPI{
        
        let caller = RestfulAPI(API: api, params: params)
        caller.priority = priority
        caller.run()
        
        return caller
    }
    
    public static func call(APIBundle bundle:APIBundle)->RestfulAPI{
        bundle.prepare()
        return Acclaim.call(API: bundle.api, params: bundle.params, priority: bundle.priority)
    }
}