//
//  UpdateAddyViewController.swift
//  BudHero
//
//  Created by Benjamin Harvey on 1/25/16.
//  Copyright © 2016 parse. All rights reserved.
//

import UIKit

class UpdateAddyViewController: UIViewController , UITextViewDelegate{

  @IBOutlet weak var addressTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

      addressTextView.delegate = self
        // Do any additional setup after loading the view.
      
      
      addressTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      self.dismissViewControllerAnimated(true, completion: { () -> Void in
        print("bam")
      })
      return false
    }
    return true
  }
  @IBAction func backPress(sender: UIButton) {
    self.dismissViewControllerAnimated(true) { () -> Void in
      
      
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

}
