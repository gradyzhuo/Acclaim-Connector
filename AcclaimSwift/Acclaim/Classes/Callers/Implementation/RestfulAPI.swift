//
//  RestfulAPI.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class RestfulAPI : APICaller {
    public typealias AssistantType = JSONResponseAssistant
    
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
    
    public func handleObject(keyPath keyPath:KeyPath = "", handler: AssistantType.Handler)->AssistantType{
        let assistant:AssistantType
        if keyPath == "" {
            assistant = AssistantType(handler: handler)
        }else{
            assistant = AssistantType(forKeyPath: keyPath, handler: handler)
        }
        return self.handle(responseType: .Success, assistant: assistant)
    }
    
    public func handleObject(keyPath keyPath:String = "", handler: AssistantType.Handler)->AssistantType{
        let assistant:AssistantType
        if keyPath == "" {
            assistant = AssistantType(handler: handler)
        }else{
            assistant = AssistantType(forKeyPath: KeyPath(path: keyPath), handler: handler)
        }
        return self.handle(responseType: .Success, assistant: assistant)
    }
    
    public func handleMappingObject<T:Mappable>(mappingClass mappingClass: T.Type, option:NSJSONReadingOptions = .AllowFragments, handler:MappingResponseAssistant<T>.Handler)->MappingResponseAssistant<T>{
        return self.handle(responseType: .Success, assistant: MappingResponseAssistant<T>(options: option, handler: handler))
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
        caller.handle(responseType: .Success, assistant: OriginalDataResponseAssistant(handler: completionHandler))
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
