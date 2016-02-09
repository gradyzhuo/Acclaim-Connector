//: Playground - noun: a place where people can play

import UIKit
@testable import Acclaim


var params:RequestParameters = ["key1":"1"]
params.addParamValue(["1","2","3","4"], forKey: "test")


let queryData = JSONParametersSerializer(option: .PrettyPrinted).serialize(params)//QueryStringParametersSerializer().serialize(params)
let str = String(data: queryData!, encoding: NSUTF8StringEncoding)
print(str!)


//let a:[String:AnyObject] = ["test":["hello":"world"]]
//
//let mirror = Mirror(reflecting: a)
//mirror.children.enumerate().forEach { (test) in
//    print(test.element)
//    print(test.index)
//}
//
//mirror.descendant(0, 1, 0)

//class Test:_Reflectable {
//    dynamic var i : Int = 0
//    
//    init(){
//        
//    }
//    
//    func _getMirror() -> _MirrorType {
//        return self
//    }
//    
//}
//
//s
//
//var test = Test()
//var mirror = Mirror(reflecting: test)
//mirror.descendant("i")
//
//""._getMirror()
//
//
//let mirror2 = Mirror("", children: ["hello":"world"])
//
//let ttt:AnyObject? = test
//let ggg:Test = ttt.map{ (item)->Test in return ttt as! Test }!
//
//let aa = [Mirror.Child(label: "", value: "")]
//let children = Mirror.Children(aa)
//
//
//for (_, var attr) in mirror.children.enumerate() {
//    print("attr.label:\(attr.label)")
//    attr.value = 20
////    mirror.children
//}



//test.i

//let utf8 = dispatch_queue_get_label(QueuePriority.Default.queue)
//let identifier = String(CString: utf8, encoding: NSUTF8StringEncoding)

//let param = ACParameter(key: "String", value: "12")
//let param2 = ACParameter(key: "String", value: "21")
//let params = ACParameters(params: [param, param2])
//
//let api = API(URL: NSURL(string: "http://www.google.com")!, method: .GET, paramsType: .JSON)
//Acclaim.runAPI(API: api, params: [param, param2]).addTextResponse { (result, response, error) -> Void in
//    print("result:\(result)")
//}.addResponse(Response<JSON>(handler: { (JSONObject, response, error) -> Void in
//    
//})).addImageResponse { (image, response, error) -> Void in
//    
//}.addTextResponse { (text, response, error) -> Void in
//    
//}
//
//let api2 : API = "http://www.google.com.tw"
//Acclaim.runAPI(API: "http://www.google.com", params: [])
//
//
//struct TestDeserializer : Deserializer {
//    typealias DeserialType = [AnyObject]
//
//    static var identifier: String { return "Test" }
//    static func deserialize(data:NSData) -> (DeserialType?, ErrorType?){
//        return ([], nil)
//    }
//}
//
////let apiCall = ACAPICaller.makeCallAndRun(API: api, params: [param, param2])
////.addResponse(ACAPIResponse.OriginalData({ (data, response, error) -> Void in
////    print("data:\(data)")
////}))
////    .addResponse(ACAPIResponse.JSON({ (JSONOjbect, response, error) -> Void in
////        print("jsonObject")
////}))
////apiCall.api
//
////FIXME: 未來可以加入錯誤的Key，要如何自已處理的方式。
//public protocol Deserializer2 {
//    typealias InstanceType
//    typealias Tuple
//    typealias Handler = (Tuple)->Void
//    
//    static var identifier: String { get }
//    static func deserialize(data:NSData) -> (Self.InstanceType?, ErrorType?)
//    
//}
//
//struct TestDeserializer2 : Deserializer2 {
//    typealias Tuple = (a: String, b: String)
//    typealias InstanceType = (AnyObject)
//    
//    static var identifier: String { return "Test" }
//    static func deserialize(data:NSData) -> (InstanceType?, ErrorType?){
//        return ((t: "123"), nil)
//    }
//    
//    static func myData(handler: ((a: String, b: String))->Void){
//        handler(("1","2"))
//    }
//}
//
//TestDeserializer2.myData { (tuple) -> Void in
//    
//}
