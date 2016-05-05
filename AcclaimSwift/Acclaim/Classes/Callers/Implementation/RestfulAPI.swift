//
//  RestfulAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class RestfulAPI : Caller, APISupport {
    public typealias AssistantType = JSONResponseAssistant
    
    public var identifier: String{
        set{
            self.caller.identifier = newValue
        }
        get{
            return self.caller.identifier
        }
    }
    
    public internal(set) var priority:QueuePriority {
        set{
            self.caller.priority = newValue
        }
        get{
            return self.caller.priority
        }
    }
    
    public var api: API {
        return self.caller.api
    }
    
    public var running:Bool {
        return self.caller.running
    }
    
    public var cancelled:Bool {
        return self.caller.cancelled
    }

    internal var caller: APICaller
    
    required public init(API api: API, params: RequestParameters, connector: Connector = Acclaim.configuration.connector) {
        self.caller = APICaller(API: api, params: params, connector: connector)
    }
    
    public func resume() {
        self.caller.resume()
    }
    
    public func run(cacheStoragePolicy: CacheStoragePolicy, priority: QueuePriority = .Default) -> Self {
        self.caller.run(cacheStoragePolicy, priority: priority)
        return self
    }
    
    public func cancel() {
        self.caller.cancel()
    }
    
    public func waitting(callers: Caller...) {
        //FIXME: not implemented
    }
    
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
        caller.priority = priority
        caller.run(.NotAllowed)
        
        return caller
    }
    
    public static func call(APIBundle bundle:APIBundle)->RestfulAPI{
        bundle.prepare()
        return Acclaim.call(API: bundle.api, params: bundle.params, priority: bundle.priority)
    }
}
