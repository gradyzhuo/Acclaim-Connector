//
//  protocol.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/19/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Connection {
    associatedtype ResponseType:NSURLResponse
    
    var request: NSURLRequest { get }
    var response: Self.ResponseType { get }
    var cached: Bool { get }
    
    init(request: NSURLRequest, response: Self.ResponseType, cached: Bool)
}

public struct GenericConnection: Connection {
    public typealias ResponseType = NSURLResponse
    
    public internal(set) var request: NSURLRequest
    public internal(set) var response: GenericConnection.ResponseType
    public internal(set) var cached: Bool
    
    public init(request: NSURLRequest, response: GenericConnection.ResponseType, cached: Bool) {
        self.request = request
        self.response = response
        self.cached = cached
    }
}

public struct HTTPConnection : Connection {
    public typealias ResponseType = NSHTTPURLResponse
    
    public internal(set) var request: NSURLRequest
    public internal(set) var response: HTTPConnection.ResponseType
    public internal(set) var cached: Bool
    
    public init(request: NSURLRequest, response: HTTPConnection.ResponseType, cached: Bool) {
        self.request = request
        self.response = response
        self.cached = cached
    }
}