//: Playground - noun: a place where people can play

import UIKit
@testable import Acclaim


//var params:RequestParameters = ["key1":"1"]
//params.addParamValue(["1","2","3","4"], forKey: "test")
//
//
//let queryData = JSONParametersSerializer(option: .PrettyPrinted).serialize(params)//QueryStringParametersSerializer().serialize(params)
//let str = String(data: queryData!, encoding: NSUTF8StringEncoding)
//print(str!)
//


let api:API = "http://www.google.com"

let str = "fling@GET"
let str2 = "fling@DataTask(GET)"



let options:NSRegularExpressionOptions = [NSRegularExpressionOptions.AllowCommentsAndWhitespace]
let expression = try? NSRegularExpression(pattern: "[\\W]", options: options)
let matches = expression?.matchesInString(str, options: NSMatchingOptions.ReportCompletion, range: NSRange(location: 0, length: str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
print(matches)
