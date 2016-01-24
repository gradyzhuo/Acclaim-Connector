//
//  AppDelegate.swift
//  Sample
//
//  Created by Grady Zhuo on 8/12/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import Acclaim

struct TestDeserializer : Deserializer {
    typealias InstanceType = (AnyObject)
    
    static var identifier: String { return "Test" }
    
    func deserialize(data: NSData, URLResponse: NSURLResponse?, connectionError: ErrorType?) -> (InstanceType?, ErrorType?) {
        return ((t: "123"), nil)
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
        api.method = "GET"

//        Acclaim :: "fling" :: "GET" << (success:"") << (data: "")
        
        weak var caller:APICaller? = Acclaim.runAPI(API: api, params: ["fling_hash":"dQAXWbcv"])
        caller?.addJSONResponseHandler { (JSONObject, error) -> Void in
            print("JSONObject:\(JSONObject), caller.response:\(caller?.response)")
            
        }

        
//        let caller = ACAPICaller(API: api, params: ["fling_hash":"dQAXWbcv"])
//        caller.addFailedResponseHandler { (data, response, error) -> Void in
//            print("result:\(data)")
//        }.addJSONResponseHandler { (JSONObject, response, error) -> Void in
//            print("JSONObject:\(JSONObject)")
//            if let dict = JSONObject as? [String: AnyObject] {
//                print("dict:\(dict)")
//            }
//        }.run().cancel()
        
        
        return true
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

