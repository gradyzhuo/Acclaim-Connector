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
    
    static var previousCancelledResumeData: NSData?
    
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
        
        self.apiCaller?.cancel(handler: { (resumeData) in
            DownloadTaskViewController.previousCancelledResumeData = resumeData
        })
        
        self.apiCaller = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func run(sender: AnyObject){
        
        guard let urlString = self.urlTextField?.text, let url = NSURL(string: urlString) else{
            return
        }
        
        guard let api:API = API(URL: url, method: .GET) else{
            return
        }
        
        guard self.apiCaller == nil else{
            return
        }
        
        self.apiCaller = Acclaim.download(API: api)
        self.apiCaller?.cancel()
        
        self.apiCaller?.handleImage(scale: 1.0, handler: {[unowned self] (image, connection) in
            self.resultImageView.image = image
            self.resultImageView.layer.addAnimation(CATransition(), forKey: "transition")
        })
        
        self.apiCaller?.observer(recevingProcess: {[weak self] (bytes, totalBytes, totalBytesExpected) in
            let percent = Float(totalBytes) / Float(totalBytesExpected)

            self?.processBar.setProgress(percent, animated: true)
            self?.processLabel?.text = "\(percent * 100)%"
        }).failed { (result) in
            
            }.cancelled { (resumeData, connection) in
//                DownloadTaskViewController.previousCancelledResumeData = resumeData
                print("cancel, resumeData:\(resumeData?.length)")
        }
        
        let continueClosure = {[unowned self] (action: AnyObject?)->Void in
            self.apiCaller?.resume()
        }
        
        if let previousCancelledResumeData = DownloadTaskViewController.previousCancelledResumeData {
            
            let alert = UIAlertController(title: "Continue Donwolding?", message: "It's found a privous cancelled resume data, should continue?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Should", style: .Default, handler: {[unowned self]  (_) in
                
                self.apiCaller?.taskType = .DownloadTask(resumeData: previousCancelledResumeData)
                self.apiCaller?.resume()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: continueClosure))
            self.presentViewController(alert, animated: true, completion: nil)

        }else{
            
            continueClosure(nil)
        }
        
        
    }
    
    deinit{
        print("deinit")
    }
    
}
