//
//  RequestViewController.swift
//  AnyPhone
//
//  Created by Benjamin Harvey on 1/16/16.
//  Copyright © 2016 parse. All rights reserved.
//

import UIKit
import Parse
import AddressBookUI
import MapKit
import Atlas

class RequestViewController: UIViewController, CLLocationManagerDelegate {
  
  var manager: OneShotLocationManager?
  var reallocation : [NSString:NSString]?
  var layerClient: LYRClient!
  
  @IBOutlet weak var map: MKMapView!
  
  @IBOutlet weak var addressField: UITextField!
  @IBOutlet weak var requestButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.loginLayer()
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
            self.requestButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
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
        
        self.centerMapOnLocation(loc)
        
        
        
        
        
        
        //now add the text to the textfield
        
        let wordlocation = CLLocation(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude) //changed!!!
        
        CLGeocoder().reverseGeocodeLocation(wordlocation, completionHandler: {(placemarks, error) -> Void in
          if error != nil {
            return
          }
          
          if placemarks!.count > 0 {
            let pm = placemarks![0]
            self.addressField.text = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
          }
          else {
            NSLog("Problem with the data received from geocoder")
          }
        })
        
        
        
        
        

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
    let vc : OrderViewController = storyboard.instantiateViewControllerWithIdentifier("OrderViewController") as! OrderViewController
    vc.layerClient = self.layerClient;
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

  let regionRadius: CLLocationDistance = 1000
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius * 2.0, regionRadius * 2.0)
    map.setRegion(coordinateRegion, animated: true)
    map.scrollEnabled = false;
    map.userInteractionEnabled = false;
    map.zoomEnabled = false;
  }
}