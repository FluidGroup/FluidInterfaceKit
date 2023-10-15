//
//  AppDelegate.swift
//  ExampleFluidApp
//
//  Created by Muukii on 2022/02/20.
//

import UIKit
import FluidStack

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    let newWindow = UIWindow()
        
    newWindow.rootViewController = RootViewController()
    newWindow.makeKeyAndVisible()
    
    window = newWindow
    
    return true
  }


}

