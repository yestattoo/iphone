//
//  AppDelegate.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Parse
import LayerKit
import Atlas

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var layerClient: LYRClient!
  
  let LayerAppIDString: NSURL! = NSURL(string: "layer:///apps/staging/9d78ffcc-c2dc-11e5-9063-80b60e0058d9")
  let ParseAppIDString: String = "eIvJ40jzlYcsYzxcRamj3tMgb5IufW7FZw4JpwH9"
  let ParseClientKeyString: String = "1DYlnZYhoev4mglYW2TizFMwzEZwrhxC8IEjxXxC"

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    setupParse()
    setupLayer()
    
    PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    
    application.registerForRemoteNotifications()
    
    return true
  }
  
  func setupParse() {
    Parse.enableLocalDatastore()
    Parse.setApplicationId(ParseAppIDString, clientKey: ParseClientKeyString)
    
    // Set default ACLs
    let defaultACL: PFACL = PFACL()
    defaultACL.setPublicReadAccess(true)
    PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
  }
  
  func setupLayer() {
    layerClient = LYRClient(appID: LayerAppIDString)
    layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as? Set<String>
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    
    var currentInstallation = PFInstallation.currentInstallation()
    currentInstallation.setDeviceTokenFromData(deviceToken)
    currentInstallation.saveInBackground()
    
    print("got device id! \(deviceToken)")
    
  }
  
}
