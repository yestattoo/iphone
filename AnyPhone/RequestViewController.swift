//
//  RequestViewController.swift
//  AnyPhone
//
//  Created by Benjamin Harvey on 1/16/16.
//  Copyright © 2016 parse. All rights reserved.
//

import UIKit
import Parse

class RequestViewController: UIViewController {
  @IBOutlet weak var requestButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      self.requestButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
      }
  
  func buttonAction(sender:UIButton!)
  {
    NSLog("Tapped")
    
    PFCloud.callFunctionInBackground("request", withParameters: ["address" : "934 Howard Street SF CA"], block: { (object: AnyObject?, error) -> Void in
      if error == nil {

      } else {
        NSLog("sent")
        // Do error handling
      }
    })
    
    
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
