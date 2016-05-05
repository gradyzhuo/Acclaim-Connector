//
//  DownloadTaskViewController.swift
//  AcclaimDemo
//
//  Created by Grady Zhuo on 3/12/16.
//  Copyright © 2016 Offsky. All rights reserved.
//

import UIKit
import Acclaim

class DownloadTaskViewController: UIViewController {

    var apiCaller: Downloader?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let api:API = "https://upload.wikimedia.org/wikipedia/commons/2/28/Frangipani_rust_(caused_by_Coleosporium_plumeriae)_on_Plumeria_rubra.jpg"
        api.requestTaskType = .DownloadTask()
        
//        self.apiCaller = Acclaim.download(API: api)
        
        Acclaim.download(API: api)
        
        self.apiCaller = Acclaim.download(API: api)
        self.apiCaller?.addImageResponseHandler { (image, connection) in
            print(image)
        }
            
        self.apiCaller?.setRecevingProcessHandler { (bytes, totalBytes, totalBytesExpected) -> Void in
            let percent = Float(totalBytes) / Float(totalBytesExpected)
            print("Hello dataTask percent:\(percent * 100)%")
        }.addFailedResponseHandler(handler: { (result) in
            
        }).setCancelledResponseHandler({ (resumeData, connection) in
            print("cancel")
        })
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
