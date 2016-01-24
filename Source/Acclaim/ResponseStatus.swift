//
//  ResponseStatus.swift
//  Acclaim
//
//  Created by Grady Zhuo on 1/20/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation


public protocol ResponseSpot{
    static func shouldHandle(spot: Spot)->Bool
}

public enum Spot {
    case HTTPStatusCode(statusCode: Int)
}