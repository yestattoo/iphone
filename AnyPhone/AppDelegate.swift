
//
//  AppDelegate.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Parse
import Atlas
import Google

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var layerClient: LYRClient!
  
  let ParseAppIDString: String = "eIvJ40jzlYcsYzxcRamj3tMgb5IufW7FZw4JpwH9"
  let ParseClientKeyString: String = "1DYlnZYhoev4mglYW2TizFMwzEZwrhxC8IEjxXxC"

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    setupParse()
    
    PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    
    application.registerForRemoteNotifications()
    
    // Configure tracker from GoogleService-Info.plist.
    var configureError:NSError?
    GGLContext.sharedInstance().configureWithError(&configureError)
    assert(configureError == nil, "Error configuring Google services: \(configureError)")
    
    // Optional: configure GAI options.
    var gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true  // report uncaught exceptions
    gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
    
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
  
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    
    var currentInstallation = PFInstallation.currentInstallation()
    currentInstallation.setDeviceTokenFromData(deviceToken)
    currentInstallation.saveInBackground()
    
    print("got device id! \(deviceToken)")
    
  }
  
}
