//
//  ACSerialization.swift
//  Acclaim
//
//  Created by Grady Zhuo on 8/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import Foundation

typealias Serialization = protocol<Serializer, Deserializer>


public protocol Serializer {
    func serialize(params:Parameters) -> NSData?
    
}

public struct ACParamsJSONSerializer : Serializer {
    public var option: NSJSONWritingOptions
    
    public init(option: NSJSONWritingOptions = .PrettyPrinted){
        self.option = option
    }
    
    public func serialize(params: Parameters) -> NSData? {
        return nil
    }
    
}


public struct ACParamsQueryStringSerializer : Serializer {

    public func serialize(params: Parameters) -> NSData? {
        
        
        
        let query:String?
        
        if #available(iOS 8, *) {
            let components = NSURLComponents()
            components.queryItems = params.params.map { (element) -> NSURLQueryItem in
                return NSURLQueryItem(name: element.1.key, value: element.1.value as? String)
            }
            query = components.query
        } else {
            
            query = params.params.enumerate().reduce(String?(), combine: { (query, item:(index: Int, element: (String, Parameter))) -> String? in
                let value = item.element.1.value as? String ?? ""
                let parameterString = "\(item.element.0)=\(value)"
                guard params.params.startIndex.advancedBy(item.index+1) < params.params.endIndex else {
                    return query?.stringByAppendingString(parameterString)
                }
                return query?.stringByAppendingString("\(parameterString)&")
            })
        }
        
        return query?.dataUsingEncoding(NSUTF8StringEncoding)
    }
}




