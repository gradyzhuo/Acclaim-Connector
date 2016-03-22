//
//  URLSessionDelegate.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/17/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

internal typealias ACURLSession = URLSession
//MARK: -
internal class URLSessionDelegate : NSObject {
    
    weak var session:ACURLSession?
    
    init(session: ACURLSession) {
        self.session = session
    }
    
    deinit{
        ACDebugLog("URLSessionDelegate : [\(unsafeAddressOf(self))] deinit")
    }
    
}

extension URLSessionDelegate : NSURLSessionDelegate {
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        let data = task.data.copy() as? NSData
        let connection = Connection(originalRequest: task.originalRequest, currentRequest: task.currentRequest, response: task.response, cached: false)
        task.completionHandler?(data: data, connection: connection, error: error)
    }
}

extension URLSessionDelegate : NSURLSessionTaskDelegate {
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        task.apiCaller?.sendingProcessHandler?(bytes: bytesSent, totalBytes: totalBytesSent, totalBytesExpected: totalBytesExpectedToSend)
    }
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        completionHandler(request)
    }
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream?) -> Void) {
        //FIXME: 還沒有BodyStream
        completionHandler(nil)
    }
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, nil)
    }
    
}

extension URLSessionDelegate : NSURLSessionDataDelegate {
    
    internal func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.UseCredential, challenge.proposedCredential)
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
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        dataTask.data.appendData(data)
        
        let countOfBytesReceived = dataTask.countOfBytesReceived
        let countOfBytesExpectedToReceive = dataTask.countOfBytesExpectedToReceive > 0 ? dataTask.countOfBytesExpectedToReceive : countOfBytesReceived
        
        dataTask.apiCaller?.receivingProcessHandler?(bytes: Int64(data.length), totalBytes: countOfBytesReceived, totalBytesExpected: countOfBytesExpectedToReceive)
    }
    
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        print("\(response.MIMEType)")
        completionHandler(.Allow)
        
    }
    
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
        print("here didBecomeDownloadTask", self.session)
    }
    
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeStreamTask streamTask: NSURLSessionStreamTask) {
        
    }
    
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, willCacheResponse proposedResponse: NSCachedURLResponse, completionHandler: (NSCachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }
    
}

extension URLSessionDelegate : NSURLSessionDownloadDelegate {
    
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data = NSData(contentsOfURL: location)
        let connection = Connection(originalRequest: downloadTask.originalRequest, currentRequest: downloadTask.currentRequest, response: downloadTask.response, cached: false)
        downloadTask.completionHandler?(data: data, connection: connection, error: downloadTask.error)
    }
    
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        downloadTask.apiCaller?.receivingProcessHandler?(bytes: bytesWritten, totalBytes: totalBytesWritten, totalBytesExpected: totalBytesExpectedToWrite)
    }
    
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("didResumeAtOffset here")
    }
    
}
