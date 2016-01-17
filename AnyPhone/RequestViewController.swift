//
//  RequestViewController.swift
//  AnyPhone
//
//  Created by Benjamin Harvey on 1/16/16.
//  Copyright © 2016 parse. All rights reserved.
//

import UIKit
import Parse

class RequestViewController: UIViewController, CLLocationManagerDelegate {
  
  var manager: OneShotLocationManager?
  var reallocation : [NSString:NSString]?
  
  
  
  @IBOutlet weak var requestButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      self.requestButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
      }
  
  func buttonAction(sender:UIButton!)
  {
    
    self.sendRequest()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    manager = OneShotLocationManager()
    manager!.fetchWithCompletion { (location, error) -> () in
      
      if let loc = location {
        
        
        var latitudeText:String = "\(location!.coordinate.latitude)"
        
        var longitudeText:String = "\(location!.coordinate.longitude)"
        
        
        self.reallocation = ["lat":latitudeText,"long":longitudeText]
        
        
        print(self.reallocation)

      } else if let err = error {
        NSLog(err.localizedDescription)
      }
      self.manager = nil
    }
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func goToReq(){
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("OrderViewController")
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
  func sendRequest(){
    PFCloud.callFunctionInBackground("request", withParameters: ["location" : self.reallocation!], block: { (object: AnyObject?, error) -> Void in
      if error == nil {
        
        self.goToReq()
        
      } else {
        NSLog("sent")
        // Do error handling
      }
    })
  }

}
