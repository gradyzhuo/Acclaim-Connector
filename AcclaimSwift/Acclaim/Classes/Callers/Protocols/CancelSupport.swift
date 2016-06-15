//
//  CancelSupport.swift
//  Pods
//
//  Created by Grady Zhuo on 5/20/16.
//
//

public protocol CancelSupport:class {
    var cancelledAssistant: Assistant? { get }
    
    func cancelled(_ handler:ResumeDataResponseAssistant.Handler)->Self
}
