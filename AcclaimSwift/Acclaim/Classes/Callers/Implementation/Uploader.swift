//
//  Uploader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

private typealias SupportProtocols = protocol<Caller, APISupport, CancelSupport, SendingProcessHandlable, ResponseSupport, Configurable>
public final class Uploader : SupportProtocols {
    public var identifier: String{
        set{
            self.caller.identifier = newValue
        }
        get{
            return self.caller.identifier
        }
    }
    
    public var api: API {
        return self.caller.api
    }
    
    public var params: Parameters{
        return self.caller.params
    }
    
    public var running:Bool {
        return self.caller.running
    }
    
    public var isCancelled: Bool{
        return self.caller.isCancelled
    }
    
    private var caller: SupportProtocols
    
    required public init(API api: API, params: Parameters, connector: Connector = Acclaim.configuration.connector) {
        self.caller = APICaller(API: api, params: params, connector: connector)
    }
    
    public func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?) -> Void)?) {
        self.caller.resume(completion: completion)
    }
    
    public func cancel() {
        self.caller.cancel()
    }
    
}

//MARK: - CancelSupport
extension Uploader {
    
    public var cancelledResumeData: NSData?{
        return self.caller.cancelledResumeData
    }
    
    public var cancelledAssistant: Assistant? {
        return self.caller.cancelledAssistant
    }
    
    public func cancelled(handler: ResumeDataResponseAssistant.Handler) -> Self {
        self.caller.cancelled(handler)
        return self
    }
    
}

//MARK: - SendingProcessHandlable
extension Uploader {
    public var sendingProcessHandler: ProcessHandler?{
        return self.caller.sendingProcessHandler
    }
    
    public func observer(sendingProcess handler: ProcessHandler) -> Self {
        self.caller.observer(sendingProcess: handler)
        return self
    }
    
}

//MARK: - Configurable
extension Uploader{
    
    public var configuration: Acclaim.Configuration{
        set{
            self.caller.configuration = newValue
        }
        get{
            return self.caller.configuration
        }
    }
    
}

//MARK: - ResponseSupport
extension Uploader {
    
    public var responseAssistants:[Assistant] {
        return self.caller.responseAssistants
    }
    
    public var failedResponseAssistants:[Assistant] {
        return self.caller.failedResponseAssistants
    }
    
    public func handle<T : ResponseAssistant>(responseType type: ResponseAssistantType, assistant: T) -> T {
        return self.caller.handle(responseType: type, assistant: assistant)
    }

    public func handleMappingObject<T:Mappable>(mappingClass: T.Type, option:NSJSONReadingOptions = .AllowFragments, handler:MappingResponseAssistant<T>.Handler)->MappingResponseAssistant<T>{
        return self.caller.handle(responseType: .Success, assistant: MappingResponseAssistant<T>(options: option, handler: handler))
    }
    
    public func handleObject(keyPath keyPath:KeyPath, option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->JSONResponseAssistant{
        return self.caller.handle(responseType: .Success, assistant: JSONResponseAssistant(forKeyPath: keyPath, options: option, handler: handler))
    }

    public func handleObject(option:NSJSONReadingOptions = .AllowFragments, handler:JSONResponseAssistant.Handler)->JSONResponseAssistant{
        return self.caller.handle(responseType: .Success, assistant: JSONResponseAssistant(options: option, handler: handler))
    }
    
    
    
}



extension Acclaim {
    
    public static func upload(API api:API, params:Parameters = [], priority: QueuePriority = .Default)->Uploader{
        
        let method = api.requestTaskType.method.HTTPMethodByReplaceSerializer(SerializerType.MultipartForm)
        api.requestTaskType.method = method
        
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