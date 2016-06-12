//
//  API.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

/**
 RequestTaskType to assign how API be sended through DataTask(Normal), DownloadTask or UploadTask.
 */
public struct RequestTaskType {
    internal var infoObject: AnyObject?
    internal var identifier: String
    
    internal init(identifier: String, infoObject: AnyObject? = nil){
        self.infoObject = infoObject
        self.identifier = identifier
    }
    
    /**
     Type of DataTask to handle normal API request.
     */
    public static var DataTask:RequestTaskType{
        return RequestTaskType(identifier: "DataTask")
    }
    
    
    /**
     Type of DownloadTask to handle normal API request.
     */
    public static var DownloadTask:RequestTaskType{
        return RequestTaskType(identifier: "DownloadTask", infoObject: nil)
    }
    
    /**
     Return a Type of DownloadTask to handle normal API request.
     - parameters:
        - resumeData: It can be resume a downloadTask with previous result's data by pausing. (required)
     - returns: DownloadTask's RequestTaskType.
     */
    public static func DownloadTask(resumeData: NSData?)->RequestTaskType{
        return RequestTaskType(identifier: "DownloadTask", infoObject: resumeData)
    }
    
    /**
     Type of UploadTask to handle normal API request.
     */
    public static var UploadTask:RequestTaskType {
        return RequestTaskType(identifier: "UploadTask")
    }
    
    /**
     Type of UploadTask to handle normal API request.
     */
    internal static var StreamTask:RequestTaskType {
        return RequestTaskType(identifier: "StreamTask")
    }
    
    /**
     Return a Type of StreamTask to handle normal API request.
     - parameters:
        - netService: It can be resume a downloadTask with previous result's data by pausing. (required)
     - returns: DownloadTask's RequestTaskType.
     */
    public static func StreamTask(service: NSNetService)->RequestTaskType{
        return RequestTaskType(identifier: "StreamTask", infoObject: service)
    }
    
}

public func ==(lhs: RequestTaskType, rhs: RequestTaskType)->Bool{
    return lhs.identifier == rhs.identifier
}

public class  API : StringLiteralConvertible {
    
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    public internal(set) var apiURL:NSURL
    
    /**  Convenience property from RequestTaskType. (readonly) */
    public var method: HTTPMethod = .GET
    
//    public var requestTaskType: RequestTaskType = .DataTask(method: .GET)
    public var timeoutInterval:NSTimeInterval = 30
    
    public var cachePolicy:NSURLRequestCachePolicy = .useProtocolCachePolicy
    
    public var HTTPHeaderFields:[String: String] = [:]
    public internal(set) var cookies:[NSHTTPCookie] = []
    
    /** The property `request` will be generated after getRequest() is called. default value is nil. (readonly) */
    public internal(set) var request: NSURLRequest?
    internal var requestConfigurationHandler: (request: NSMutableURLRequest)->Void = { _ in }
    
    public convenience init(api:String, host:NSURL! = Acclaim.hostURLFromInfoDictionary(), method: HTTPMethod = .GET) throws {
        
        
        guard let validHostURL = host else {
            
            let reason = "Error: [Host URL] is not found."
            let recoverSuggestion = "Please assign your api host url, or setup '\(Acclaim.Configuration.defaultHostURLInfoKey)' into your project info.plist."
            
            throw NSError(domain: "API.Constructor", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:reason, NSLocalizedRecoverySuggestionErrorKey:recoverSuggestion])
        }
        
        let apiURL = validHostURL.appendingPathComponent(api)
        
        self.init(URL: apiURL, method: method)
        
    }
    
    public init(URL:NSURL, method: HTTPMethod){
        self.apiURL = URL
        self.method = method
        
        for cookie in NSHTTPCookieStorage.shared().cookies ?? [] where cookie.domain == URL.host!{
            _ = self.addHTTPCookie(cookie: cookie)
        }
        
    }
    
    public convenience init(URLString string: String, method:HTTPMethod = .GET) throws {
        guard let URL = NSURL(string: string) else {
            throw NSError(domain: "API.From.URLString", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"The API can't be construct by URLString(\(string))"])
        }
        
        self.init(URL: URL, method: method)
    }
    
    public required convenience init(stringLiteral value: StringLiteralType) {
        
        if let components = NSURLComponents(string: value) where components.scheme != nil, let url = components.url  {
            self.init(URL: url, method: .GET)
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
    public func addSimpleHTTPCookie(name:String, value: String)->NSHTTPCookie?{
        let properties = [NSHTTPCookieName:name, NSHTTPCookieValue:value, NSHTTPCookieDomain:self.apiURL.host ?? "", NSHTTPCookieOriginURL:self.apiURL.absoluteString, NSHTTPCookiePath:self.apiURL.path ?? "", NSHTTPCookieVersion:"0"]
        guard let cookie = NSHTTPCookie(properties: properties) else {
            return nil
        }
        
        _ = self.addHTTPCookie(cookie: cookie)
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
    
    public func generateRequest(parameters params: Parameters, configuration: Acclaim.Configuration)->NSMutableURLRequest {
        
        let request:NSMutableURLRequest = NSMutableURLRequest(url: self.apiURL, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        
        let body = self.method.serializer.serialize(params: params)
        
        if let body = body where self.method == HTTPMethod.GET {
            let components = NSURLComponents(url
                : self.apiURL, resolvingAgainstBaseURL: false)
            components?.query = String(data: body, encoding: NSUTF8StringEncoding)
            request.url = (components?.url)!
        }else{
            request.httpBody = body
        }
        
        request.httpMethod = self.method.rawValue
        request.allowsCellularAccess = configuration.allowsCellularAccess
        
        for field in NSHTTPCookie.requestHeaderFields(with: self.cookies){
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
        return request
    }
}

//
//extension API : Hashable {
//    public var hashValue: Int {
//        return self.identifier.hashValue
//    }
//}
//public func ==(lhs:API, rhs:API)->Bool{
//    return lhs.hashValue == rhs.hashValue
//}