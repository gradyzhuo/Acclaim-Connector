//
//  DispatchBlock.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/19/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

internal class DispatchBlock {
    
    internal var block:dispatch_block_t!
    
    internal init(block:dispatch_block_t){
        self.block = block
    }
    
    deinit{
        self.block = nil
        ACDebugLog("DispatchBlock deinit")
    }
}