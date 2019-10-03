//
//  AppDelegate.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 02..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import UIKit
import SciChart
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
        
        // Note! This is just an example.
        // The real License Contract is found by following steps above
        let licencing:String = "<LicenseContract>" +
            "<Customer>brigittaforrai@decent.org</Customer>" +
            "<OrderId>Trial</OrderId>" +
            "<LicenseCount>1</LicenseCount>" +
            "<IsTrialLicense>true</IsTrialLicense>" +
            "<SupportExpires>11/02/2019 00:00:00</SupportExpires>" +
            "<ProductCode>SC-IOS-2D-ENTERPRISE-SRC</ProductCode>" +
        "<KeyCode>" + "11beb379fe2437ebc851c75af31e6d86a553702eeb0974fb1157e7414ffde8d7c6ab5ab0b9899e08a6062c07edf9be93faa49bbc2ffcf15941204ca710286d0c46889e13df64a93610fb73d7cc6049120819cd7b84077e20ab3df0834fe5da687b4fd02ec307dc6e69729aadc73f62eea9105c9c0ff0d31b73f0c95807e20aef04b684d097024cde9bba7db729e0630ea44a6f92f13fde3d6c97c5734730ff96cded57f36d70c76d93ad5a81817c7491c2b3abdb8d95cf36" + "</KeyCode>" +
        "</LicenseContract>"
        
        SCIChartSurface.setRuntimeLicenseKey(licencing)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

