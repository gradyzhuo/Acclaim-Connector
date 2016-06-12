//
//  Uploader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class Uploader : APICaller, SendingProcessHandlable {
    
    public internal(set) var sendingProcessHandler: ProcessHandler?
    
    public init(API api: API, params: Parameters = [], resumeData: NSData? = nil, configuration: Acclaim.Configuration = Acclaim.configuration) {
        super.init(API: api, params: params, taskType: .UploadTask, configuration:configuration)
    }
    
    public func observer(sendingProcess handler: ProcessHandler) -> Self {
        self.sendingProcessHandler = handler
        return self
    }
    
}

//MARK: - ResponseSupport
extension Uploader {

    public func handleMappingObject<T:Mappable>(mappingClass: T.Type, option:NSJSONReadingOptions = .AllowFragments, handler:MappingResponseAssistant<T>.Handler)->MappingResponseAssistant<T>{
        return self.handle(responseType: .Success, assistant: MappingResponseAssistant<T>(options: option, handler: handler))
    }
    
    public func handleObject(keyPath keyPath:KeyPath, option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->JSONResponseAssistant{
        return self.handle(responseType: .Success, assistant: JSONResponseAssistant(forKeyPath: keyPath, options: option, handler: handler))
    }

    public func handleObject(option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->JSONResponseAssistant{
        return self.handle(responseType: .Success, assistant: JSONResponseAssistant(options: option, handler: handler))
    }
    
    
    
}



extension Acclaim {
    
    public static func upload(API api:API, params:Parameters = [], priority: QueuePriority = .Default)->Uploader{
        
        let method = api.method.HTTPMethodByReplaceSerializer(SerializerType.MultipartForm)
        api.method = method
        
        let caller = Uploader(API: api, params: params)
        caller.configuration.priority = priority
        caller.resume()
        
        return caller
    }
    
    public static func upload(API api:API, params:Parameters = [], priority: QueuePriority = .Default, completionHandler: OriginalDataResponseAssistant.Handler, failedHandler: FailedResponseAssistant<DataDeserializer>.Handler)->Uploader{
        
        let caller = Uploader(API: api, params: params)
        caller.configuration.priority = priority
        caller.handle(responseType: .Success, assistant: OriginalDataResponseAssistant(handler: completionHandler))
        caller.failed(deserializer: DataDeserializer(), handler: failedHandler)
        caller.resume()
        
        
        return caller
    }
}


//Convenience
extension Acclaim {
    
    public static func upload<T:ParameterValue>(API api:API, paramsDict:[String: T], priority: QueuePriority = .Default)->Uploader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.upload(API: api, params: params, priority: priority)
    }
    
    public static func upload<T:ParameterValue>(API api:API, paramsDict:[String: [T]], priority: QueuePriority = .Default)->Uploader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.upload(API: api, params: params, priority: priority)
    }
    
    public static func upload<T:ParameterValue>(API api:API, paramsDict:[String: [String:T]], priority: QueuePriority = .Default)->Uploader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.upload(API: api, params: params, priority: priority)
    }
    
}