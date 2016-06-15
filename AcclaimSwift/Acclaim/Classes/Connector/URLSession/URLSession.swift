//
//  URLSession.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/17/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public class URLSession : NSObject, _Connector {
    
    public internal(set) var session: Foundation.URLSession!
    
    public internal(set) var configuration:URLSessionConfiguration = .default()
    public internal(set) var delegateQueue:OperationQueue = OperationQueue.main()
    
    public required override init(){
        super.init()
        
        let delegate = URLSessionDelegate(session: self)
        self.session = Foundation.URLSession(configuration: self.configuration, delegate: delegate, delegateQueue: self.delegateQueue)
    }
    
    init(configuration: URLSessionConfiguration) {
        super.init()
        
        let delegate = URLSessionDelegate(session: self)
        self.session = Foundation.URLSession(configuration: configuration, delegate: delegate, delegateQueue: self.delegateQueue)
    }
    
    public func generateTask(_ api: API, params: Parameters = [], requestTaskType taskType: RequestTaskType, configuration: Acclaim.Configuration, completionHandler handler: TaskResponseHandler) -> URLSessionTask {

        let task:URLSessionTask
        
        if taskType == .DownloadTask {
            
            let request = api.generateRequest(parameters: params, configuration: configuration)
            if let resumeData = taskType.infoObject as? Data {
                task = self.session.downloadTask(withResumeData: resumeData)
            }else{
                task = self.session.downloadTask(with: request)
            }
        }else if taskType == .UploadTask {
            
            var mutableRequest = api.generateRequest(parameters: params, configuration: configuration)
            let uploadData = params.serialize(by: api.method.serializer) ?? Data()
            
            if let multipartSerializer = api.method.serializer as? MultipartFormSerializer {
                
                mutableRequest.setValue("\(uploadData.length)", forHTTPHeaderField: "Content-Length")
                
                let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
                let contentType = "multipart/form-data; charset=\(charset); boundary=\(multipartSerializer.boundary)"
                mutableRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
            }
            
            task = self.session.uploadTask(with: mutableRequest as URLRequest, from: uploadData as Data)
        }
        else if taskType == .StreamTask {
            // Unfinished
            _ = api.generateRequest(parameters: params, configuration: configuration)
            
            let service = taskType.infoObject as! NetService
            let streamTask:URLSessionStreamTask = self.session.streamTask(with: service)
            task = streamTask
            
            streamTask.captureStreams()
        }
        else{
            
            let request = api.generateRequest(parameters: params, configuration: configuration)
            //FIXME: 如果要使用Delegate，就一定要使用沒有CompletionHandler的版本
            task = self.session.dataTask(with: request)
        }
        
        task.completionHandler = handler
        
        return task
    }
    
    
    public func request(API api: API, params: Parameters = [], requestTaskType: RequestTaskType = .DataTask, configuration: Acclaim.Configuration = Acclaim.Configuration.defaultConfiguration,completionHandler handler: DataResponseHandler) -> URLSessionTask? {
        let task = self._request(API: api, params: params, requestTaskType: requestTaskType, configuration: configuration){
            handler(data: $0.task.data, response: $0.response, error: $0.error)
        }
        
        task?.resume()
        
        return task
    }
    
    deinit{
        Debug(log: "URLSession : [\(unsafeAddress(of: self))] deinit")
    }
}
