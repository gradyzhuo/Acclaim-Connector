//
//  RestfulAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

private typealias SupportProtocols = protocol<Caller, APISupport, Configurable, ResponseSupport, CancelSupport>
public final class RestfulAPI : SupportProtocols {
    public typealias AssistantType = JSONResponseAssistant
    
    public var identifier: String{
        set{
            self.caller.identifier = newValue
        }
        get{
            return self.caller.identifier
        }
    }
    
    public var configuration: Acclaim.Configuration{
        set{
            self.caller.configuration = newValue
        }
        get{
            return self.caller.configuration
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
    
    required public init(API api: API, params: Parameters = [], connector: Connector = Acclaim.configuration.connector) {
        self.caller = APICaller(API: api, params: params, connector: connector)
    }
    
    public func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?) -> Void)?) {
        self.caller.resume(completion: completion)
    }
    
    public func cancel() {
        self.caller.cancel()
    }
    
//    public func waitting(forCaller caller: protocol<Caller, ResponseSupport>, assistant: JSONResponseAssistant, handler: (caller: Caller, waitingData: NSData?, connection: Connection, error: NSError?)->Void)->QueueCaller {
//        
//        caller.addOriginalDataResponseHandler { (data, connection) in
//            handler(caller: self, waitingData: data, connection: connection, error: nil)
//        }.addFailedResponseHandler { (outcome, connection, error) in
//            handler(caller: self, waitingData: outcome, connection: connection, error: error as? NSError)
//        }
//        
//        let queueCaller = QueueCaller(callers: [caller])
//        queueCaller.resume()
//        
//        return queueCaller
//        
//    }
    
    public func handleObject(response handler: AssistantType.Handler)->AssistantType{
        return self.caller.handle(responseType: .Normal, assistant: AssistantType(handler: handler))
    }
    
    public func handleObject(keyPath keyPath:KeyPath, handler: AssistantType.Handler)->AssistantType{
        return self.caller.handle(responseType: .Normal, assistant: AssistantType(forKeyPath: keyPath, handler: handler))
    }
    
    public func handleMappingObject<T:Mappable>(mappingClass mappingClass: T.Type, option:NSJSONReadingOptions = .AllowFragments, handler:MappingResponseAssistant<T>.Handler)->MappingResponseAssistant<T>{
        return self.handle(responseType: .Normal, assistant: MappingResponseAssistant<T>(options: option, handler: handler))
    }
    
}


extension RestfulAPI {
    
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

extension RestfulAPI  {
    
    public var responseAssistants:[Assistant] {
        return self.caller.responseAssistants
    }
    
    public var failedResponseAssistants:[Assistant] {
        return self.caller.failedResponseAssistants
    }
    
    public func handle<T : ResponseAssistant>(responseType type: ResponseAssistantType, assistant: T) -> T {
        return self.caller.handle(responseType: type, assistant: assistant)
    }
    
}

extension Acclaim {
    ///
    public static func call(API api:API, params:Parameters = [], priority: QueuePriority = .Default)->RestfulAPI{
        
        let caller = RestfulAPI(API: api, params: params)
        caller.configuration.priority = priority
        caller.resume()
        
        return caller
    }
    
    public static func call(API api:API, params:Parameters = [], priority: QueuePriority = .Default, completionHandler: OriginalDataResponseAssistant.Handler, failedHandler: FailedResponseAssistant<DataDeserializer>.Handler)->RestfulAPI{
        
        let caller = RestfulAPI(API: api, params: params)
        caller.configuration.priority = priority
        caller.handle(responseType: .Normal, assistant: OriginalDataResponseAssistant(handler: completionHandler))
        caller.failed(deserializer: DataDeserializer(), handler: failedHandler)
        caller.resume()
        
        return caller
    }
}

//Convenience
extension Acclaim {
    
    public static func call<T:ParameterValue>(API api:API, paramsDict:[String: T], priority: QueuePriority = .Default)->RestfulAPI{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.call(API: api, params: params, priority: priority)
    }
    
    public static func call<T:ParameterValue>(API api:API, paramsDict:[String: [T]], priority: QueuePriority = .Default)->RestfulAPI{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.call(API: api, params: params, priority: priority)
    }
    
    public static func call<T:ParameterValue>(API api:API, paramsDict:[String: [String:T]], priority: QueuePriority = .Default)->RestfulAPI{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.call(API: api, params: params, priority: priority)
    }
    
}
