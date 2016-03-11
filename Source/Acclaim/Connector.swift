//
//  ACConnector.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias ProcessHandler = (bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64)->Void
public typealias ResponseHandler = (data: NSData?, response: NSURLResponse?, error: NSError?)->Void

public class Handler<Type> {
    internal typealias HandlerType = Type
    
    internal let handler:HandlerType?
    internal init(_ handler: HandlerType?){
        self.handler = handler
    }
}

private let kRecevingProcessHandler = unsafeAddressOf("kProcessHandler")
private let kSendingProcessHandler = unsafeAddressOf("kProcessHandler")
private let kCompletionHandler = unsafeAddressOf("kCompletionHandler")
private let kData = unsafeAddressOf("kData")

extension NSURLSessionTask {
    typealias ResponseHandlerType = Handler<ResponseHandler>
    
    internal var sendingProcessHandler: ProcessHandler? {
        set{
            let handler = Handler<ProcessHandler>(newValue)
            objc_setAssociatedObject(self, kSendingProcessHandler, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let handler = objc_getAssociatedObject(self, kSendingProcessHandler) as? Handler<ProcessHandler>
            return handler?.handler
        }
    }
    
    internal var receivingProcessHandler: ProcessHandler? {
        set{
            let handler = Handler<ProcessHandler>(newValue)
            objc_setAssociatedObject(self, kRecevingProcessHandler, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let handler = objc_getAssociatedObject(self, kRecevingProcessHandler) as? Handler<ProcessHandler>
            return handler?.handler
        }
    }
    
    internal var completionHandler:ResponseHandlerType.HandlerType? {
        set{
            let handler = Handler<ResponseHandler>(newValue)
            objc_setAssociatedObject(self, kCompletionHandler, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let handler = objc_getAssociatedObject(self, kCompletionHandler) as? ResponseHandlerType
            return handler?.handler
        }
    }
    
    
    private var data:NSMutableData {
        
        set{
            objc_setAssociatedObject(self, kData, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get{
            guard let data = objc_getAssociatedObject(self, kData) as? NSMutableData else {
                self.data = NSMutableData()
                return self.data
            }
            return data
        }
        
    }
    
}




public protocol Connector : class {

    func generateTask(api: API, params: RequestParameters, completionHandler handler: ResponseHandler) -> NSURLSessionTask
}

internal protocol _Connector : Connector {
    
}

extension Connector {
    
    internal func handle(task:NSURLSessionTask) {
        task.resume()
    }
    
    internal func sendRequest(api: API, params: RequestParameters, completionHandler handler: ResponseHandler) -> NSURLSessionTask? {
        
        let task:NSURLSessionTask = self.generateTask(api, params: params, completionHandler: handler)

        defer{
            self.handle(task)
        }
        
        return task
    }

}


public class ACURLSession : NSObject, _Connector {
    
    public internal(set) var session: NSURLSession!
    
    public internal(set) var configuration:NSURLSessionConfiguration = .defaultSessionConfiguration()
    public internal(set) var delegateQueue:NSOperationQueue = NSOperationQueue.mainQueue()
    
    public required override init(){
        super.init()

        let delegate = URLSessionDelegate(session: self)
        self.session = NSURLSession(configuration: self.configuration, delegate: delegate, delegateQueue: self.delegateQueue)
    }
    
    init(configuration: NSURLSessionConfiguration) {
        super.init()
        
        let delegate = URLSessionDelegate(session: self)
        self.session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: self.delegateQueue)
    }
    
    public func generateTask(api: API, params: RequestParameters, completionHandler handler: ResponseHandler) -> NSURLSessionTask {
        
        let taskType = api.requestTaskType
        
        let task:NSURLSessionTask
        if case let .DownloadTask(_, resumeData) = taskType {
            
            let request = api.generateRequest(params)
            
            if let resumeData = resumeData {
                task = self.session.downloadTaskWithResumeData(resumeData)
            }else{
                task = self.session.downloadTaskWithRequest(request)
            }
            
        }else if case let .UploadTask = taskType {
            
            let serializer = MultipartFormSerializer()
            let uploadData = params.serialize(serializer) ?? NSData()
            
            let request = api.generateRequest().mutableCopy() as! NSMutableURLRequest
            request.setValue("\(uploadData.length)", forHTTPHeaderField: "Content-Length")
            
            let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
            let contentType = "multipart/form-data; charset=\(charset); boundary=\(serializer.boundary)"
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            task = self.session.uploadTaskWithRequest(request, fromData: uploadData)
            
        }else{
            
            let request = api.generateRequest(params)
            //FIXME: 如果要使用Delegate，就一定要使用沒有CompletionHandler的版本
            task = self.session.dataTaskWithRequest(request)
        }
        
        task.completionHandler = handler
        return task
    }

    deinit{
        ACDebugLog("URLSession : [\(unsafeAddressOf(self))] deinit")
    }
}


//MARK: -
public class URLSessionDelegate : NSObject {
    
    weak var session:ACURLSession?
    
    init(session: ACURLSession) {
        self.session = session
    }
    
    deinit{
        ACDebugLog("URLSessionDelegate : [\(unsafeAddressOf(self))] deinit")
    }
    
}

extension URLSessionDelegate : NSURLSessionDelegate {
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        task.completionHandler?(data: task.data.copy() as? NSData, response: task.response, error: error)
    }
}

extension URLSessionDelegate : NSURLSessionTaskDelegate {
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        task.sendingProcessHandler?(bytes: bytesSent, totalBytes: totalBytesSent, totalBytesExpected: totalBytesExpectedToSend)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        completionHandler(request)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream?) -> Void) {
        //FIXME: 還沒有BodyStream
        completionHandler(nil)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, nil)
    }
    
}

extension URLSessionDelegate : NSURLSessionDataDelegate {
    
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, nil)
    }
    
    
//    /* number of body bytes already received */
//    public var countOfBytesReceived: Int64 { get }
//    
//    /* number of body bytes already sent */
//    public var countOfBytesSent: Int64 { get }
//    
//    /* number of body bytes we expect to send, derived from the Content-Length of the HTTP request */
//    public var countOfBytesExpectedToSend: Int64 { get }
//    
//    /* number of byte bytes we expect to receive, usually derived from the Content-Length header of an HTTP response. */
//    public var countOfBytesExpectedToReceive: Int64 { get }
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        dataTask.data.appendData(data)
        
        let countOfBytesReceived = dataTask.countOfBytesReceived
        let countOfBytesExpectedToReceive = dataTask.countOfBytesExpectedToReceive > 0 ? dataTask.countOfBytesExpectedToReceive : countOfBytesReceived
        
        dataTask.receivingProcessHandler?(bytes: Int64(data.length), totalBytes: countOfBytesReceived, totalBytesExpected: countOfBytesExpectedToReceive)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        print("\(response.MIMEType)")
        completionHandler(.Allow)
        
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
        print("here didBecomeDownloadTask", self.session)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeStreamTask streamTask: NSURLSessionStreamTask) {
        
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, willCacheResponse proposedResponse: NSCachedURLResponse, completionHandler: (NSCachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }
    
}

extension URLSessionDelegate : NSURLSessionDownloadDelegate {
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        downloadTask.completionHandler?(data: NSData(contentsOfURL: location), response: downloadTask.response, error: downloadTask.error)
    }
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        downloadTask.receivingProcessHandler?(bytes: bytesWritten, totalBytes: totalBytesWritten, totalBytesExpected: totalBytesExpectedToWrite)
    }
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("didResumeAtOffset here")
    }
    
}


