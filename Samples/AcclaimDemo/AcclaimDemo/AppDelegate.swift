//
//  AppDelegate.swift
//  Sample
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
@testable import Acclaim

//protocol Model:class, NSObjectProtocol {
//    var model:[String: Any] { set get }
//    
//    init(model: [String: Any])
//    
//    func set(key key: String, value:Any)
//    func get(key key: String) -> Any?
//}
//
//extension Model {
//    func set(key key: String, value:Any){
//        self.model[key] = value
//    }
//    
//    func get(key key: String)->Any?{
//        return self.model[key]
//    }
//}
//
//struct Mapping<ModelType:Model> {
//    typealias MappingTable = [String:Any]
//    
//    var table:MappingTable = [:]
//    
//    func map(model: [String: Any])->ModelType{
//        return ModelType(model: model)
//    }
//    
//    init(table: MappingTable){
//        self.table = table
//    }
//    
//}
//
//
//class Fling : NSObject, Model {
//    var model:[String: Any] = [:]
//    required init(object: AnyObject) {
//        self.object = object
//    }
//}

struct MyDeserializer : ResponseDeserializer {
    typealias CallbackType = JSONResponseDeserializer.CallbackType

    func deserialize(data:NSData?, connection: Acclaim.Connection, connectionError error: ErrorType?) -> (CallbackType?, ErrorType?){
        let deserializer = JSONResponseDeserializer(keyPath: "data", options: .AllowFragments)
        return deserializer.deserialize(data, connection: connection, connectionError: error)
    }
    
    init(){
        
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let api:API = "fling"
//        api.requestTaskType = .UploadTask(data: NSData())
        api.configRequest { (request) -> Void in
            print("headerFields:\(request.allHTTPHeaderFields)")
        }
        
//        let assistant = JSONResponseAssistant(forKeyPath: "data.content.image.url", option: .AllowFragments, handler: { (result) in
//            
////            if let urlString = result.JSONObject as? String, url = NSURL(string: urlString) {
////                let task:NSURLSessionDownloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (url, response, error) in
////                    print("url:\(url)")
////                    print("data:\(NSData(contentsOfURL: url!))")
////                    
////                })
////                task.resume()
////            }
//////            print("result.JSONObject:\(result.JSONObject)")
//        })
        
        let param = FormParameter(key: "fling_hash", value: "dQAXWbcv")
        
        let api2:API = "https://upload.wikimedia.org/wikipedia/commons/2/28/Frangipani_rust_(caused_by_Coleosporium_plumeriae)_on_Plumeria_rubra.jpg"
        api2.requestTaskType = .DownloadTask(method: .GET, resumeData: nil)
        
//        Acclaim.runAPI(API: api2,  params: [param])
//        .addResponseAssistant(responseAssistant: assistant)
//        .addFailedResponseHandler(statusCode: 404) { (result) in
//            print("result:\(result.connection.response)")
//        }.addFailedResponseHandler { (result) in
//            print("failed:\(result.error)")
//        }.addJSONResponseHandler { (result) in
//            print("cached: \(result.connection.cached)")
//            print("result.JSONObject:\(result.JSONObject)")
////            Acclaim.defaultConnector = URLSession()
//        }.sessionTask?.error//.cacheStoragePolicy = .NotAllowed//.Allowed(renewRule: .RenewSinceData(data: NSDate().dateByAddingTimeInterval(1)))
//        .api.method = .POST
        
//        Acclaim.defaultConnector = URLSession()
        
        
//        Acclaim.runAPI(API: api2,  params: [param])
//        .addImageResponseHandler { (result) in
//            print(result.image)
//        }.addRecevingProcessHandler { (bytes, totalBytes, totalBytesExpected) -> Void in
//            let percent = Float(totalBytes) / Float(totalBytesExpected)
//            print("Hello dataTask percent:\(percent * 100)%")
//                
//        }.addSendingProcessHandler { (bytes, totalBytes, totalBytesExpected) -> Void in
//            let percent = Float(totalBytes) / Float(totalBytesExpected)
//            print("2: Hello dataTask percent:\(percent * 100)%")
//        }
        
        let image = UIImage(named: "limbic")
        print("image:\(image)")
        
        var params = RequestParameters()
        params.addFormData(UIImagePNGRepresentation(image!), forKey: "image_file", fileName: "limbic.png", MIME: "image/png")
        params.addParamValue("LpJTZz8sePiBRWgdNz084JJHD7Bfys1hQnLM2U66", forKey: "access_token")
        
        let api3: API = "http://api.flin.gy/rest/image"
        api3.requestTaskType = .UploadTask(method: .POST)
        Acclaim.runAPI(API: api3, params: params).addJSONResponseHandler { (result) in
            print("result:", result.JSONObject)
        }.setSendingProcessHandler { (bytes, totalBytes, totalBytesExpected) in
            let percent = Float(totalBytes) / Float(totalBytesExpected)
            print("percent:\(percent * 100)%")
        }
        
        
        
        return true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("change:\(change)")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

