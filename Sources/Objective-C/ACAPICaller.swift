//
//  ACAPICaller.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/25/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation
import Acclaim

public class ACAPICaller : NSObject {
    var apiCaller: APICaller!
    
    public var priority:ACQueuePriority{
        if apiCaller.priority == QueuePriority.Default {
            return .Default
        }else if apiCaller.priority == QueuePriority.High {
            return .High
        }else if apiCaller.priority == QueuePriority.Medium {
            return .Medium
        }else {
            return .Low
        }
    }
    
    public var cacheStoragePolicy:NSURLCacheStoragePolicy{
        return NSURLCacheStoragePolicy(self.apiCaller.cacheStoragePolicy)
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
    
    public func run(cacheStoragePolicy:NSURLCacheStoragePolicy = .Allowed, priority: ACQueuePriority = .Default){
        self.apiCaller.run(APICaller.CacheStoragePolicy(cacheStoragePolicy), priority: QueuePriorityMake(priority))
    }
    
    public func resume(){
        self.apiCaller.resume()
    }
    
    public func cancel(){
        self.apiCaller.cancel()
    }
    
    public init(API api:ACAPI, params:ACRequestParameters) {
        super.init()
        
        self.setup(API: api, params: params)
    }
    
    internal func setup(API api:ACAPI, params:ACRequestParameters){
        self.apiCaller = APICaller(API: api.api, params: params.requestParameters(), connector: Acclaim.defaultConnector)
    }
    
}

extension ACAPICaller {
    public func addResponseHandler(handler: @convention(block)(data: NSData, response: NSURLResponse?)->Void){
        self.apiCaller.addOriginalDataResponseHandler { (result) in
            handler(data: result.data, response: result.connection.response)
        }
    }
    
    
    
    public func setFailedResponseHandler(handler:@convention(block)(data: NSData?, response: NSHTTPURLResponse?, error: NSError?)->Void){
        self.apiCaller.addFailedResponseHandler { (originalData, connection, error) in
            handler(data: originalData, response: connection.response, error: error as? NSError)
        }
    }
    
    public func setCancelledResponseHandler(handler:@convention(block)(resumedata: NSData?, response: NSURLResponse?, error: NSError?)->Void){
        
        self.apiCaller.setCancelledResponseHandler { (result) in
            handler(resumedata: result.resumeData, response: result.connection.response, error: nil)
        }
    }
    
    public func setSendingProcessHandler(handler: @convention(block)(bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64)->Void) {
        self.apiCaller.setSendingProcessHandler { (bytes, totalBytes, totalBytesExpected) in
            handler(bytes: bytes, totalBytes: totalBytes, totalBytesExpected: totalBytesExpected)
        }
    }
    
    public func setRecevingProcessHandler(handler: @convention(block)(bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64)->Void) {
        self.apiCaller.setRecevingProcessHandler { (bytes, totalBytes, totalBytesExpected) in
            handler(bytes: bytes, totalBytes: totalBytes, totalBytesExpected: totalBytesExpected)
        }
    }

    
}

public class ACDownloader : ACAPICaller {
    
    var downloader: Downloader!
    
    public static func downloadCallerWith(API api:ACAPI, params: ACRequestParameters)->ACDownloader{
        return ACDownloader(API: api, params: params)
    }
    
    override func setup(API api: ACAPI, params: ACRequestParameters) {
        self.downloader = Downloader(API: api.api, params: params.requestParameters(), connector: Acclaim.defaultConnector)
        self.apiCaller = self.downloader
    }
    
    public func addImageResponseHandler(handler: @convention(block)(image: UIImage, response: NSURLResponse?)->Void){
        
        self.downloader.addImageResponseHandler { (image, connection) in
            handler(image: image, response: connection.response)
        }
        
    }
    
}

public class ACRestfulAPI : ACAPICaller {
    
    var restfulAPI: RestfulAPI!
    
    public static func restfulAPICallerWith(API api:ACAPI, params: ACRequestParameters)->ACRestfulAPI{
        return ACRestfulAPI(API: api, params: params)
    }
    
    override func setup(API api: ACAPI, params: ACRequestParameters) {
        self.restfulAPI = RestfulAPI(API: api.api, params: params.requestParameters())
        self.apiCaller = self.restfulAPI
    }
    
    public func addJSONResponseHandler(handler:@convention(block)(JSONObject: AnyObject?, response: NSURLResponse?)->Void){
        
        self.restfulAPI.addJSONResponseHandler { (JSONObject, connection) in
            handler(JSONObject: JSONObject, response: connection.response)
        }
        
    }
    
    public func addTextResponseHandler(handler:@convention(block)(text: String, response: NSURLResponse?)->Void){
        self.restfulAPI.addTextResponseHandler { (text, connection) in
            handler(text: text, response: connection.response)
        }
    }
}
