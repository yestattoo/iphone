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

class RequestViewController: UIViewController, CLLocationManagerDelegate {
  
  var manager: OneShotLocationManager?
  var reallocation : [NSString:NSString]?
  
  
  @IBOutlet weak var map: MKMapView!
  
  @IBOutlet weak var addressField: UITextField!
  @IBOutlet weak var requestButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      self.requestButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
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
    let vc = storyboard.instantiateViewControllerWithIdentifier("OrderViewController")
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
