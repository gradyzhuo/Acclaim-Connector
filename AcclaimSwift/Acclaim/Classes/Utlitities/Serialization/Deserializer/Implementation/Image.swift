//
//  ImageDeserializer.swift
//  Acclaim
//
//  Created by Grady Zhuo on 3/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct ImageDeserializer : Deserializer{
    public typealias Outcome = UIImage
    
    public var scale: CGFloat = 1.0
    
    public func deserialize(data: NSData?) -> (outcome: Outcome?, error: NSError?) {
        guard let data = data else {
            return (nil, error: NSError(domain: "ACImageResponseDeserializer", code: 9, userInfo: [NSLocalizedFailureReasonErrorKey:"Original Data is nil."]))
        }
        
        guard let image = UIImage(data: data) else {
            let error = NSError(domain: "Acclaim.error.deserializer.image", code: 999, userInfo: [NSLocalizedFailureReasonErrorKey:"The data can't convert to image."])
            return (nil, error)
        }
        
        return (image, nil)
        
    }
    
    public init(){
        
    }
    
    public init(scale: CGFloat){
        self.scale = scale
    }
    
}