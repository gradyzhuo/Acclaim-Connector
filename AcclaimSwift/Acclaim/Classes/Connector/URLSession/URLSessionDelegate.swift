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
        ACDebugLog(log: "URLSessionDelegate : [\(unsafeAddress(of: self))] deinit")
    }
    
}

extension URLSessionDelegate : NSURLSessionDelegate {
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        task.completionHandler?(task: task, response: task.response, error: error)
        task.removeAllAssociatedObjects()
    }
}

extension URLSessionDelegate : NSURLSessionTaskDelegate {
    
    internal func urlSession(_ session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        if let processableCaller = task.apiCaller as? SendingProcessHandlable {
            let handler = processableCaller.sendingProcessHandler
            handler?(bytes: bytesSent, totalBytes: totalBytesSent, totalBytesExpected: totalBytesExpectedToSend)
        }
        
        
    }
    
    internal func urlSession(_ session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        completionHandler(request)
    }
    
    internal func urlSession(_ session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream?) -> Void) {
        //FIXME: 還沒有BodyStream
        completionHandler(nil)
    }
    
    internal func urlSession(_ session: NSURLSession, task: NSURLSessionTask, didReceive challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.useCredential, nil)
    }
    
}

extension URLSessionDelegate : NSURLSessionDataDelegate {
    
    internal func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.useCredential, challenge.proposedCredential)
    }
    
    internal func urlSession(_ session: NSURLSession, dataTask: NSURLSessionDataTask, didReceive data: NSData) {
        
        dataTask.data.append(data)
        
        let countOfBytesReceived = dataTask.countOfBytesReceived
        let countOfBytesExpectedToReceive = dataTask.countOfBytesExpectedToReceive > 0 ? dataTask.countOfBytesExpectedToReceive : countOfBytesReceived
        
        if let processableCaller = dataTask.apiCaller as? RecevingProcessHandlable {
            let handler = processableCaller.recevingProcessHandler
            handler?(bytes: Int64(data.length), totalBytes: countOfBytesReceived, totalBytesExpected: countOfBytesExpectedToReceive)
        }
        
        
    }
    
    internal func urlSession(_ session: NSURLSession, dataTask: NSURLSessionDataTask, didReceive response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        guard let MIME = response.mimeType else{
            completionHandler(.cancel)
            return
        }
        
        do{
            let type = try MIMEType(MIME: MIME)
            
            if let MIMECaller = dataTask.apiCaller as? MIMESupport {
                
                if MIMECaller.allowedMIMEs.contains(element: type) && type.isKindOf(otherMIME: .Image, .Audio, .Video) {
                    debugPrint("[MIMEType(\(MIME))]: BecomeDownloadTask")
                    completionHandler(.becomeDownload)
                }else if MIMECaller.allowedMIMEs.contains(element: type){
                    completionHandler(.allow)
                }else{
                    completionHandler(.cancel)
                }
                
            }else{
                completionHandler(.allow)
            }
        }catch{
            debugPrint("[didReceiveResponse] MIMEType(\(MIME)) is not correct, error: \(error)")
            completionHandler(.allow)
        }
        
        
        
    }
    
    internal func urlSession(_ session: NSURLSession, dataTask: NSURLSessionDataTask, didBecome downloadTask: NSURLSessionDownloadTask) {
        
        downloadTask.apiCaller = dataTask.apiCaller
        downloadTask.completionHandler = dataTask.completionHandler
        
        dataTask.apiCaller = nil
        dataTask.completionHandler = nil
        
        print("here didBecomeDownloadTask", self.session)
    }
    
    internal func urlSession(_ session: NSURLSession, dataTask: NSURLSessionDataTask, didBecome streamTask: NSURLSessionStreamTask) {
        
    }
    
    internal func urlSession(_ session: NSURLSession, dataTask: NSURLSessionDataTask, willCacheResponse proposedResponse: NSCachedURLResponse, completionHandler: (NSCachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }
    
}

extension URLSessionDelegate : NSURLSessionDownloadDelegate {
    
    internal func urlSession(_ session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingTo location: NSURL) {
        
        let data = NSMutableData(contentsOf: location)
        downloadTask.data = data ?? NSMutableData()
        
    }
    
    internal func urlSession(_ session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let processableCaller = downloadTask.apiCaller as? RecevingProcessHandlable {
            let handler = processableCaller.recevingProcessHandler
            handler?(bytes: bytesWritten, totalBytes: totalBytesWritten, totalBytesExpected: totalBytesExpectedToWrite)
        }
    }
    
    internal func urlSession(_ session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
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
