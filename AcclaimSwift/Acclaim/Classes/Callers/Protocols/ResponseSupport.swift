//
//  ResponseSupport.swift
//  Pods
//
//  Created by Grady Zhuo on 5/20/16.
//
//

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
