//
//  protocol.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/19/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

internal protocol _Connection {
    associatedtype ResponseType:NSURLResponse
    
    var currentRequest: NSURLRequest! { get }
    var originalRequest: NSURLRequest! { get }
    
    var response: Self.ResponseType? { get }
    var cached: Bool { get }
    
    init(originalRequest request: NSURLRequest?, currentRequest:NSURLRequest?, response: ResponseType?, cached: Bool)
}

public struct Connection: _Connection {
    public typealias ResponseType = NSURLResponse
    
    public internal(set) var currentRequest: NSURLRequest!
    public internal(set) var originalRequest: NSURLRequest!
    
    public internal(set) var response: ResponseType?
    public internal(set) var cached: Bool
    
    public init(originalRequest request: NSURLRequest?, currentRequest:NSURLRequest?, response: ResponseType?, cached: Bool) {
        self.originalRequest = request
        self.currentRequest = request
        
        self.response = response
        self.cached = cached
    }
}

//public struct HTTPConnection : Connection {
//    public typealias ResponseType = NSHTTPURLResponse
//    
//    public internal(set) var request: NSURLRequest
//    public internal(set) var response: HTTPConnection.ResponseType
//    public internal(set) var cached: Bool
//    
//    public init(request: NSURLRequest, response: HTTPConnection.ResponseType, cached: Bool) {
//        self.request = request
//        self.response = response
//        self.cached = cached
//    }
//}