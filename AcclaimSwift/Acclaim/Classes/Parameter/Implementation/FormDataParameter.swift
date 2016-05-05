//
//  FormDataParameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public struct FormDataParameter : Parameter {
    public internal(set) var key: String
    public internal(set) var data: NSData
    public internal(set) var fileName: String
    public internal(set) var MIME: String
    
    public init(key: String, data: NSData, fileName: String = "", MIME: String = ""){
        self.key = key
        self.data = data
        self.fileName = fileName
        self.MIME = MIME
    }
}

