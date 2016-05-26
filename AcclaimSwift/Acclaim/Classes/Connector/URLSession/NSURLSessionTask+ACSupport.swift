//
//  NSURLSessionTask+ACSupport.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/17/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

private let kRecevingProcessHandler = unsafeAddressOf("kProcessHandler")
private let kSendingProcessHandler = unsafeAddressOf("kProcessHandler")
private let kAPICaller = unsafeAddressOf("kAPICaller")
private let kCompletionHandler = unsafeAddressOf("kCompletionHandler")
private let kData = unsafeAddressOf("kData")

extension NSURLSessionTask {
    typealias ResponseHandlerType = Handler<TaskResponseHandler>
    
    internal var apiCaller: Caller? {
        set{
            if let apiCaller = newValue as? APICaller {
                apiCaller.sessionTask = self
            }
            objc_setAssociatedObject(self, kAPICaller, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let apiCaller = objc_getAssociatedObject(self, kAPICaller) as? Caller
            return apiCaller
        }
    }
    
    internal var completionHandler:ResponseHandlerType.HandlerType? {
        set{
            let handler = Handler<TaskResponseHandler>(newValue)
            objc_setAssociatedObject(self, kCompletionHandler, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let handler = objc_getAssociatedObject(self, kCompletionHandler) as? ResponseHandlerType
            return handler?.handler
        }
    }
    
    
    internal var data:NSMutableData {
        
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
    
    
    internal func removeData(){
        objc_setAssociatedObject(self, kData, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    
    internal func removeAllAssociatedObjects(){
        self.removeData()
        objc_removeAssociatedObjects(self)
    }
    
}
