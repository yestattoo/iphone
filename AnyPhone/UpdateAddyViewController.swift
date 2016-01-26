//
//  UpdateAddyViewController.swift
//  BudHero
//
//  Created by Benjamin Harvey on 1/25/16.
//  Copyright © 2016 parse. All rights reserved.
//

import UIKit
import MapKit


protocol UpdateAddyViewControllerDelegate {
  func doSomethingWithData(data: CLLocation)
}


class UpdateAddyViewController: UIViewController , UITextViewDelegate{

  @IBOutlet weak var addressTextView: UITextView!
  var delegate: UpdateAddyViewControllerDelegate?
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

      self.addressTextView.delegate = self
        // Do any additional setup after loading the view.
      
      
    }
  
  override func viewDidAppear(animated: Bool) {

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      print("test")
      self.addressTextView.text = ""
      self.addressTextView.becomeFirstResponder()

    }
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      
      
      
      
      let request = MKLocalSearchRequest()
      request.naturalLanguageQuery = addressTextView.text
      
      let search = MKLocalSearch(request: request)
      search.startWithCompletionHandler { response, error in
        guard let response = response else {
          print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
          return
        }
        
      
        var location = response.mapItems.first!.placemark.location
        
        print(location)
        
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
          self.delegate?.doSomethingWithData(location!)
        })
      }
    }
    return true
  }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
