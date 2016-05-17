//
//  ImageDownloader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class Downloader : Caller, APISupport, ResponseSupport, RecevingProcessHandlable, Configurable {

    internal var caller: APICaller
    
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
    
    public var recevingProcessHandler: ProcessHandler?{
        return self.caller.recevingProcessHandler
    }

    public var responseAssistants:[Assistant] {
        return self.caller.responseAssistants
    }
    
    public var failedResponseAssistants:[Assistant] {
        return self.caller.failedResponseAssistants
    }
    
    public var cancelledAssistant: Assistant? {
        return self.caller.cancelledAssistant
    }
    
    public var cancelledResumeData:NSData?{
        return self.caller.cancelledResumeData
    }
    
    required public init(API api: API, params: RequestParameters, connector: Connector = Acclaim.configuration.connector) {
        self.caller = APICaller(API: api, params: params, connector: connector)
    }
    
    public func resume(completion completion: ((data: NSData?, connection: Connection, error: NSError?) -> Void)?) {
        self.caller.resume(completion: completion)
    }
    
    public func cancel() {
        self.caller.cancel()
    }
    
    public func cancel(resumeDataHandler: (cancelledResumeData: NSData?)->Void) {
        self.caller.cancel()
        resumeDataHandler(cancelledResumeData: self.caller.cancelledResumeData)
    }
    
    public func setRecevingProcessHandler(handler: ProcessHandler) -> Self {
        self.caller.setRecevingProcessHandler(handler)
        return self
    }
    
    public func addResponseAssistant<T : ResponseAssistant>(forType type: ResponseAssistantType = .Normal, responseAssistant assistant: T) -> T {
        return self.caller.addResponseAssistant(forType: type, responseAssistant: assistant)
    }
    
    public func setCancelledResponseHandler(handler: ResumeDataResponseAssistant.Handler) -> Self {
        self.caller.setCancelledResponseHandler(handler)
        return self
    }
    
    public func addImageResponseHandler(scale scale: CGFloat = 1.0, handler:ImageResponseAssistant.Handler)->ImageResponseAssistant{
        return self.addResponseAssistant(responseAssistant: ImageResponseAssistant(scale: scale, handler: handler))
    }
    
    public func waitting(callers: Caller...) {
        //FIXME: not implemented
    }
    
}

extension Acclaim {
    
    public static func download(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.configuration.priority = priority
        caller.resume()
        
        return caller
    }
    
    public static func download(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default, completionHandler: OriginalDataResponseAssistant.Handler, failedHandler: FailedResponseAssistant<DataDeserializer>.Handler)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.configuration.priority = priority
        caller.addResponseAssistant(responseAssistant: OriginalDataResponseAssistant(handler: completionHandler))
        caller.addFailedResponseHandler(deserializer: DataDeserializer(), handler: failedHandler)
        caller.resume()

        
        return caller
    }
    
}