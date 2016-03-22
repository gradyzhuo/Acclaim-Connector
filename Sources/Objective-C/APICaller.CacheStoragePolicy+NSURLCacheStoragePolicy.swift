//
//  APICaller.CacheStoragePolicy+.swift
//  Acclaim
//
//  Created by Grady Zhuo on 2/10/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation
import Acclaim

extension NSURLCacheStoragePolicy {
    init(_ rawValue: APICaller.CacheStoragePolicy) {
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

extension APICaller.CacheStoragePolicy {
    
    internal init(_ rawValue: NSURLCacheStoragePolicy){
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