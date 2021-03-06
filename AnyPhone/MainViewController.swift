//
//  MainViewController.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Parse
import Google

class MainViewController: UIViewController , MultipleChoiceControllerDelegate {

  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var nameTextField: UITextField!

  @IBOutlet weak var setting1: UISwitch!
  @IBOutlet weak var setting2: UISwitch!
  @IBOutlet weak var setting3: UISwitch!

  @IBOutlet weak var saveSettingsButton: UIButton!

  var user: PFUser? = PFUser.currentUser()

  override func viewDidLoad() {
    super.viewDidLoad()

    nameTextField.delegate = self
    saveSettingsButton.layer.cornerRadius = 3
    print(PFUser.currentUser())
    if let user = self.user {
      usernameLabel.text = user.username
      
      
      let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
      //add name to install
      let channelName = "to" + user.username!
      currentInstallation.addUniqueObject(channelName, forKey: "channels")
      currentInstallation.saveInBackground()
      
      
      if let name = user["name"] as? String {
        nameTextField.text = name
      }
      checkSettingsForUser(user)
    } else {
      print("hi")
      dismissViewControllerAnimated(true, completion: nil)
    }

  }

  @IBAction func backClick(sender: UIButton) {
    self.dismissViewControllerAnimated(true) { () -> Void in
      
      
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    var tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Settings Sreen")
    
    var builder = GAIDictionaryBuilder.createScreenView()
  
    tracker.send(builder.build() as [NSObject : AnyObject])
    
    
    delay(1000) { () -> () in
      self.setting3.setOn(true, animated: true)
    }
  }
  

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  @IBAction func didTapLogOut(sender: AnyObject) {
    PFUser.logOutInBackgroundWithBlock { error in
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc : LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
      
      self.presentViewController(vc, animated: true, completion: nil)
    
    }
  }

  @IBAction func didTapSaveSettings(sender: AnyObject) {
    if let user = self.user {
      if nameTextField.text != "" {
        user["name"] = nameTextField.text
      }
      if checkSetting(user, settingName: "flower") != setting1.on {
        user["flower"] = setting1.on
      }
      if checkSetting(user, settingName: "edible") != setting2.on {
        user["edible"] = setting2.on
      }
      if checkSetting(user, settingName: "concentrate") != setting3.on {
        user["concentrate"] = setting3.on
      }
      user.saveEventually()
      NSLog("saving " );
      
      self.goToReq()
      
      
      
    } else {
      print("hiiii")
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  func goToReq(){
    dismissViewControllerAnimated(true, completion: nil)

  }

  func checkSetting(user: PFUser, settingName : String) -> Bool {
    if let value = user[settingName] as? Bool {
      return value
    }
    return false
  }
  
  func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }

  @IBAction func quizClick(sender: UIButton) {
    
    let vc = MultipleChoiceController(style: UITableViewStyle.Grouped)
    vc.choices = ["Apples", "Oranges", "Bananas", "Oranges3", "Bananas3"] //Provide an array of choices. These must be NSObjects.
    
    vc.allowMultipleSelections = true
    vc.maximumAllowedSelections = 2 // Optional, limits selection.
    
    vc.header = "Choose some fruits" // A header that appears before the list.
    vc.footer = "Make sure to choose some delicious ones!" //A footer that appears after the list.
    vc.delegate = self //Implement the MultipleChoiceControllerDelegate protocol to handle selections.
    
    self.presentViewController(vc, animated: true) { () -> Void in
      
      
      
    }    
    
  }
  
  /* Delegate method when selection is finished */
  
  func multipleChoiceController(controller: MultipleChoiceController, didSelectItems items: [NSObject]) {
    //Do something with the "items" the user selected.
    navigationController?.popViewControllerAnimated(true)
  }
  @IBAction func clickedPrivacy(sender: UIButton) {
    if let url = NSURL(string: "http://www.budhero.com/privacy") {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  @IBAction func clickedTerms(sender: UIButton) {
    if let url = NSURL(string: "http://www.budhero.com/terms") {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  func checkSettingsForUser(user: PFUser) {
    if checkSetting(user, settingName: "flower") {
      setting1.setOn(true, animated: false)
      
    }
    if checkSetting(user, settingName: "edible") {
      setting2.setOn(true, animated: false)
    }
    if checkSetting(user, settingName: "concentrate") {
      setting3.setOn(true, animated: false)
    }
  }
  override func shouldAutorotate() -> Bool {
    return false
  }
}

func delay(delay:Double, closure:()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(), closure)
}




extension MainViewController : UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    nameTextField.resignFirstResponder()
    return true
  }
}
