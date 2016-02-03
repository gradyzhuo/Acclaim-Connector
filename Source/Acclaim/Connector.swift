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
        
    }
    
}