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
    
    public init(API api: API, params: Parameters = [], resumeData: Data? = nil, configuration: Acclaim.Configuration = Acclaim.configuration) {
        super.init(API: api, params: params, taskType: .UploadTask, configuration:configuration)
    }
    
    public func observer(sendingProcess handler: ProcessHandler) -> Self {
        self.sendingProcessHandler = handler
        return self
    }
    
}

//MARK: - ResponseSupport
extension Uploader {

    public func handleMappingObject<T:Mappable>(_ mappingClass: T.Type, option:JSONSerialization.ReadingOptions = .allowFragments, handler:MappingResponseAssistant<T>.Handler)->MappingResponseAssistant<T>{
        return self.handle(responseType: .success, assistant: MappingResponseAssistant<T>(options: option, handler: handler))
    }
    
    public func handleObject(_ keyPath:KeyPath, option:JSONSerialization.ReadingOptions = .allowFragments, handler:JSONResponseAssistant.Handler)->JSONResponseAssistant{
        return self.handle(responseType: .success, assistant: JSONResponseAssistant(forKeyPath: keyPath, options: option, handler: handler))
    }

    public func handleObject(_ option:JSONSerialization.ReadingOptions = .allowFragments, handler:JSONResponseAssistant.Handler)->JSONResponseAssistant{
        return self.handle(responseType: .success, assistant: JSONResponseAssistant(options: option, handler: handler))
    }
    
    
    
}



extension Acclaim {
    
    public static func upload(API api:API, params:Parameters = [], priority: QueuePriority = .Default)->Uploader{
        
        
        let method = api.method.replaced(bySerializerType: SerializerType.multipartForm)
        api.method = method
        
        let caller = Uploader(API: api, params: params)
        caller.configuration.priority = priority
        caller.resume()
        
        return caller
    }
    
    public static func upload(API api:API, params:Parameters = [], priority: QueuePriority = .Default, completionHandler: OriginalDataResponseAssistant.Handler, failedHandler: FailedResponseAssistant<DataDeserializer>.Handler)->Uploader{
        
        let caller = Uploader(API: api, params: params)
        caller.configuration.priority = priority
        _ = caller.handle(responseType: .success, assistant: OriginalDataResponseAssistant(handler: completionHandler))
        _ = caller.failed(deserializer: DataDeserializer(), handler: failedHandler)
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
