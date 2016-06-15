//
//  protocol.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/19/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

internal protocol _Connection {
    associatedtype ResponseType:URLResponse
    
    var currentRequest: URLRequest! { get }
    var originalRequest: URLRequest! { get }
    var requestMIMEs: [MIMEType] { get }
    var responseMIME: MIMEType? { get }
    
    var response: Self.ResponseType? { get }
    var cached: Bool { get }
    
    init(originalRequest request: URLRequest?, currentRequest:URLRequest?, response: ResponseType?, requestMIMEs:[MIMEType], cached: Bool)
}

public struct Connection: _Connection {
    public typealias ResponseType = URLResponse
    
    public internal(set) var currentRequest: URLRequest!
    public internal(set) var originalRequest: URLRequest!
    
    public internal(set) var response: ResponseType?
    public internal(set) var cached: Bool
    
    public internal(set) var requestMIMEs: [MIMEType]
    public internal(set) var responseMIME: MIMEType?
    
    internal init(originalRequest request: URLRequest?, currentRequest:URLRequest?, response: ResponseType?, requestMIMEs:[MIMEType], cached: Bool) {
        self.originalRequest = request
        self.currentRequest = request
        
        self.response = response
        self.cached = cached
        
        self.requestMIMEs = requestMIMEs
        if let MIMEString = self.response?.mimeType, let MIME = try? MIMEType(MIME: MIMEString) {
            self.responseMIME = MIME
        }
    }
}
