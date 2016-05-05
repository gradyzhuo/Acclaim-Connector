//
//  APICall.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/14/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol APISupport {
    var api:API               { get }
    
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
    public func addFailedResponseHandler(statusCode statusCode:Int? = nil, handler:FailedResponseAssistant.Handler)->Self{
        var assistant = FailedResponseAssistant()
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

public protocol Caller : class{
    var identifier: String     { get }
    var priority:QueuePriority { get }
    var running:Bool           { get }
    var cancelled:Bool         { get }
    
    func run(cacheStoragePolicy: CacheStoragePolicy, priority: QueuePriority)->Self
    func resume()
    func cancel()
}


public enum ProcessHandlerType : String {
    case Sending = "Sending"
    case Receiving = "Receiving"
}

public class APICaller : Caller, APISupport, ResponseSupport, ProcessHandlable {
    
    public internal(set) var identifier: String = String(NSDate().timeIntervalSince1970)
    
    /**
     The queue priority level configure of sending a request. (readonly)
     
     There are 3 levels as below:
     - High
     - Medium
     - Low
     
     Otherwise:
     - Default = Medium
     */
    public internal(set) var priority:QueuePriority = .Default
    internal var cacheStoragePolicy:CacheStoragePolicy = .AllowedInMemoryOnly(renewRule: .NotRenewed)
    
    
    /** (readonly) */
    public var cancelled:Bool {
        if let queue = self.blockInQueue {
            let testResult = dispatch_block_testcancel(queue)
            return Bool(testResult)
        }
        return false
    }
    
    /** (read only) */
    public internal(set) var api:API
    /** (read only) */
    public internal(set) var running:Bool = false
    /** (read only) */
    
    //MARK: internal variables
    internal var blockInQueue:dispatch_block_t!
    internal var params:RequestParameters = []
    
    internal var sessionTask:NSURLSessionTask?
    
    public internal(set) var responseAssistants:[Assistant] = []
    public internal(set)  var failedResponseAssistants:[Assistant] = []
    public internal(set)  var cancelledAssistant: Assistant?
    
    
    public internal(set) var sendingProcessHandler: ProcessHandler?
    public internal(set) var recevingProcessHandler: ProcessHandler?
    
    public internal(set) var cancelledResumeData:NSData?
    
    lazy var queue: dispatch_queue_t = dispatch_queue_create(self.identifier, DISPATCH_QUEUE_SERIAL)
    
    var connector: Connector!
    
    convenience init(API api:API, params:[String: ParameterValueType], connector: Connector = Acclaim.configuration.connector) {
        self.init(API: api, params: RequestParameters(dictionary: params), connector: connector)
    }
    
    convenience init(API api:API, params:[Parameter], connector: Connector = Acclaim.configuration.connector ) {
        self.init(API: api, params: RequestParameters(params: params), connector: connector)
    }
    
    required public init(API api:API, params:RequestParameters = [], connector: Connector = Acclaim.configuration.connector) {
        self.api = api
        self.params = params
        self.connector = connector
    }
    
    func run()->Self{
        self.resume()
        return self
    }
    
    public func run(cacheStoragePolicy:CacheStoragePolicy, priority: QueuePriority = .Default)->Self{
        
        self.cacheStoragePolicy = cacheStoragePolicy
        self.priority = priority
        
        return self.run()
    }
    
    func run(connector connector: Connector){
        
        guard !self.running else {
            return
        }
        
        // set
        self.sessionTask = connector.request(API: self.api, params: self.params) {[unowned self] (data, connection, error) in
            
            let request:NSURLRequest! = self.sessionTask?.currentRequest
            
            self.handleResponses(data: data, connection: connection, error: error)
            
            //remove
            Acclaim.removeRunningCaller(self)
            
            self.blockInQueue = nil
            self.running = false
            
        }
        
        self.sessionTask?.apiCaller = self
        
        defer{
            self.running = true
        }
        
    }
    
    func retry(API api:API){

    }
    
    public func resume(){
        
        let block = dispatch_block_create_with_qos_class(DISPATCH_BLOCK_DETACHED, priority.qos_class, priority.relative_priority) {[unowned self] () -> Void in
            self.run(connector: self.connector)
        }
        
        self.blockInQueue = block
        dispatch_barrier_async(self.queue, block)
        
        //add
        Acclaim.addRunningCaller(self)
        
    }
    
    public func cancel(){
        
        //插入cancel指令到running之後
        dispatch_sync(self.queue) {
            
            //Ignore if APICaller is not running.
            guard self.running else {
                ACDebugLog("Caller is not running. Please perform `func call()` to run your api.")
                return
            }
            
            //Ignore if APICaller has been cannceled.
            guard !self.cancelled else {
                ACDebugLog("Caller has been cannceled. Please perform `func call()` to run your api.")
                return
            }
            
            if let downloadTask = self.sessionTask as? NSURLSessionDownloadTask {
                downloadTask.cancelByProducingResumeData{[unowned self] data in
                    self.cancelledResumeData = data
                }
            }else{
                self.sessionTask?.cancel()
            }
            
            dispatch_block_cancel(self.blockInQueue)
            
        }
        
    }
    
    deinit{
        ACDebugLog("APICaller : [\(unsafeAddressOf(self))] deinit")
    }
}

extension APICaller {
    
    func handleCachedResponse(cachedResponse: NSCachedURLResponse, byRequest request: NSURLRequest){
        let connection = Connection(originalRequest: request, currentRequest: request, response: cachedResponse.response, cached: true)
        self.handleResponses(fromCached: true)(data: cachedResponse.data, connection: connection, error: nil)
    }

    func handleResponses(data data:NSData?, connection: Connection, error:ErrorType?){
        self.handleResponses()(data: data, connection: connection, error: error)
    }
    
    func handleResponses(fromCached cached: Bool = false)->(data:NSData?, connection: Connection, error:ErrorType?)->Void{
        
        return {[unowned self] (data:NSData?, connection: Connection, error:ErrorType?)->Void in
            
            guard !self.cancelled else {
                //檢查cancel的訊息，並在這裡回傳resumedData
                self.cancelledAssistant?.handle(self.cancelledResumeData, connection: connection, error: nil)
                return
            }
            
            guard error == nil else {
                //remove cached response data by renewRule : RenewByRetry
                
                //before this request
                if let cachedResponse = Acclaim.cachedResponse(request: connection.currentRequest) {
                    self.handleCachedResponse(cachedResponse, byRequest: connection.currentRequest)
                }
                
                self.handleFailedResponse(data: data, connection: connection, error: error)
                return
            }
            
            if let response = connection.response, let data = data where cached == false{
                let cacheStoragePolicy = NSURLCacheStoragePolicy(self.cacheStoragePolicy)
                let cachedResponse = NSCachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: cacheStoragePolicy)
                Acclaim.storeCachedResponse(cachedResponse, forRequest: connection.currentRequest)
            }
            
            self.responseAssistants.forEach { reciver in
                
                if let error = reciver.handle(data, connection: connection, error: error) as? NSError {
                    self.handleFailedResponse(data: data, connection: connection, error: error)
                }
            }
        }
        
    }
    
    func handleFailedResponse(data data:NSData?, connection: Connection, error:ErrorType?) {
        self.failedResponseAssistants.forEach { $0.handle(data, connection: connection, error: error) }
    }
    
    
    public func addResponseAssistant<T:ResponseAssistant>(forType type:ResponseAssistantType = .Normal, responseAssistant assistant: T)->T{
        switch type {
        case .Normal:
            self.responseAssistants.append(assistant)
        case .Failed:
            self.failedResponseAssistants.append(assistant)
        }
        return assistant
    }
    
}

//handle sending/receving processing
extension APICaller {
    
    public func setCancelledResponseHandler(handler:ResumeDataResponseAssistant.Handler)->Self{
        self.cancelledAssistant = ResumeDataResponseAssistant(handler: handler)
        return self
    }
    
    public func setSendingProcessHandler(handler: ProcessHandler)->Self {
        self.sendingProcessHandler = handler
        return self
    }
    
    public func setRecevingProcessHandler(handler: ProcessHandler)->Self {
        self.recevingProcessHandler = handler
        return self
    }
}


/// A enum describes how `ResponseCached` should cache into a storage.
public enum CacheStoragePolicy{
    
    /// A enum describes the renew rule by the response failed.
    public enum RenewRule {
        
        case NotRenewed
        /// Not implemented.
        case RenewSinceDate(data: NSDate)
        /// Not implemented.
        case RenewByRetry(limitCount: Int)
        
        internal static let DefaultRetryCount = 4
    }
    
    /// Response will be cached into a storage.
    case Allowed(renewRule: RenewRule)
    /// Response will be cached into a memory only.
    case AllowedInMemoryOnly(renewRule: RenewRule)
    /// Response should not be cached.
    case NotAllowed
    
    internal var renewRule: RenewRule {
        switch self {
        case .Allowed(let renewRule):
            return renewRule
        case .AllowedInMemoryOnly(let renewRule):
            return renewRule
        case .NotAllowed:
            return .NotRenewed
        }
    }
}

//MARK: - RenewRule internal methods
extension CacheStoragePolicy.RenewRule {
    
    internal var _method:String{
        switch self {
        case .NotRenewed:
            return "NotRenewed"
        case .RenewSinceDate:
            return "RenewSinceDate"
        case .RenewByRetry:
            return "RenewByRetry"
        }
    }
}



extension NSURLCacheStoragePolicy {
    public init(_ rawValue: CacheStoragePolicy) {
        switch rawValue{
        case .Allowed:
            self = .Allowed
        case .AllowedInMemoryOnly:
            self = .AllowedInMemoryOnly
        case .NotAllowed:
            self = .NotAllowed
        }
    }
}

extension CacheStoragePolicy {
    
    public init(_ rawValue: NSURLCacheStoragePolicy){
        switch rawValue {
        case .Allowed:
            self = .Allowed(renewRule: .NotRenewed)
        case .AllowedInMemoryOnly:
            self = .AllowedInMemoryOnly(renewRule: .NotRenewed)
        case .NotAllowed:
            self = .NotAllowed
        }
    }
}