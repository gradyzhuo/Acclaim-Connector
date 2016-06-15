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
        Debug(log: "URLSessionDelegate : [\(unsafeAddress(of: self))] deinit")
    }
    
}

extension URLSessionDelegate : Foundation.URLSessionDelegate {
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        
        task.completionHandler?(task: task, response: task.response, error: error)
        task.removeAllAssociatedObjects()
    }
}

extension URLSessionDelegate : URLSessionTaskDelegate {
    
    internal func urlSession(_ session: Foundation.URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        if let processableCaller = task.apiCaller as? SendingProcessHandlable {
            let handler = processableCaller.sendingProcessHandler
            handler?(bytes: bytesSent, totalBytes: totalBytesSent, totalBytesExpected: totalBytesExpectedToSend)
        }
        
        
    }
    
    internal func urlSession(_ session: Foundation.URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    internal func urlSession(_ session: Foundation.URLSession, task: URLSessionTask, needNewBodyStream completionHandler: (InputStream?) -> Void) {
        //FIXME: 還沒有BodyStream
        completionHandler(nil)
    }
    
    internal func urlSession(_ session: Foundation.URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, nil)
    }
    
}

extension URLSessionDelegate : URLSessionDataDelegate {
    
    internal func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, challenge.proposedCredential)
    }
    
    internal func urlSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        dataTask.data.append(data)
        
        let countOfBytesReceived = dataTask.countOfBytesReceived
        let countOfBytesExpectedToReceive = dataTask.countOfBytesExpectedToReceive > 0 ? dataTask.countOfBytesExpectedToReceive : countOfBytesReceived
        
        if let processableCaller = dataTask.apiCaller as? RecevingProcessHandlable {
            let handler = processableCaller.recevingProcessHandler
            handler?(bytes: Int64(data.count), totalBytes: countOfBytesReceived, totalBytesExpected: countOfBytesExpectedToReceive)
        }
        
        
    }
    
    internal func urlSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {
        
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
    
    internal func urlSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        
        downloadTask.apiCaller = dataTask.apiCaller
        downloadTask.completionHandler = dataTask.completionHandler
        
        dataTask.apiCaller = nil
        dataTask.completionHandler = nil
        
        print("here didBecomeDownloadTask", self.session)
    }
    
    internal func urlSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        
    }
    
    internal func urlSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: (CachedURLResponse?) -> Void) {
        completionHandler(proposedResponse)
    }
    
}

extension URLSessionDelegate : URLSessionDownloadDelegate {
    
    internal func urlSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do{
            let data = try Data(contentsOf: location)
            downloadTask.data = data ?? Data()
        }catch{
            Debug(crash: "[Crashed]: Data from \(location)")
        }
    }
    
    internal func urlSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let processableCaller = downloadTask.apiCaller as? RecevingProcessHandlable {
            let handler = processableCaller.recevingProcessHandler
            handler?(bytes: bytesWritten, totalBytes: totalBytesWritten, totalBytesExpected: totalBytesExpectedToWrite)
        }
    }
    
    internal func urlSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
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
