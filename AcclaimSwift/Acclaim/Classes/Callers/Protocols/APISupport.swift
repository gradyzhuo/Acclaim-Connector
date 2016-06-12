//
//  APISupport.swift
//  Pods
//
//  Created by Grady Zhuo on 5/20/16.
//
//

public protocol APISupport : Configurable {
    var api:API                   { get }
    var params:Parameters         { get }
}

internal protocol _APISupport : APISupport {
    var api:API               { set get }
    var params:Parameters { set get }
}
