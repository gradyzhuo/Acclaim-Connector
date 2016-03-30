
//
//  DataTaskViewController.swift
//  AcclaimDemo
//
//  Created by Grady Zhuo on 3/12/16.
//  Copyright © 2016 Offsky. All rights reserved.
//

import UIKit
import Acclaim

class DataTaskViewController: UIViewController {

    var apiCaller: RestfulAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let api:API = "fling"
//        self.apiCaller = Acclaim.call(API: api,  params: ["fling_hash":"dQAXWbcv"])
//        .addFailedResponseHandler { (result) in
//            print("failed:\(result.error)")
//        }.addJSONResponseHandler { (result) in
//            print("cached: \(result.connection.cached)")
//            print("result.JSONObject:\(result.JSONObject)")
//        }.addJSONResponseHandler(handler: { (JSONObject, connection) in
//            
//        })
        
        let api:API = "http://data.taipei/opendata/datalist/apiAccess?scope=datasetMetadataSearch"
        let APICaller = RestfulAPI(API: api, params: ["scope":"datasetMetadataSearch", "q":"id:8ef1626a-892a-4218-8344-f7ac46e1aa48"])
        APICaller.addJSONResponseHandler(keyPath: "result.count"){ (JSONObject, connection) in
            print("JSONObject", JSONObject)
        }.run()
        
        
        
        
        //.cacheStoragePolicy = .NotAllowed//.Allowed(renewRule: .RenewSinceData(data: NSDate().dateByAddingTimeInterval(1)))
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.apiCaller?.cancel()
        self.apiCaller = nil
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
