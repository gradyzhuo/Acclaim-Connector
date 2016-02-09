//
//  ACConnector.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias ResponseHandler = (data: NSData?, response: NSURLResponse?, error: NSError?)->Void

public protocol Connector : class {
    
    init()
    func generateTask(request: NSURLRequest, taskType: RequestTaskType, handler: ResponseHandler) -> NSURLSessionTask
}

internal protocol _Connector : Connector {
    
}

extension Connector {
    
    internal func handle(task:NSURLSessionTask) {
        task.resume()
    }
    
    internal func sendRequest(request: NSURLRequest, taskType: RequestTaskType, handler: ResponseHandler) -> NSURLSessionTask? {
        
        let task:NSURLSessionTask = self.generateTask(request, taskType: taskType, handler: handler)
        
        defer{
            self.handle(task)
        }
        
        return task
    }

}

public class URLSession : NSObject, _Connector {
    
    public required override init(){
        
    }

    public func generateTask(request: NSURLRequest, taskType: RequestTaskType, handler: ResponseHandler) -> NSURLSessionTask {
        let task:NSURLSessionTask
        
        if case let .DownloadTask(resumeData) = taskType {
            
            //Carry function to handle download handler type is not equal to ResponseHandler
            func handleDownloadTaskHandler(handler: ResponseHandler)->(url: NSURL?, response: NSURLResponse?, error: NSError?)->Void{
                
                return { (url: NSURL?, response: NSURLResponse?, error: NSError?)->Void in
                    
                    guard let url = url else {
                        return
                    }
                    
                    handler(data: NSData(contentsOfURL: url), response: response, error: error)
                }
            }
            
            if let resumeData = resumeData {
                task = NSURLSession.sharedSession().downloadTaskWithResumeData(resumeData, completionHandler: handleDownloadTaskHandler(handler))
            }else{
                task = NSURLSession.sharedSession().downloadTaskWithRequest(request, completionHandler: handleDownloadTaskHandler(handler))
            }
            
        }else if case let .UploadTask(data) = taskType {
            
            task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data, completionHandler: handler)
            
        }else{
            
            let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                handler(data: data, response: response, error: error)
            }
            task = dataTask
        }
        
        return task
    }

}