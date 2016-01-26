//
//  ViewController.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Parse

class InitialViewController: UIViewController {

  override func viewDidAppear(animated: Bool) {
    if let _ = PFUser.currentUser() {
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc : RequestViewController = storyboard.instantiateViewControllerWithIdentifier("RequestViewController") as! RequestViewController
      
      self.presentViewController(vc, animated: true, completion: nil)
      
      
    } else {
      self.performSegueWithIdentifier("toLogin", sender: self)
    }
  }
}
