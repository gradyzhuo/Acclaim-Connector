//
//  Uploader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation


extension Acclaim {
    
    public static func upload(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->Uploader{
        
        let method = api.requestTaskType.method.HTTPMethodByReplaceSerializer(SerializerType.MultipartForm)
        api.requestTaskType.method = method
        
        let caller = Uploader(API: api, params: params)
        caller.priority = priority
        caller.run()
        
        return caller
    }
    
}

public final class Uploader : RestfulAPI {
    
}