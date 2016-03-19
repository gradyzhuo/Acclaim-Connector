//
//  Uploader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation


public final class Uploader : RestfulAPI {
    
}

extension Acclaim {
    
    public static func upload(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->Uploader{
        
        let method = api.requestTaskType.method.HTTPMethodByReplaceSerializer(SerializerType.MultipartForm)
        api.requestTaskType.method = method
        
        let caller = Uploader(API: api, params: params)
        caller.priority = priority
        caller.run()
        
        return caller
    }
    
    public static func upload(APIBundle bundle:APIBundle)->Uploader{
        bundle.prepare()
        return Acclaim.upload(API: bundle.api, params: bundle.params, priority: bundle.priority)
    }
    
}