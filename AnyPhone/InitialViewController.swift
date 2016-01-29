//
//  ViewController.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Parse
import Google

class InitialViewController: UIViewController {

  override func viewDidAppear(animated: Bool) {
    
    var tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Initial Screen")
    
    var builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
    
    
    if let _ = PFUser.currentUser() {
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc : RequestViewController = storyboard.instantiateViewControllerWithIdentifier("RequestViewController") as! RequestViewController
      
      self.presentViewController(vc, animated: true, completion: nil)
      
      
    } else {
      self.performSegueWithIdentifier("toLogin", sender: self)
    }
  }
}
