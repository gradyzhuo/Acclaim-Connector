//
//  ImageDownloader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class Downloader : Caller, APISupport, ResponseSupport, RecevingProcessHandlable {

    internal var caller: APICaller
    
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
    
    public internal(set) var priority:QueuePriority {
        set{
            self.caller.priority = newValue
        }
        get{
            return self.caller.priority
        }
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
    
    public func addImageResponseHandler(resumeData:NSData? = nil, handler:ImageResponseAssistant.Handler)->ImageResponseAssistant{
        return self.addResponseAssistant(responseAssistant: ImageResponseAssistant(handler: handler))
    }
    
    public func waitting(callers: Caller...) {
        //FIXME: not implemented
    }
    
}

extension Acclaim {
    
    public static func download(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.priority = priority
        caller.run(.NotAllowed)
        
        return caller
    }
    
    public static func download(APIBundle bundle:APIBundle)->Downloader{
        bundle.prepare()
        return Acclaim.download(API: bundle.api, params: bundle.params, priority: bundle.priority)
    }
    
}