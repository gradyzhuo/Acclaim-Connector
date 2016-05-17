//
//  ImageDownloader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

private typealias SupportProtocols = protocol<Caller, APISupport, ResponseSupport, RecevingProcessHandlable, Configurable, CancelSupport>
public final class Downloader : SupportProtocols {

    private var caller: SupportProtocols
    
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
    
    required public init(API api: API, params: Parameters = [], connector: Connector = Acclaim.configuration.connector) {
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
    
    public func observer(recevingProcess handler: ProcessHandler) -> Self {
        self.caller.observer(recevingProcess: handler)
        return self
    }
    
    public func handle<T : ResponseAssistant>(responseType type: ResponseAssistantType, assistant: T) -> T {
        return self.caller.handle(responseType: type, assistant: assistant)
    }
    
    public func cancelled(handler: ResumeDataResponseAssistant.Handler) -> Self {
        self.caller.cancelled(handler)
        return self
    }
    
    public func handleImage(scale scale: CGFloat = 1.0, handler:ImageResponseAssistant.Handler)->ImageResponseAssistant{
        return self.handle(responseType: .Normal, assistant: ImageResponseAssistant(scale: scale, handler: handler))
    }
    
    public func waitting(callers: Caller...) {
        //FIXME: not implemented
    }
    
}

extension Acclaim {
    
    public static func download(API api:API, params:Parameters = [], priority: QueuePriority = .Default)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.configuration.priority = priority
        caller.resume()
        
        return caller
    }
    
    public static func download(API api:API, params:Parameters = [], priority: QueuePriority = .Default, completionHandler: OriginalDataResponseAssistant.Handler, failedHandler: FailedResponseAssistant<DataDeserializer>.Handler)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.configuration.priority = priority
        caller.handle(responseType: .Normal, assistant: OriginalDataResponseAssistant(handler: completionHandler))
        caller.failed(deserializer: DataDeserializer(), handler: failedHandler)
        caller.resume()

        
        return caller
    }
    
}

//Convenience
extension Acclaim {
    
    public static func download<T:ParameterValue>(API api:API, paramsDict:[String: T], priority: QueuePriority = .Default)->Downloader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.download(API: api, params: params, priority: priority)
    }
    
    public static func download<T:ParameterValue>(API api:API, paramsDict:[String: [T]], priority: QueuePriority = .Default)->Downloader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.download(API: api, params: params, priority: priority)
    }
    
    public static func download<T:ParameterValue>(API api:API, paramsDict:[String: [String:T]], priority: QueuePriority = .Default)->Downloader{
        let params = Parameters(dictionary: paramsDict)
        return Acclaim.download(API: api, params: params, priority: priority)
    }
    
}