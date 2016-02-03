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
import Google

class RequestViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, UINavigationBarDelegate, MKMapViewDelegate, UpdateAddyViewControllerDelegate {
  
  var manager: OneShotLocationManager?
  var reallocation : [NSString:NSString]?
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

      
      
      manager = OneShotLocationManager()
      manager!.fetchWithCompletion { (location, error) -> () in
        self.renderLocation(location!)
        self.manager = nil
      }
      
      
      
      //add navbar at end of viewdidload
      // Create the navigation bar
      let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44)) // Offset by 20 pixels vertically to take the status bar into account
      
      let bgcolor: UIColor = UIColor( red: CGFloat(101/255.0), green: CGFloat(0/255.0), blue: CGFloat(252/255.0), alpha: CGFloat(1.0) )
      
      navigationBar.barTintColor = bgcolor
      navigationBar.backgroundColor = bgcolor
      navigationBar.delegate = self;
      

      let navbarFont = UIFont(name: "YanoneKaffeesatz-Bold.ttf", size: 19) ?? UIFont.systemFontOfSize(17)
      var navigationBarAppearance = UINavigationBar.appearance()
      
      navigationBarAppearance.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.whiteColor()]
      
      navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName:UIColor.whiteColor()]
      
      // Create a navigation item with a title
      let navigationItem = UINavigationItem()
      navigationItem.title = "Budhero"
      
      // Create left and right button for navigation item
//      let leftButton =  UIBarButtonItem(title: "Save", style:   UIBarButtonItemStyle.Plain, target: self, action: "btn_clicked:")
      let rightButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "btn_clicked:")
      
      // Create two buttons for the navigation item
      //navigationItem.leftBarButtonItem = leftButton
      navigationItem.rightBarButtonItem = rightButton
      navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
      
      // Assign the navigation item to the navigation bar
      navigationBar.items = [navigationItem]
      
      // Make the navigation bar a subview of the current view controller
      self.map.addSubview(navigationBar)

  }
  
  func btn_clicked(sender: UIBarButtonItem) {
    
    PFUser.logOutInBackgroundWithBlock { error in
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc : LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
      
      self.presentViewController(vc, animated: true, completion: nil)
      
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
    let params = NSMutableDictionary()
    params.setObject( "test", forKey: "test" )
    params.setObject(self.reallocation!, forKey: "location")
    
    print("send request")
    PFCloud.callFunctionInBackground("request", withParameters: params as [NSObject : AnyObject], block: { (object: AnyObject?, error) -> Void in
      if error == nil {
        
        self.goToReq()
        
      } else {
        
        // alternative: not case sensitive
        if error?.description.lowercaseString.rangeOfString("out of area") != nil {
          print("out of area")
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          self.requestButton.enabled = true
          let vc : OutOfBoundsViewController = storyboard.instantiateViewControllerWithIdentifier("OutOfBoundsViewController") as! OutOfBoundsViewController
          vc.reallocation = self.reallocation
          self.presentViewController(vc, animated: true, completion: nil)
        }
        
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
        
        var name = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
        let nameArr = name.componentsSeparatedByString("\n")
        
        self.addressTextView.text = nameArr[0]
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
          
          var name = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
          let nameArr = name.componentsSeparatedByString("\n")
          
          self.addressTextView.text = nameArr[0]
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
