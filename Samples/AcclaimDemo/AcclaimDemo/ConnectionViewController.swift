//
//  ConnectionViewController.swift
//  AcclaimDemo
//
//  Created by Grady Zhuo on 3/12/16.
//  Copyright © 2016 Offsky. All rights reserved.
//

import UIKit
import Acclaim

class ConnectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let api:API = "fling"
//        let param = FormParameter(key: "fling_hash", value: "dQAXWbcv")
//        
        let api:API = "https://upload.wikimedia.org/wikipedia/commons/2/28/Frangipani_rust_(caused_by_Coleosporium_plumeriae)_on_Plumeria_rubra.jpg"
        
//        let streamAPI: API = "http://live.leanstream.co/ICRTFM?args=tunein_aac"
        let session = URLSession()
//
//        
//        let service = NSNetService(domain: "live.leanstream.co", type: "_ipp._tcp", name: "")
//        
//        session.request(API: streamAPI, requestTaskType: .StreamTask(service: service)) { (data, response, error) in
//            print("here")
//        }
        
        
        session.request(API: api) { (data, response, error) in
            print(UIImage(data: data!))
        }
        

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
