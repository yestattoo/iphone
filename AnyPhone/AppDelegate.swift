//
//  AppDelegate.swift
//  AnyPhone
//
//  Created by Fosco Marotto on 5/6/15.
//  Copyright (c) 2015 parse. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    Parse.enableLocalDatastore()
    Parse.setApplicationId("eIvJ40jzlYcsYzxcRamj3tMgb5IufW7FZw4JpwH9",
      clientKey: "1DYlnZYhoev4mglYW2TizFMwzEZwrhxC8IEjxXxC")

    PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

    return true
  }
  
}
