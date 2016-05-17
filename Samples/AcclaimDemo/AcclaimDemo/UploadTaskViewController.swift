//
//  UploadTaskViewController.swift
//  AcclaimDemo
//
//  Created by Grady Zhuo on 3/12/16.
//  Copyright © 2016 Offsky. All rights reserved.
//

import UIKit
import Acclaim

class UploadTaskViewController: UIViewController {

    var apiCaller: Uploader?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var params = Parameters()
        params.add(image: UIImage(named: "limbic"), decoder: .JPEG(quality: 0.8), forKey: "image_file")
        params.add(string: "LpJTZz8sePiBRWgdNz084JJHD7Bfys1hQnLM2U66", forKey: "access_token")
        
        let api: API = "image"
        api.requestTaskType = .UploadTask(method: .POST)
        
        self.apiCaller = Acclaim.upload(API: api, params: params)
        self.apiCaller?.handleObject{ (JSONObject, connection) in
            print("result:", JSONObject)
        }
        
        self.apiCaller?.observer(sendingProcess: { (bytes, totalBytes, totalBytesExpected) in
            let percent = Float(totalBytes) / Float(totalBytesExpected)
            print("percent:\(percent * 100)%")
        }).failed { (result) in
            print("result:\(result.error)")
        }.cancelled { (resumeData, connection) in
            print("cancelled")
        }

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.apiCaller?.cancel()
        
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
