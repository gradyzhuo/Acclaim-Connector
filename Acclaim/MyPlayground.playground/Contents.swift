//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"



struct Test : StringLiteralConvertible {
    
    typealias StringLiteralType = String
    typealias ExtendedGraphemeClusterLiteralType = String
    typealias UnicodeScalarLiteralType = String
    
    var key:String
    
    
    init(key:String){
        self.key = key
    }
    
    private init(key:String, from:String){
        self.init(key: key)
        
        print("from:\(from)")
    }
    
    init(stringLiteral value: StringLiteralType){
        self.init(key: value, from: "StringLiteralType")
        
        print("1")
    }
    
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType){
        self.init(key: value, from: "ExtendedGraphemeClusterLiteralType")
        
        print("2")
    }
    
    
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType){
        self.init(key: value, from: "UnicodeScalarLiteralType")
        print("3")
    }
    
    
}


func tttt(a:Test){
    print(a.key)
}

tttt("abc")




class Test4 {
    
}

enum MM {
    case H
}

extension Test4 {
    
    typealias Method = MM
    
}


let a = class_getName(NSString)
let aa = NSString(CString: a, encoding: NSUTF8StringEncoding)
var runningQueue:dispatch_queue_t = dispatch_queue_create(class_getName(NSString), DISPATCH_QUEUE_SERIAL)



var t = "post"
t.uppercaseString
