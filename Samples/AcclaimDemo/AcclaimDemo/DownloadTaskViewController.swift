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
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var processBar: UIProgressView!
    @IBOutlet weak var processLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    
    var apiCaller: Downloader?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.urlTextField?.text = "https://upload.wikimedia.org/wikipedia/commons/2/28/Frangipani_rust_(caused_by_Coleosporium_plumeriae)_on_Plumeria_rubra.jpg"
        
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.apiCaller?.cancel()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func run(sender: AnyObject){
        
        guard let urlString = self.urlTextField?.text, let url = NSURL(string: urlString) else{
            return
        }
        
        guard let api:API = API(URL: url) else{
            return
        }
        
        api.requestTaskType = .DownloadTask()
        
        self.apiCaller = Acclaim.download(API: api)
        
        self.apiCaller?.handleImage(scale: 1.0, handler: { (image, connection) in
            self.resultImageView.image = image
            self.resultImageView.layer.addAnimation(CATransition(), forKey: "transition")
        })
        
        self.apiCaller?.observer(recevingProcess: { (bytes, totalBytes, totalBytesExpected) in
            let percent = Float(totalBytes) / Float(totalBytesExpected)
            
            self.processBar.setProgress(percent, animated: true)
            self.processLabel?.text = "\(percent * 100)%"
        }).failed { (result) in
                
        }.cancelled { (resumeData, connection) in
            print("cancel")
        }
    }
    
}
