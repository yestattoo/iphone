//
//  LoginViewController.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Parse
import Google

class LoginViewController: UIViewController {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendCodeButton: UIButton!

  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!

  var phoneNumber: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    step1()
    sendCodeButton.layer.cornerRadius = 3

    self.editing = true
  }

  override func shouldAutorotate() -> Bool {
    return false
  }
  
  func step1() {
    phoneNumber = ""
    textField.placeholder = NSLocalizedString("numberDefault", comment: "555-333-6726")
    questionLabel.text = NSLocalizedString("enterPhone", comment: "Welcome to Budhero! Please verify your phone #")
    subtitleLabel.text = NSLocalizedString("enterPhoneExtra", comment: "By clicking verify, you acknowledge that you have read and agree to the Privacy Policy & Terms")
    sendCodeButton.enabled = true
    
  }

  func step2() {
    phoneNumber = " " + textField.text!
    textField.text = ""
    textField.placeholder = "1234"
    questionLabel.text = NSLocalizedString("enterCode", comment: "Enter the 4-digit confirmation code:")
    subtitleLabel.text = NSLocalizedString("enterCodeExtra", comment: "It was sent in an SMS message to +1" + phoneNumber) + phoneNumber
    sendCodeButton.enabled = true
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    //textField.becomeFirstResponder()
    textField.endEditing(true)
    
    var tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Login Screen")
    
    var builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
  }

  @IBAction func didTapSendCodeButton() {
    let preferredLanguage = NSBundle.mainBundle().preferredLocalizations[0]

    let textFieldText = textField.text ?? ""

    if phoneNumber == "" {
      if (preferredLanguage == "en" && textFieldText.characters.count != 10)
        || (preferredLanguage == "ja" && textFieldText.characters.count != 11) {
          showAlert("Phone Login", message: NSLocalizedString("warningPhone", comment: "You must enter a 10-digit US phone number including area code."))
          return step1()
      }

      self.editing = false
      let params = ["phoneNumber" : textFieldText, "language" : preferredLanguage]
      PFCloud.callFunctionInBackground("sendCode", withParameters: params) { response, error in
        self.editing = true
        if let error = error {
          var description = error.description
          if description.characters.count == 0 {
            description = NSLocalizedString("warningGeneral", comment: "Something went wrong. Please try again.") // "There was a problem with the service.\nTry again later."
          } else if let message = error.userInfo["error"] as? String {
            description = message
          }
          self.showAlert("Login Error", message: description)
          return self.step1()
        }
        let tracker = GAI.sharedInstance().defaultTracker
        let eventTracker: NSObject = GAIDictionaryBuilder.createEventWithCategory(
          "Send SignUp Code",
          action: "SignUp Button",
          label: "SomeLabel",
          value: nil).build()
        tracker.send(eventTracker as! [NSObject : AnyObject])
        return self.step2()
      }
    } else {
      if textFieldText.characters.count == 4, let code = Int(textFieldText) {
        return doLogin(phoneNumber, code: code)
      }

      showAlert("Code Entry", message: NSLocalizedString("warningCodeLength", comment: "You must enter the 4 digit code texted to your phone number."))
    }
  }

  func doLogin(phoneNumber: String, code: Int) {
    let tracker = GAI.sharedInstance().defaultTracker
    let eventTracker: NSObject = GAIDictionaryBuilder.createEventWithCategory(
      "CodeEntry Attempt",
      action: "Enter Code Button Button",
      label: "SomeLabel",
      value: nil).build()
    tracker.send(eventTracker as! [NSObject : AnyObject])
    
    
    self.editing = false
    let params = ["phoneNumber": phoneNumber, "codeEntry": code] as [NSObject:AnyObject]
    PFCloud.callFunctionInBackground("logIn", withParameters: params) { response, error in
      if let description = error?.description {
        self.editing = true
        return self.showAlert("Login Error", message: description)
      }
      if let token = response as? String {
        PFUser.becomeInBackground(token) { user, error in
          if let _ = error {
            self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something happened while trying to log in.\nPlease try again."))
            self.editing = true
            return self.step1()
          }
          //success
          print("success")
          
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let vc : RequestViewController = storyboard.instantiateViewControllerWithIdentifier("RequestViewController") as! RequestViewController
          
          return self.presentViewController(vc, animated: true, completion: nil)
          
          //return self.loginLayer()
        }
      } else {
        self.editing = true
        self.showAlert("Login Error", message: NSLocalizedString("warningGeneral", comment: "Something went wrong.  Please try again."))
        return self.step1()
      }
    }
  }

  override func setEditing(editing: Bool, animated: Bool) {
    sendCodeButton.enabled = editing
    textField.enabled = editing
    if editing {
      //textField.becomeFirstResponder()
    }
  }

  func showAlert(title: String, message: String) {
    return UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: NSLocalizedString("alertOK", comment: "OK")).show()
  }

  @IBAction func goTioPrivacy(sender: UIButton) {
    if let url = NSURL(string: "http://www.budhero.com/privacy") {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  @IBAction func goToTerms(sender: UIButton) {
    if let url = NSURL(string: "http://www.budhero.com/terms") {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .Default
  }
}


extension LoginViewController : UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.didTapSendCodeButton()
    
    return true
  }
  
}
