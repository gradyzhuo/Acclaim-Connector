//
//  Protocols.swift
//  Acclaim
//
//  Created by Grady Zhuo on 5/5/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Configurable {
    var configuration: Acclaim.Configuration { set get }
}

public protocol APISupport {
    var api:API               { get }
    var params:RequestParameters { get }
    
    init(API api: API, params: RequestParameters, connector: Connector)
}


public protocol CancelSupport {
    var cancelledAssistant: Assistant? { get }
    var cancelledResumeData:NSData? { get }
    
    func setCancelledResponseHandler(handler:ResumeDataResponseAssistant.Handler)->Self
}

public protocol ResponseSupport {
    
    var responseAssistants:[Assistant] { get }
    var failedResponseAssistants:[Assistant] { get }
    
    func addResponseAssistant<T:ResponseAssistant>(forType type:ResponseAssistantType, responseAssistant assistant: T)->T
}

extension ResponseSupport {
    
    // convenience response handler function
    public func addFailedResponseHandler(statusCode:Int? = nil, handler:FailedResponseAssistant<DataDeserializer>.Handler)->Self{
        var assistant = FailedResponseAssistant<DataDeserializer>()
        if let statusCode = statusCode {
            assistant.addHandler(forStatusCode: statusCode, handler: handler)
        }else{
            assistant.handler = handler
        }
        self.addResponseAssistant(forType: .Failed, responseAssistant: assistant)
        
        return self
    }
    
    public func addFailedResponseHandler<T:Deserializer>(deserializer deserializer: T, statusCode:Int? = nil, handler:FailedResponseAssistant<T>.Handler)->Self{
        var assistant = FailedResponseAssistant<T>()
        if let statusCode = statusCode {
            assistant.addHandler(forStatusCode: statusCode, handler: handler)
        }else{
            assistant.handler = handler
        }
        self.addResponseAssistant(forType: .Failed, responseAssistant: assistant)
        
        return self
    }
    
    public func addOriginalDataResponseHandler(handler:OriginalDataResponseAssistant.Handler)->Self{
        
        self.addResponseAssistant(forType: .Normal, responseAssistant: OriginalDataResponseAssistant(handler: handler))
        
        return self
    }
    
    public func addTextResponseHandler(encoding: NSStringEncoding = NSUTF8StringEncoding, handler:TextResponseAssistant.Handler)->Self{
        
        self.addResponseAssistant(forType: .Normal, responseAssistant: TextResponseAssistant(encoding: encoding, handler: handler))
        
        return self
    }
    
}

public protocol SendingProcessHandlable:class {
    var sendingProcessHandler: ProcessHandler? { get }
    
    func setSendingProcessHandler(handler: ProcessHandler)->Self
}

public protocol RecevingProcessHandlable:class {
    var recevingProcessHandler: ProcessHandler? { get }
    
    func setRecevingProcessHandler(handler: ProcessHandler)->Self
}

public typealias ProcessHandlable = protocol<SendingProcessHandlable, RecevingProcessHandlable>

public protocol Caller : class {
    var identifier: String     { set get }
    var running:Bool           { get }
    var cancelled:Bool         { get }
    
    func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?)->Void)?)
    func cancel()
}

extension Caller {
    public func resume(){
        self.resume(completion: nil)
    }
}
