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
import Google

class RequestViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, MKMapViewDelegate, UpdateAddyViewControllerDelegate {
  
  var manager: OneShotLocationManager?
  var reallocation : [NSString:NSString]?
  var layerClient: LYRClient!
  var imageView : UIImageView!
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var map: MKMapView!
  @IBOutlet weak var profileClick: UIButton!
  @IBOutlet weak var requestButton: UIButton!

  @IBOutlet weak var addressTextView: UITextView!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      addressTextView.delegate = self
      map.delegate = self
      map.showsUserLocation = true
      
      addressTextView.textContainer.maximumNumberOfLines = 2
      requestButton.addTarget(self, action: "buttonAction:", forControlEvents: .TouchUpInside)

      
        self.loginLayer()
      
      
      manager = OneShotLocationManager()
      manager!.fetchWithCompletion { (location, error) -> () in
        self.renderLocation(location!)
        self.manager = nil
      }
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
    print("buton action")
    requestButton.enabled = false
    self.sendRequest()
    
    
    let tracker = GAI.sharedInstance().defaultTracker
    let eventTracker: NSObject = GAIDictionaryBuilder.createEventWithCategory(
      "Send Request",
      action: "Request Button",
      label: "SomeLabel",
      value: nil).build()
    tracker.send(eventTracker as! [NSObject : AnyObject])

  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    var tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Request Screen")
    
    var builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
    
    
    
    let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
    if firstLaunch  {
      print("Not first launch.")
    }
    else {
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc : MainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
      
      self.presentViewController(vc, animated: true, completion: nil)
      print("First launch, setting NSUserDefault.")
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
    
//    let screenSize: CGRect = UIScreen.mainScreen().bounds
//    let screenWidth = screenSize.width
//    let screenHeight = screenSize.height
//    
//    let imageName = "requestpage.png"
//    let image = UIImage(named: imageName)
//    imageView = UIImageView(image: image!)
//    
//    
//    
//    
//    
//    let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
//    imageView.userInteractionEnabled = true
//    imageView.addGestureRecognizer(tapGestureRecognizer)
//    
//    let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:Selector("profileImageTapped:"))
//    profileImageView.userInteractionEnabled = true
//    tapGestureRecognizer2.numberOfTouchesRequired = 1
//    profileImageView.addGestureRecognizer(tapGestureRecognizer2)
//    
//    
//    
//    imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
//    view.addSubview(imageView)
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc : OrderViewController = storyboard.instantiateViewControllerWithIdentifier("OrderViewController") as! OrderViewController
    
    self.presentViewController(vc, animated: true, completion: nil)
  }
  
  
  
  func profileImageTapped(img: AnyObject){
    
  }
  
  func imageTapped(img: AnyObject)
  {
    PFCloud.callFunctionInBackground("cancel", withParameters: nil, block: { (object: AnyObject?, error) -> Void in
      if error == nil {
        self.imageView.removeFromSuperview()
        
      } else {
        // Do error handling
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
          NSLog("canceled with error")
        })
      }
    })
  }
  
  func sendRequest(){
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    self.requestButton.enabled = true
    let vc : OutOfBoundsViewController = storyboard.instantiateViewControllerWithIdentifier("OutOfBoundsViewController") as! OutOfBoundsViewController
    vc.reallocation = self.reallocation
    self.presentViewController(vc, animated: true, completion: nil)
    
    return
      
    print("send request")
    PFCloud.callFunctionInBackground("request", withParameters: ["location" : self.reallocation!], block: { (object: AnyObject?, error) -> Void in
      if error == nil {
        
        self.goToReq()
        
      } else {
        if(error?.code==420){
          print("out of area")
        }
        NSLog("sent")
        // Do error handling
      }
      
      self.requestButton.enabled = true
    })
  }
  
  let regionRadius: CLLocationDistance = 1000
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius * 2.0, regionRadius * 2.0)
    map.setRegion(coordinateRegion, animated: true)
    map.scrollEnabled = true;
    map.userInteractionEnabled = true;
    map.zoomEnabled = true;
  }
  
  @IBAction func profileButtonClick(sender: UIButton) {
    
    print("tapped")
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc : MainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
    self.presentViewController(vc, animated: true, completion: nil)
    
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    
    
  }

  func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
    // Calling...

    var latitudeText:String = "\(mapView.centerCoordinate.latitude)"
    
    var longitudeText:String = "\(mapView.centerCoordinate.longitude)"
    
    self.reallocation = ["lat":latitudeText,"long":longitudeText ]
  
    let wordlocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude) //changed!!!
    
    CLGeocoder().reverseGeocodeLocation(wordlocation, completionHandler: {(placemarks, error) -> Void in
      if error != nil {
        return
      }
      
      if placemarks!.count > 0 {
        let pm = placemarks![0]
        self.addressTextView.text = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
        self.reallocation = ["lat":latitudeText,"long":longitudeText, "address":ABCreateStringWithAddressDictionary(pm.addressDictionary!, false) ]
      }
      else {
        NSLog("Problem with the data received from geocoder")
      }
    })
  
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  func renderLocation(location: CLLocation) {
      var latitudeText:String = "\(location.coordinate.latitude)"
      
      var longitudeText:String = "\(location.coordinate.longitude)"
      
      
      self.reallocation = ["lat":latitudeText,"long":longitudeText]
      
      
      print(self.reallocation)
      
      self.centerMapOnLocation(location)
      
      
      let wordlocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) //changed!!!
      
      CLGeocoder().reverseGeocodeLocation(wordlocation, completionHandler: {(placemarks, error) -> Void in
        if error != nil {
          return
        }
        
        if placemarks!.count > 0 {
          let pm = placemarks![0]
          self.addressTextView.text = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
          self.reallocation = ["lat":latitudeText,"long":longitudeText, "address":ABCreateStringWithAddressDictionary(pm.addressDictionary!, false) ]
        }
        else {
          NSLog("Problem with the data received from geocoder")
        }
      })
  }
  
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    textView.resignFirstResponder()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc : UpdateAddyViewController = storyboard.instantiateViewControllerWithIdentifier("UpdateAddyViewController") as! UpdateAddyViewController
    vc.delegate = self
    
    self.presentViewController(vc, animated: true, completion: nil)
    
    print("h2")
    return true
  }
  func textFieldDidBeginEditing(textField: UITextField) {
    
    print("h1")

  }
  
  func doSomethingWithData(data: CLLocation) {
    print("here!!!")
    // Uses the data passed back
    self.renderLocation(data)
  }
  
  override func shouldAutorotate() -> Bool {
    return false
  }
  
}


extension UIButton {
  override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    var relativeFrame = self.bounds
    var hitTestEdgeInsets = UIEdgeInsetsMake(-44, -44, -44, -44)
    var hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
    return CGRectContainsPoint(hitFrame, point)
  }
}
