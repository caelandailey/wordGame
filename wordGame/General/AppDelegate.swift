//
//  AppDelegate.swift
//  wordGame
//
//  Created by Caelan Dailey on 3/16/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//
// Created for the course CS4530 Mobile App Development Course
// @ University of utah
// Project 3 - Word Game
//
// App delegate for word game. Views are constructed here.
// Root view is a tab barcontroller -> Navigation controller

// WHAT THE APP DOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tab bar with a Progress Navigation Controller and a Finished Game Controller
// Progress navigation controller has a table view representing a list of games that are in progress
// These are represented with the ProgressDataset which is the data for each game
// This data is used to create a game or games are created without data
// Selected a cell creates a game with existing data
// Creating a new game randomly generates data
// Data is saved on every action
//
// Finished game controller has a finished table view
// This represents a list of finished games
// The data for this is in FinishedDataset
// Same as progress, but game is complete
//
// Game is represented as a MVC
// Game is a UIControl of a 9 wide by 12 deep grid
// Player selects words on grid and they get deleted

// FEATURES
// Randomly generating data
// Saving data
// Play existing games
// Presenting data
// Multiple games
// Fininshed games


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}


}

