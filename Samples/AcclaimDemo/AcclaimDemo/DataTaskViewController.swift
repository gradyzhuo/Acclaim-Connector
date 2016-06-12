
//
//  DataTaskViewController.swift
//  AcclaimDemo
//
//  Created by Grady Zhuo on 3/12/16.
//  Copyright © 2016 Offsky. All rights reserved.
//

import UIKit
import Acclaim

//class Test : Mappable {
//    static var mappingTable: [String : String]{
//       return ["":""]
//    }
//    
//    required init(){
//        
//    }
//}

class DataTaskViewController: UIViewController {

    var apiCaller: RestfulAPI?
    
    @IBOutlet weak var urlTextField: UITextField?
    @IBOutlet weak var resultTextView: UITextView?
    @IBOutlet weak var processBar: UIProgressView?
    @IBOutlet weak var keyPathTextField: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.urlTextField?.text = "http://data.taipei/opendata/datalist/apiAccess"
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.apiCaller?.cancel()
        
    }

    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func run(){
        
        self.view.endEditing(true)
        
        let api = API(URL: NSURL(string: self.urlTextField!.text!)!, method: .GET)
        
        let APICaller = RestfulAPI(API: api, paramsDict: ["scope":"datasetMetadataSearch", "q":"id:8ef1626a-892a-4218-8344-f7ac46e1aa48"])
        
//        let APICaller = RestfulAPI(API: api, params: [Parameter](dictionary: ["scope":"datasetMetadataSearch", "q":"id:8ef1626a-892a-4218-8344-f7ac46e1aa48"]))
        
//        let APICaller = RestfulAPI(API: "http://images.apple.com/tw/hotnews/promos/images/promo_event_2x.jpg")
        
        if let keyPath = self.keyPathTextField?.text {
            
            APICaller.handle(responseType: .Success, assistant: JSONResponseAssistant(forKeyPath: KeyPath(path: keyPath)) {[unowned self] (JSONObject, connection) in
                
                guard let JSONObject = JSONObject else{
                    self.resultTextView?.text = "nil"
                    return
                }
                
                self.resultTextView?.text = String(JSONObject)
            })

            
//            APICaller.handleObject(keyPath: KeyPath(path: keyPath)){[unowned self] (JSONObject, connection) in
//                
//                guard let JSONObject = JSONObject else{
//                    self.resultTextView?.text = "nil"
//                    return
//                }
//                
//                self.resultTextView?.text = String(JSONObject)
//            }
            
        }
        
        APICaller.handle(responseType: .Success, assistant: ImageResponseAssistant(handler: { (image, connection) in
            print("image:\(image)")
        })).failed { (assistant, data, error) in
            
        }
//        APICaller.failed(deserializer: TextDeserializer()) { (outcome, connection, error) in
//            print("outcome: \(outcome), error:\(error)")
//        }
        
        APICaller.cancelled { (resumeData, connection) in
            print("cancelled resumeData: \(resumeData)")
        }
        
        APICaller.resume()
        
        self.apiCaller = APICaller
    }
    
    @IBAction func keyPathDidInput(sender: UITextField){
        sender.resignFirstResponder()
    }

}
