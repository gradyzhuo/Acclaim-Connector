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
    var params:Parameters { get }
    
    init(API api: API, params: Parameters, connector: Connector)
}


public protocol CancelSupport {
    var cancelledAssistant: Assistant? { get }
    var cancelledResumeData: NSData? { get }
    
    func cancelled(handler:ResumeDataResponseAssistant.Handler)->Self
}

public protocol ResponseSupport {
    
    var responseAssistants:[Assistant] { get }
    var failedResponseAssistants:[Assistant] { get }
    
    func handle<T:ResponseAssistant>(responseType type:ResponseAssistantType, assistant: T)->T
}

extension ResponseSupport {
    
    // convenience response handler function
    public func failed(statusCode:Int? = nil, handler:FailedResponseAssistant<DataDeserializer>.Handler)->Self{
        var assistant = FailedResponseAssistant<DataDeserializer>()
        if let statusCode = statusCode {
            assistant.addHandler(forStatusCode: statusCode, handler: handler)
        }else{
            assistant.handler = handler
        }
        self.handle(responseType: .Failed, assistant: assistant)
        
        return self
    }
    
    public func failed<T:Deserializer>(deserializer deserializer: T, statusCode:Int? = nil, handler:FailedResponseAssistant<T>.Handler)->Self{
        var assistant = FailedResponseAssistant<T>()
        if let statusCode = statusCode {
            assistant.addHandler(forStatusCode: statusCode, handler: handler)
        }else{
            assistant.handler = handler
        }
        self.handle(responseType: .Failed, assistant: assistant)
        
        return self
    }
    
    public func handleOriginalData(handler:OriginalDataResponseAssistant.Handler)->Self{
        self.handle(responseType: .Success, assistant: OriginalDataResponseAssistant(handler: handler))
        return self
    }
    
    public func handleText(encoding: NSStringEncoding = NSUTF8StringEncoding, handler:TextResponseAssistant.Handler)->Self{
        self.handle(responseType: .Success, assistant: TextResponseAssistant(encoding: encoding, handler: handler))
        return self
    }
    
}

public protocol SendingProcessHandlable:class {
    var sendingProcessHandler: ProcessHandler? { get }
    
    func observer(sendingProcess handler: ProcessHandler) -> Self
}

public protocol RecevingProcessHandlable:class {
    var recevingProcessHandler: ProcessHandler? { get }
    
    func observer(recevingProcess handler: ProcessHandler) -> Self
}

public typealias ProcessHandlable = protocol<SendingProcessHandlable, RecevingProcessHandlable>

public protocol Caller : class {
    var identifier: String     { set get }
    var running:Bool           { get }
    var isCancelled: Bool      { get }
    
    func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?)->Void)?)
    func cancel()
}

extension Caller {
    public func resume(){
        self.resume(completion: nil)
    }
}
