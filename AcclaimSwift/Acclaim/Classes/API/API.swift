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
    public static func DownloadTask(resumeData: Data?)->RequestTaskType{
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
    public static func StreamTask(_ service: NetService)->RequestTaskType{
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
    
    public internal(set) var apiURL:URL
    
    /**  Convenience property from RequestTaskType. (readonly) */
    public var method: Method = .get
    
//    public var requestTaskType: RequestTaskType = .DataTask(method: .GET)
    public var timeoutInterval:TimeInterval = 30
    
    public var cachePolicy:NSURLRequest.CachePolicy = .useProtocolCachePolicy
    
    public var HTTPHeaderFields:[String: String] = [:]
    public internal(set) var cookies:[HTTPCookie] = []
    
    /** The property `request` will be generated after getRequest() is called. default value is nil. (readonly) */
    public internal(set) var request: URLRequest?
    internal var requestConfigurationHandler: (request: URLRequest)->Void = { _ in }
    
    public convenience init(api:String, host:URL! = Acclaim.hostURLFromInfoDictionary(), method: Method = .get) throws {
        
        
        guard let validHostURL = host else {
            
            let reason = "Error: [Host URL] is not found."
            let recoverSuggestion = "Please assign your api host url, or setup '\(Acclaim.Configuration.defaultHostURLInfoKey)' into your project info.plist."
            
            throw NSError(domain: "API.Constructor", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:reason, NSLocalizedRecoverySuggestionErrorKey:recoverSuggestion])
        }
        
        let apiURL = try! validHostURL.appendingPathComponent(api)
        
        self.init(URL: apiURL, method: method)
        
    }
    
    public init(URL:Foundation.URL, method: Method){
        self.apiURL = URL
        self.method = method
        
        for cookie in HTTPCookieStorage.shared().cookies ?? [] where cookie.domain == URL.host!{
            _ = self.add(cookie: cookie)
        }
        
    }
    
    public convenience init(URLString string: String, method:Method = .get) throws {
        guard let URL = URL(string: string) else {
            throw NSError(domain: "API.From.URLString", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"The API can't be construct by URLString(\(string))"])
        }
        
        self.init(URL: URL, method: method)
    }
    
    public required convenience init(stringLiteral value: StringLiteralType) {
        
        if let components = URLComponents(string: value) where components.scheme != nil, let url = components.url  {
            self.init(URL: url, method: .get)
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
    
    public func configRequest(_ handler: (request: URLRequest)->Void) {
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
    public func addSimpleHTTPCookie(name:String, value: String)->HTTPCookie?{
        let properties:[HTTPCookiePropertyKey:AnyObject] = [
            .name:name,
            .value:value,
            .domain:self.apiURL.host ?? "",
            .originURL:self.apiURL,
            .path:self.apiURL.path ?? "",
            .version:"0"
        ]
        
        guard let cookie = HTTPCookie(properties: properties) else {
            return nil
        }
        
        _ = self.add(cookie: cookie)
        return cookie
    }
    
    /**
     add the cookie object of NSHTTPCookie.
     - parameters:
     - cookie: the instance of NSHTTPCookie.
     - returns: API.
     */
    public func add(cookie: HTTPCookie)->Self{
        self.cookies.append(cookie)
        return self
    }
}

extension API {
    
    public func generateRequest(parameters params: Parameters, configuration: Acclaim.Configuration)->URLRequest {
        
        var request:URLRequest = URLRequest(url: self.apiURL, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        
        let body = self.method.serializer.serialize(params: params)
        
        if let body = body where self.method == .get {
            var components = URLComponents(url
                : self.apiURL, resolvingAgainstBaseURL: false)
            components?.query = String(data: body as Data, encoding: String.Encoding.utf8)
            request.url = (components?.url)!
        }else{
            request.httpBody = body
        }
        
        request.httpMethod = self.method.rawValue
        request.allowsCellularAccess = configuration.allowsCellularAccess
        
        for field in HTTPCookie.requestHeaderFields(with: self.cookies){
            request.addValue(field.1, forHTTPHeaderField: field.0)
        }
        
        API.HTTPHeaderFieldsForAllRequest.forEach { (key:String, value: String) -> () in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        self.HTTPHeaderFields.forEach { (key:String, value: String) -> () in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        self.requestConfigurationHandler(request: request)
        
        self.request = request
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
