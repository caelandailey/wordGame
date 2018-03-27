//
//  AppDelegate.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/16/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /*
        let VCview = UIViewController()
        let boxView = BoardControl()
        boxView.frame = CGRect(x:0, y:0, width: 300, height: 300)
        VCview.view = boxView
        window?.rootViewController = VCview
        window?.makeKeyAndVisible()
        */
        window?.backgroundColor = UIColor(red: 245/256, green: 245/256, blue: 245/256, alpha: 1.0)
        
        // Create controllers
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor.white
        
        let progressTableViewController = ProgressTableViewController()
        let finishedTableViewController = FinishedTableViewController()
        
        let progressNavigationController = ProgressNavigationController(rootViewController: progressTableViewController)
        let finishedNavigationController = FinishedNavigationController(rootViewController: finishedTableViewController)
        
        tabBarController.viewControllers = [progressNavigationController, finishedNavigationController]
        tabBarController.selectedViewController = progressNavigationController
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
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

