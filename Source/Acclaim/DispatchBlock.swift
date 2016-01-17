//
//  DispatchBlock.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/19/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

public class DispatchBlock {
    
    public typealias dispatch_block_t = () throws -> Void
    
    internal var block:dispatch_block_t!
    
    public init(block:dispatch_block_t){
        self.block = block
        
    }
    
    deinit{
        self.block = nil
        ACDebugLog("DispatchBlock deinit")
    }
}

