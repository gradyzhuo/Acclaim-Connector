//
//  ImageDownloader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class Downloader : APICaller, RecevingProcessHandlable {
    public internal(set) var cancelledResumeData: NSData?
    public internal(set) var recevingProcessHandler: ProcessHandler?
    
    public override func cancel() {
        self.cancel(handler: nil)
    }
    
    public func cancel(handler handler: ((resumeData: NSData?)->Void)?) {
        if let sessionTask = self.sessionTask as? NSURLSessionDownloadTask, let handler = handler {
            sessionTask.cancelByProducingResumeData {[unowned self] resumeData in
                self.cancelledResumeData = resumeData
                handler(resumeData: resumeData)
            }
        }else{
            super.cancel()
        }
    }
    
    public func observer(recevingProcess handler: ProcessHandler) -> Self {
        self.recevingProcessHandler = handler
        return self
    }
    
    public func handleImage(scale scale: CGFloat = 1.0, handler:ImageResponseAssistant.Handler)->ImageResponseAssistant{
        return self.handle(responseType: .Success, assistant: ImageResponseAssistant(scale: scale, handler: handler))
    }
    
}

extension Acclaim {
    
    public static func download(API api:API, params:Parameters = [], priority: QueuePriority = .Default)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.configuration.priority = priority
        caller.resume()
        
        return caller
    }
    
    public static func download(API api:API, params:Parameters = [], priority: QueuePriority = .Default, completionHandler: OriginalDataResponseAssistant.Handler, failedHandler: FailedResponseAssistant<DataDeserializer>.Handler)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.configuration.priority = priority
        caller.handle(responseType: .Success, assistant: OriginalDataResponseAssistant(handler: completionHandler))
        caller.failed(deserializer: DataDeserializer(), handler: failedHandler)
        caller.resume()

        
        return caller
    }
    
}

//Convenience
extension Acclaim {
    
    public static func download<T:ParameterValue>(API api:API, paramsDict:[String: T], priority: QueuePriority = .Default)->Downloader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.download(API: api, params: params, priority: priority)
    }
    
    public static func download<T:ParameterValue>(API api:API, paramsDict:[String: [T]], priority: QueuePriority = .Default)->Downloader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.download(API: api, params: params, priority: priority)
    }
    
    public static func download<T:ParameterValue>(API api:API, paramsDict:[String: [String:T]], priority: QueuePriority = .Default)->Downloader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.download(API: api, params: params, priority: priority)
    }
    
}