//
//  Configurable.swift
//  Pods
//
//  Created by Grady Zhuo on 5/20/16.
//
//

public protocol Configurable {
    var configuration: Acclaim.Configuration { set get }
    var taskType: RequestTaskType { set get }
}