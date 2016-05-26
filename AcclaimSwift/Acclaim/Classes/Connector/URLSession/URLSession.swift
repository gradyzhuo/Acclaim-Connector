//
//  URLSession.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/17/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class URLSession : NSObject, _Connector {
    
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
    
    public func generateTask(api: API, params: Parameters = [], requestTaskType taskType: RequestTaskType, configuration: Acclaim.Configuration, completionHandler handler: TaskResponseHandler) -> NSURLSessionTask {

        let task:NSURLSessionTask
        
        if taskType == .DownloadTask {
            
            let request = taskType.generateRequest(api, configuration: configuration, params: params)
            
            if let resumeData = taskType.resumeData {
                task = self.session.downloadTaskWithResumeData(resumeData)
            }else{
                task = self.session.downloadTaskWithRequest(request)
            }
        }else if taskType == .UploadTask {
            
            let mutableRequest:NSMutableURLRequest! = taskType.generateRequest(api, configuration: configuration, params: params).mutableCopy() as! NSMutableURLRequest
            let uploadData = params.serialize(api.method.serializer) ?? NSData()
            
            if let multipartSerializer = api.method.serializer as? MultipartFormSerializer {
                
                mutableRequest.setValue("\(uploadData.length)", forHTTPHeaderField: "Content-Length")
                
                let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
                let contentType = "multipart/form-data; charset=\(charset); boundary=\(multipartSerializer.boundary)"
                mutableRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
            }
            
            task = self.session.uploadTaskWithRequest(mutableRequest, fromData: uploadData)
        }
        else{
            
            let request = taskType.generateRequest(api, configuration: configuration, params: params)
            //FIXME: 如果要使用Delegate，就一定要使用沒有CompletionHandler的版本
            task = self.session.dataTaskWithRequest(request)
        }
        
        return task
    }
    
    deinit{
        ACDebugLog("URLSession : [\(unsafeAddressOf(self))] deinit")
    }
}
