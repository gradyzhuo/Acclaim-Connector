//
//  ACConnector.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/16/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public typealias ProcessHandler = (bytes: Int64, totalBytes: Int64, totalBytesExpected: Int64)->Void
public typealias TaskResponseHandler = (task: NSURLSessionTask, response: NSURLResponse?, error: NSError?)->Void
public typealias DataResponseHandler = (data: NSData?, response: NSURLResponse?, error: NSError?)->Void

public class Handler<Type> {
    internal typealias HandlerType = Type
    
    internal let handler:HandlerType?
    internal init(_ handler: HandlerType?){
        self.handler = handler
    }
}

public protocol Connector : class {

    func generateTask(api: API, params: Parameters, configuration: Acclaim.Configuration,completionHandler handler: TaskResponseHandler) -> NSURLSessionTask
}

internal protocol _Connector : Connector {
    
}

extension Connector {
    
    internal func handle(task:NSURLSessionTask) {
        task.resume()
    }
    
    internal func _request(API api: API, params: Parameters = [], configuration: Acclaim.Configuration,completionHandler handler: TaskResponseHandler) -> NSURLSessionTask? {
        
        let task:NSURLSessionTask = self.generateTask(api, params: params, configuration: configuration,completionHandler: handler)
        task.completionHandler = handler
        
        defer{
            self.handle(task)
        }
        
        return task
    }
    
    public func request(API api: API, params: Parameters = [], configuration: Acclaim.Configuration,completionHandler handler: DataResponseHandler) -> NSURLSessionTask? {
        
        return self._request(API: api, params: params, configuration: configuration) { (task, response, error) in
            handler(data: task.data, response: response, error: error)
        }
        
    }


}

