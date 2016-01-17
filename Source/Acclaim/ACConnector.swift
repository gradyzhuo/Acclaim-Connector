//
//  ACConnector.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias ResponseHandler = (data: NSData?, response: NSURLResponse?, error: NSError?)->Void


public protocol Connector {
    
    init()
    mutating func sendRequest(request: NSURLRequest, handler: ResponseHandler)
    
}

internal protocol _Connector : Connector {
    var responseHandler: ResponseHandler? { set get }
}



extension _Connector {
    
    mutating func addResponseHandler(handler: ResponseHandler){
        self.responseHandler = handler
    }
    
}


public struct URLSession : _Connector {
    
    internal var responseHandler: ResponseHandler?
    
    public init(){
        
    }
    
    public mutating func sendRequest(request: NSURLRequest, handler: ResponseHandler) {
        
        self.addResponseHandler(handler)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            handler(data: data, response: response, error: error)
        }.resume()
        
//        let error:ErrorType? = nil
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 3)), dispatch_get_global_queue(0, 0), { () -> Void in
//            
//            let URLResponse = NSURLResponse(URL: request.URL ?? NSURL(), MIMEType: "text/json", expectedContentLength: 0, textEncodingName: "UTF-8")
//            let data:NSData! = "{\"key\":\"我\"}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
//            
//            self.responseHandler?(data: data, response: URLResponse, error: error as? NSError)
//            
//            
//        })
//        
        
    }
    
}