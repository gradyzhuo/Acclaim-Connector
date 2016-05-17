//
//  RestfulAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class RestfulAPI : Caller, APISupport, Configurable {
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
    
    public var params: RequestParameters{
        return self.caller.params
    }
    
    public var running:Bool {
        return self.caller.running
    }
    
    public var cancelled:Bool {
        return self.caller.cancelled
    }

    internal var caller: APICaller
    
    required public init(API api: API, params: RequestParameters = [], connector: Connector = Acclaim.configuration.connector) {
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
    
    public func setResponseHandler(handler: AssistantType.Handler)->AssistantType{
        return self.caller.addResponseAssistant(responseAssistant: AssistantType(handler: handler))
    }
    
    public func setResponseHandler(forKeyPath keyPath:KeyPath, handler: AssistantType.Handler)->AssistantType{
        return self.caller.addResponseAssistant(responseAssistant: AssistantType(forKeyPath: keyPath, handler: handler))
    }
    
    public func addMappingObjectResponseHandler<T:Mappable>(mappingClass: T.Type, option:NSJSONReadingOptions = .AllowFragments, handler:MappingResponseAssistant<T>.Handler)->MappingResponseAssistant<T>{
        return self.addResponseAssistant(responseAssistant: MappingResponseAssistant<T>(options: option, handler: handler))
    }
    
}


extension RestfulAPI : CancelSupport {
    
    public var cancelledResumeData: NSData?{
        return self.caller.cancelledResumeData
    }
    
    public var cancelledAssistant: Assistant? {
        return self.caller.cancelledAssistant
    }
    
    public func setCancelledResponseHandler(handler: ResumeDataResponseAssistant.Handler) -> Self {
        self.caller.setCancelledResponseHandler(handler)
        return self
    }
}

extension RestfulAPI : ResponseSupport {
    
    public var responseAssistants:[Assistant] {
        return self.caller.responseAssistants
    }
    
    public var failedResponseAssistants:[Assistant] {
        return self.caller.failedResponseAssistants
    }
    
    public func addResponseAssistant<T : ResponseAssistant>(forType type: ResponseAssistantType = .Normal, responseAssistant assistant: T) -> T {
        return self.caller.addResponseAssistant(forType: type, responseAssistant: assistant)
    }
    
    
    
}

extension Acclaim {
    ///
    public static func call(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->RestfulAPI{
        
        let caller = RestfulAPI(API: api, params: params)
        caller.configuration.priority = priority
        caller.resume()
        
        return caller
    }
    
    public static func call(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default, completionHandler: OriginalDataResponseAssistant.Handler, failedHandler: FailedResponseAssistant<DataDeserializer>.Handler)->RestfulAPI{
        
        let caller = RestfulAPI(API: api, params: params)
        caller.configuration.priority = priority
        caller.addResponseAssistant(responseAssistant: OriginalDataResponseAssistant(handler: completionHandler))
        caller.addFailedResponseHandler(deserializer: DataDeserializer(), handler: failedHandler)
        caller.resume()
        
        
        return caller
    }
}
