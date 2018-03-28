//
//
//  Created by Caelan Dailey on 2/21/18.
//  Copyright © 2018 Caelan Dailey. All rights reserved.
//

import UIKit

// Navigation for the alarms
// Can go to detail view of table cell
class ProgressNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        
        super.init(rootViewController: rootViewController)
        
        // Tab bar item
        self.tabBarItem = alarmListButton
        self.navigationBar.barTintColor = .white
        
    }
    
    // Required?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Tab bar item
    let alarmListButton : UITabBarItem = {
        let alarmListButton = UITabBarItem()
        alarmListButton.title = "Progress"
        //alarmListButton.image = UIImage(named: "alarm_icon")
        
        return alarmListButton
    }()
    
}
