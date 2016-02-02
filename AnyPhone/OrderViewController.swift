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
import MessageUI
import Google

class OrderViewController: UIViewController, MFMessageComposeViewControllerDelegate {

  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var messageButton: UIButton!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
      
      self.cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
      self.messageButton.addTarget(self, action: "message", forControlEvents: UIControlEvents.TouchUpInside)
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  func message(){
    if (MFMessageComposeViewController.canSendText()) {
      let controller = MFMessageComposeViewController()
      controller.body = "BudHero Message:  "
//      controller.recipients = ["14154624372"]
      controller.recipients = ["14086551636"]
      controller.messageComposeDelegate = self
      self.presentViewController(controller, animated: true, completion: nil)
    }
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    self.layerClient = appDelegate.layerClient
//    conversationListViewController = ConversationListViewController(layerClient: self.layerClient)
//    conversationListViewController.displaysAvatarItem = true
//    self.presentViewController(conversationListViewController, animated: true, completion: nil)
  }
  
  func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
    //... handle sms screen actions
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    self.navigationController?.navigationBarHidden = false
  }
  
  override func viewWillAppear(animated: Bool) {
    var tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Order Sreen")
    
    var builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
    
  }
  
  override func shouldAutorotate() -> Bool {
    return false
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
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
