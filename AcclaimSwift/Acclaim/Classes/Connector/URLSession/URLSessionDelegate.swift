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
        
        task.completionHandler?(task: task, response: task.response, error: error)
        task.removeAllAssociatedObjects()
    }
}

extension URLSessionDelegate : NSURLSessionTaskDelegate {
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        if let processableCaller = task.apiCaller as? SendingProcessHandlable {
            let handler = processableCaller.sendingProcessHandler
            handler?(bytes: bytesSent, totalBytes: totalBytesSent, totalBytesExpected: totalBytesExpectedToSend)
        }
        
        
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
    
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        dataTask.data.appendData(data)
        
        let countOfBytesReceived = dataTask.countOfBytesReceived
        let countOfBytesExpectedToReceive = dataTask.countOfBytesExpectedToReceive > 0 ? dataTask.countOfBytesExpectedToReceive : countOfBytesReceived
        
        if let processableCaller = dataTask.apiCaller as? RecevingProcessHandlable {
            let handler = processableCaller.recevingProcessHandler
            handler?(bytes: Int64(data.length), totalBytes: countOfBytesReceived, totalBytesExpected: countOfBytesExpectedToReceive)
        }
        
        
    }
    
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        guard let MIME = response.MIMEType else{
            completionHandler(.Cancel)
            return
        }
        
        do{
            let type = try MIMEType(MIME: MIME)
            
            if let MIMECaller = dataTask.apiCaller as? MIMESupport {
                
                if MIMECaller.allowedMIMEs.contains(type) && type.isKindOf(otherMIME: .Image, .Audio, .Video) {
                    debugPrint("[MIMEType(\(MIME))]: BecomeDownloadTask")
                    completionHandler(.BecomeDownload)
                }else if MIMECaller.allowedMIMEs.contains(type){
                    completionHandler(.Allow)
                }else{
                    completionHandler(.Cancel)
                }
                
            }else{
                completionHandler(.Allow)
            }
        }catch{
            debugPrint("[didReceiveResponse] MIMEType(\(MIME)) is not correct, error: \(error)")
            completionHandler(.Allow)
        }
        
        
        
    }
    
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
        
        downloadTask.apiCaller = dataTask.apiCaller
        downloadTask.completionHandler = dataTask.completionHandler
        
        dataTask.apiCaller = nil
        dataTask.completionHandler = nil
        
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
        
        let data = NSMutableData(contentsOfURL: location)
        downloadTask.data = data ?? NSMutableData()
        
    }
    
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let processableCaller = downloadTask.apiCaller as? RecevingProcessHandlable {
            let handler = processableCaller.recevingProcessHandler
            handler?(bytes: bytesWritten, totalBytes: totalBytesWritten, totalBytesExpected: totalBytesExpectedToWrite)
        }
    }
    
    internal func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("didResumeAtOffset:\(fileOffset)")
    }
    
}

/*
extension URLSessionDelegate : NSURLSessionStreamDelegate, NSStreamDelegate{
    internal func URLSession(session: NSURLSession, readClosedForStreamTask streamTask: NSURLSessionStreamTask){
        print("readClosedForStreamTask")
        
    }

    internal func URLSession(session: NSURLSession, writeClosedForStreamTask streamTask: NSURLSessionStreamTask){
        print("writeClosedForStreamTask")
    }
    
    internal func URLSession(session: NSURLSession, betterRouteDiscoveredForStreamTask streamTask: NSURLSessionStreamTask){
        print("betterRouteDiscoveredForStreamTask")
    }
    
    internal func URLSession(session: NSURLSession, streamTask: NSURLSessionStreamTask, didBecomeInputStream inputStream: NSInputStream, outputStream: NSOutputStream){
        print("didBecomeInputStream")
        
        
        
        inputStream.delegate = self
        inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream.open()
        
        print("inputStream.has:\(inputStream.hasBytesAvailable)")
        print("outputStream.hasSpaceAvailable:\(outputStream.hasSpaceAvailable)")
        
        
    }
    
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        print("InputStreamHandler here")
    }
}
*/
