//
//  TabBarController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.tabBar.barTintColor = appDelegate.theme.tabBarBackgroundColor
		let controllers = self.viewControllers
		// Customize tab bar items
		if controllers != nil {
			for controller in controllers! {
				if let homeVC = controller as? HomeViewController {
					homeVC.tabBarItem = UITabBarItem(tabBarSystemItem: .Featured, tag: 0)
				} else if let morseDictionaryVC = controller as? MorseDictionaryViewController {
					morseDictionaryVC.tabBarItem = UITabBarItem(tabBarSystemItem: .Bookmarks, tag: 1)
				} else if let settingsVC = controller as? SettingsSplitViewController {
					settingsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .More, tag: 1)
				}
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Only support landscape when it's on an iPad
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if self.traitCollection.horizontalSizeClass == .Regular && self.traitCollection.verticalSizeClass == .Regular {
			return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Landscape]
		} else {
			return UIInterfaceOrientationMask.Portrait
		}
	}

	/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// TODO: customize tabbar item

    }
	*/
}
