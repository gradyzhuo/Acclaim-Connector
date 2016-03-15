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
        api.requestTaskType = .DownloadTask(method: .GET, resumeData: nil)
        
        let session = ACURLSession()
        session.request(API: api) { (data, response, error) in
            print(UIImage(data: data!))
        }
//        .setRecevingProcessHandler({ (bytes, totalBytes, totalBytesExpected) in
//            let percent = Float(totalBytes) / Float(totalBytesExpected)
//            print("Hello dataTask percent:\(percent * 100)%")
//        })
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
