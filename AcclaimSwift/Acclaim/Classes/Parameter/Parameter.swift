//
//  Parameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Parameter {
    var key: String { get }
}


public protocol ParameterValueType{ }

extension String : ParameterValueType{ /* not implemented.*/ }
extension Int: ParameterValueType{ /* not implemented.*/ }