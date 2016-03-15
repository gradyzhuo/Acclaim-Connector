//
//  ACHTTPMethod.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/25/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation
import Acclaim

@objc
public enum ACHTTPMethod : Int {
    
    case GET
    
    case POST
    case PUT
    case DELETE
}

@objc
public enum ACSerializerType : Int {
    case QueryString
    case JSON
    case MultipartForm
}

internal func ACMethodMake(method: ACHTTPMethod, serializerType: ACSerializerType?)->HTTPMethod{
    
    if let serializerType = serializerType where method != .GET{
        
        var type = SerializerType.QueryString
        
        if serializerType == ACSerializerType.JSON {
            type = SerializerType.JSON(option: .PrettyPrinted)
        }
        
        switch method {
        case .GET:
            return HTTPMethod.GET
        case .POST:
            return HTTPMethod.POSTWith(serializer: type)
        case .PUT:
            return HTTPMethod.PUTWith(serializer: type)
        case .DELETE:
            return HTTPMethod.DELETEWith(serializer: type)
        }
    }
    
    switch method {
    case .GET:
        return HTTPMethod.GET
    case .POST:
        return HTTPMethod.POST
    case .PUT:
        return HTTPMethod.PUT
    case .DELETE:
        return HTTPMethod.DELETE
    }
}