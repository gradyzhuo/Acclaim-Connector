//
//  ACAPICaller.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/25/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class ACAPICaller : NSObject {
    var apiCaller: APICaller!
    
    public var priority:ACAPIQueuePriority{
        if apiCaller.priority == APIQueuePriority.Default {
            return .Default
        }else if apiCaller.priority == APIQueuePriority.High {
            return .High
        }else if apiCaller.priority == APIQueuePriority.Medium {
            return .Medium
        }else {
            return .Low
        }
    }
    
    public var cacheStoragePolicy:NSURLCacheStoragePolicy{
        return self.apiCaller.cacheStoragePolicy
    }
    
    /** (read only) */
    public  var cancelled:Bool {
        return self.apiCaller.cancelled
    }
    
    /** (read only) */
    public var api:ACAPI!{
        return ACAPI(self.apiCaller.api)
    }
    /** (read only) */
    public var running:Bool{
        return self.apiCaller.running
    }
    
    public func run(cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed, priority: ACAPIQueuePriority = .Default){
        self.apiCaller.run(cacheStoragePolicy, priority: APIQueuePriorityMake(priority))
    }
    
    public func resume(){
        self.apiCaller.resume()
    }
    
    public func cancel(){
        self.apiCaller.cancel()
    }
    
    public init(API api:ACAPI, params:[String: String]) {
        super.init()
        self.apiCaller = APICaller(API: api.api, params: params, connector: Acclaim.defaultConnector)
    }
    
}

extension ACAPICaller {
    public func addResponseHandler(handler: @convention(block)(data: NSData?, response: NSHTTPURLResponse?)->Void){
        self.apiCaller.addOriginalDataResponseHandler { (result) in
            handler(data: result.data, response: result.connection.response)
        }
    }
    
    public func addImageResponseHandler(handler: @convention(block)(image: UIImage?, response: NSHTTPURLResponse?)->Void){
        
        self.apiCaller.addImageResponseHandler { (image, connection) in
            handler(image: image, response: connection.response)
        }
        
    }
    
    public func addJSONResponseHandler(handler:@convention(block)(JSONObject: AnyObject?, response: NSHTTPURLResponse?)->Void){
        
        self.apiCaller.addJSONResponseHandler { (JSONObject, connection) in
            handler(JSONObject: JSONObject, response: connection.response)
        }
        
    }
    
    public func addTextResponseHandler(handler:@convention(block)(text: String?, response: NSHTTPURLResponse?)->Void){
        self.apiCaller.addTextResponseHandler { (text, connection) in
            handler(text: text, response: connection.response)
        }
    }
    
    public func setFailedResponseHandler(handler:@convention(block)(data: NSData?, response: NSHTTPURLResponse?, error: NSError?)->Void){
        self.apiCaller.setFailedResponseHandler { (originalData, connection, error) in
            handler(data: originalData, response: connection.response, error: error as? NSError)
        }
    }
    
}