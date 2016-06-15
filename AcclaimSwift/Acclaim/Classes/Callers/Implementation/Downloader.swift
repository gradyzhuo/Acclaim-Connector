//
//  ImageDownloader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class Downloader : APICaller, RecevingProcessHandlable {
    public internal(set) var recevingProcessHandler: ProcessHandler?
    
    public init(API api: API, params: Parameters = [], resumeData: Data? = nil, configuration: Acclaim.Configuration = Acclaim.configuration) {
        super.init(API: api, params: params, taskType: .DownloadTask(resumeData: resumeData),configuration:configuration)
    }
    
    public override func cancel() {
        self.cancel(nil)
    }
    
    public func cancel(_ handler: ((resumeData: Data?)->Void)?) {
        if let sessionTask = self.sessionTask as? URLSessionDownloadTask, let handler = handler {
            sessionTask.cancel { resumeData in
                sessionTask.data = resumeData ?? Data()
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
    
    public func handleImage(_ scale: CGFloat = 1.0, handler:ImageResponseAssistant.Handler)->ImageResponseAssistant{
        return self.handle(responseType: .success, assistant: ImageResponseAssistant(scale: scale, handler: handler))
    }
    
}

extension Acclaim {
    
    public static func download(API api:API, params:Parameters = [], method: Method = .get, resumeData: Data? = nil, priority: QueuePriority = .Default)->Downloader{
        
        let caller = Downloader(API: api, params: params, resumeData: resumeData)
        caller.configuration.priority = priority
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
