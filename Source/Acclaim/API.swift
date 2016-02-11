//
//  API.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public enum RequestTaskType {
    case DataTask
    case DownloadTask(resumeData: NSData?)
    case UploadTask(data: NSData)
}

public class  API : StringLiteralConvertible {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    public internal(set) var apiURL:NSURL
    
    public var method:HTTPMethod = .GET
    public var requestTaskType: RequestTaskType = .DataTask
    public var timeoutInterval:NSTimeInterval = 30
    
    public var cachePolicy:NSURLRequestCachePolicy = .UseProtocolCachePolicy
    
    public var HTTPHeaderFields:[String: String] = [:]
    public internal(set) var cookies:[NSHTTPCookie] = []
    
    internal var identifier: String = String(NSDate().timeIntervalSince1970)
    
    /** the request will be generated after getRequest() is called. default value is nil. (readonly) */
    public internal(set) var request: NSURLRequest?
    internal var requestConfigurationHandler: (request: NSMutableURLRequest)->Void = { _ in }
    
    public convenience init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method:HTTPMethod = .GET) throws {
        
        guard let validHostURL = host else {
            
            let reason = "Error: [Host URL] is not found."
            let recoverSuggestion = "Please assign your api host url, or setup '\(ACAPIHostURLInfoKey)' into your project info.plist."
            
            throw NSError(domain: "API.Constructor", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:reason, NSLocalizedRecoverySuggestionErrorKey:recoverSuggestion])
        }
        
        let apiURL = validHostURL.URLByAppendingPathComponent(api)
        
        self.init(URL: apiURL, method: method)
        
    }

    public init(URL:NSURL, method:HTTPMethod = .GET){
        self.apiURL = URL
        self.method = method
        
        for cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies ?? [] where cookie.domain == URL.host!{
            self.addHTTPCookie(cookie)
        }
        
    }
    
    public required convenience init(stringLiteral value: StringLiteralType) {
        
        if let components = NSURLComponents(string: value) where components.scheme != nil, let url = components.URL  {
            self.init(URL: url)
        }else{
            try! self.init(api: value)
        }
        
    }
    
    /// Create an instance initialized to `value`.
    public required convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    /// Create an instance initialized to `value`.
    public required convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
}


extension API {
    
    public static var HTTPHeaderFieldsForAllRequest:[String: String] = [:]
    
    public func configRequest(handler: (request: NSMutableURLRequest)->Void) {
        self.requestConfigurationHandler = handler
    }
    
}


//MARK: - Handle HTTPCookies
extension API {
    /**
     add the simple string cookie.
     - parameters:
        - name: the name of cookie.
        - value: the value of cookie.
     - returns: object of NSHTTPCookie. (Optional)
     */
    public func addSimpleHTTPCookie(name name:String, value: String)->NSHTTPCookie?{
        let properties = [NSHTTPCookieName:name, NSHTTPCookieValue:value, NSHTTPCookieDomain:self.apiURL.host ?? "", NSHTTPCookieOriginURL:self.apiURL.absoluteString, NSHTTPCookiePath:self.apiURL.path ?? "", NSHTTPCookieVersion:"0"]
        guard let cookie = NSHTTPCookie(properties: properties) else {
            return nil
        }
        
        self.addHTTPCookie(cookie)
        return cookie
    }
    
    /**
     add the cookie object of NSHTTPCookie.
     - parameters:
     - cookie: the instance of NSHTTPCookie.
     - returns: API.
     */
    public func addHTTPCookie(cookie: NSHTTPCookie)->Self{
        self.cookies.append(cookie)
        return self
    }
}

extension API {
    
    /**
     .
     - parameters:
     - cookie: the instance of NSHTTPCookie.
     - returns: API.
     */
    internal func generateRequest(params: RequestParameters)->NSURLRequest {
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: self.apiURL, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        
        let body = self.method.serializer.serialize(params)
        
        if let body = body where self.method == HTTPMethod.GET {
            let components = NSURLComponents(URL: self.apiURL, resolvingAgainstBaseURL: false)
            components?.query = String(data: body, encoding: NSUTF8StringEncoding)
            request.URL = (components?.URL)!
        }else{
            request.HTTPBody = body
        }
        
        request.HTTPMethod = self.method.rawValue
        request.allowsCellularAccess = Acclaim.allowsCellularAccess
        
        for field in NSHTTPCookie.requestHeaderFieldsWithCookies(self.cookies){
            request.addValue(field.1, forHTTPHeaderField: field.0)
        }
        
        API.HTTPHeaderFieldsForAllRequest.forEach { (key:String, value: String) -> () in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        self.HTTPHeaderFields.forEach { (key:String, value: String) -> () in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        self.requestConfigurationHandler(request: request)
        
        self.request = request.copy() as? NSURLRequest
        return self.request!
        
    }
    
}


extension API : Hashable {
    public var hashValue: Int {
        return self.identifier.hashValue
    }
}

public func ==(lhs:API, rhs:API)->Bool{
    return lhs.hashValue == rhs.hashValue
}