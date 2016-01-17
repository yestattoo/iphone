//
//  OrderViewController.swift
//  BudHero
//
//  Created by Benjamin Harvey on 1/16/16.
//  Copyright © 2016 parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class OrderViewController: UIViewController {

  @IBOutlet weak var cancelButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
      
      self.cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)

      
      
      
      let alert = UIAlertView()
      alert.title = "Request Sent!"
      alert.message = "Your bud is on the way!"
      alert.addButtonWithTitle("Thanks!")
      alert.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func cancel(){
    
    PFCloud.callFunctionInBackground("cancel", withParameters: nil, block: { (object: AnyObject?, error) -> Void in
      if error == nil {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
          NSLog("canceled")
        })
        
      } else {
        // Do error handling
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
          NSLog("canceled with error")
        })
      }
    })
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
