//
//  OutOfBoundsViewController.swift
//  BudHero
//
//  Created by Benjamin Harvey on 1/29/16.
//  Copyright © 2016 parse. All rights reserved.
//

import Parse
import UIKit

class OutOfBoundsViewController: UIViewController, UITextViewDelegate {

  var reallocation : [NSString:NSString]?
  
  @IBOutlet weak var emailTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

      self.emailTextView.delegate = self;
        // Do any additional setup after loading the view.
    }

  override func viewDidAppear(animated: Bool) {
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      print("test")
      self.emailTextView.text = ""
      self.emailTextView.becomeFirstResponder()
      
    }
  }

  @IBAction func back(sender: UIButton) {
    self.dismissViewControllerAnimated(true) { () -> Void in
      
      
    }
    
  }
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      
      
      let text = emailTextView.text
      
      var gameScore = PFObject(className: "OutOfRange")
      gameScore.setObject(text, forKey: "email")
      
      if let lat = self.reallocation!["lat"]{
        gameScore.setObject(lat as String, forKey: "lat")
      }
      if let long = self.reallocation!["long"]{
        gameScore.setObject(long as String, forKey: "long")
      }
      

      gameScore.saveInBackgroundWithBlock {
        (success: Bool, error: NSError?) -> Void in
        if (success) {
          // The object has been saved.
          self.dismissViewControllerAnimated(true) { () -> Void in
            
            
          }
        } else {
          // There was a problem, check error.description
          let alert = UIAlertController(title: "Error Please Try Again", message: error?.description, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
      
    }
    return true
  }
  
  func buttonTapped(){
    print("saved")
    
  
  }
  
  
  
  override func shouldAutorotate() -> Bool {
    return false
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
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
