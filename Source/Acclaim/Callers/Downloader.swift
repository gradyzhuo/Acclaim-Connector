//
//  ImageDownloader.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/14/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public final class Downloader : APICaller {

    public func addImageResponseHandler(resumeData:NSData? = nil, handler:ImageResponseAssistant.Handler)->Self{
        self.addResponseAssistant(responseAssistant: ImageResponseAssistant(handler: handler))
        return self
    }
    
}

extension Acclaim {
    
    public static func download(API api:API, params:RequestParameters = [:], priority: QueuePriority = .Default)->Downloader{
        
        let caller = Downloader(API: api, params: params)
        caller.priority = priority
        caller.run()
        
        return caller
    }
    
    public static func download(APIBundle bundle:APIBundle)->Downloader{
        bundle.prepare()
        return Acclaim.download(API: bundle.api, params: bundle.params, priority: bundle.priority)
    }
    
}