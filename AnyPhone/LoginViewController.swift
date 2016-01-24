//
//  LoginViewController.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Bolts
import Parse
import Atlas

class LoginViewController: UIViewController {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendCodeButton: UIButton!

  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!

  var phoneNumber: String = ""
  
  var layerClient: LYRClient!

  override func viewDidLoad() {
    super.viewDidLoad()
    step1()
    sendCodeButton.layer.cornerRadius = 3

    self.editing = true
    
    if (PFUser.currentUser() != nil) {
      self.loginLayer()
      return
    }
  }

  func step1() {
    phoneNumber = ""
    textField.placeholder = NSLocalizedString("numberDefault", comment: "555-333-6726")
    questionLabel.text = NSLocalizedString("enterPhone", comment: "Please enter your phone number to log in.")
    subtitleLabel.text = NSLocalizedString("enterPhoneExtra", comment: "This example is limited to 10-digit US number.")
    sendCodeButton.enabled = true
  }

  func step2() {
    phoneNumber = textField.text!
    textField.text = ""
    textField.placeholder = "1234"
    questionLabel.text = NSLocalizedString("enterCode", comment: "Enter the 4-digit confirmation code:")
    subtitleLabel.text = NSLocalizedString("enterCodeExtra", comment: "It was sent in an SMS message to +1" + phoneNumber) + phoneNumber
    sendCodeButton.enabled = true
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    textField.becomeFirstResponder()
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
          return self.loginLayer()
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
      textField.becomeFirstResponder()
    }
  }

  func showAlert(title: String, message: String) {
    return UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: NSLocalizedString("alertOK", comment: "OK")).show()
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .Default
  }
  
  func loginLayer() {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    self.layerClient = appDelegate.layerClient
    
    self.layerClient.connectWithCompletion { success, error in
      if (!success) {
        print("Failed to connect to Layer: \(error)")
      } else {
        let userID: String = PFUser.currentUser()!.objectId!
        // Once connected, authenticate user.
        // Check Authenticate step for authenticateLayerWithUserID source
        self.authenticateLayerWithUserID(userID, completion: { success, error in
          if (!success) {
            print("Failed Authenticating Layer Client with error:\(error)")
          } else {
            print("Authenticated")
            return self.dismissViewControllerAnimated(true, completion: nil)
          }
        })
      }
    }
  }
  
  func authenticateLayerWithUserID(userID: NSString, completion: ((success: Bool , error: NSError!) -> Void)!) {
    // Check to see if the layerClient is already authenticated.
    if self.layerClient.authenticatedUserID != nil {
      // If the layerClient is authenticated with the requested userID, complete the authentication process.
      if self.layerClient.authenticatedUserID == userID {
        print("Layer Authenticated as User \(self.layerClient.authenticatedUserID)")
        if completion != nil {
          completion(success: true, error: nil)
        }
        return
      } else {
        //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
        self.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError?) in
          if error != nil {
            self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError?) in
              if (completion != nil) {
                completion(success: success, error: error)
              }
            })
          } else {
            if completion != nil {
              completion(success: true, error: error)
            }
          }
        }
      }
    } else {
      // If the layerClient isn't already authenticated, then authenticate.
      self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError!) in
        if completion != nil {
          completion(success: success, error: error)
        }
      })
    }
  }
  
  func authenticationTokenWithUserId(userID: NSString, completion:((success: Bool, error: NSError!) -> Void)!) {
    /*
    * 1. Request an authentication Nonce from Layer
    */
    self.layerClient.requestAuthenticationNonceWithCompletion { (nonceString: String?, error: NSError?) in
      guard let nonce = nonceString else {
        if (completion != nil) {
          completion(success: false, error: error)
        }
        return
      }
      
      if (nonce.isEmpty) {
        if (completion != nil) {
          completion(success: false, error: error)
        }
        return
      }
      
      /*
      * 2. Acquire identity Token from Layer Identity Service
      */
      PFCloud.callFunctionInBackground("generateToken", withParameters: ["nonce": nonce, "userID": userID]) { (object:AnyObject?, error: NSError?) -> Void in
        if error == nil {
          let identityToken = object as! String
          self.layerClient.authenticateWithIdentityToken(identityToken) { authenticatedUserID, error in
            guard let userID = authenticatedUserID else {
              if (completion != nil) {
                completion(success: false, error: error)
              }
              return
            }
            
            if (userID.isEmpty) {
              if (completion != nil) {
                completion(success: false, error: error)
              }
              return
            }
            
            if (completion != nil) {
              completion(success: true, error: nil)
            }
            print("Layer Authenticated as User: \(userID)")
          }
        } else {
          print("Parse Cloud function failed to be called to generate token with error: \(error)")
        }
      }
    }
  }
}

extension LoginViewController : UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.didTapSendCodeButton()
    
    return true
  }
  
}
