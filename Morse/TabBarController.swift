//
//  TabBarController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
	var homeVC:HomeViewController! = nil
	var morseDictionaryVC:MorseDictionaryViewController! = nil
	var settingsVC:SettingsSplitViewController! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.tabBar.barTintColor = appDelegate.theme.tabBarBackgroundColor
		let controllers = self.viewControllers
		// Customize tab bar items
		if controllers != nil {
			for controller in controllers! {
				if let homeViewController = controller as? HomeViewController {
					self.homeVC = homeViewController
					self.homeVC.tabBarItem = UITabBarItem(tabBarSystemItem: .Featured, tag: 0)
				} else if let dictionaryViewController = controller as? MorseDictionaryViewController {
					self.morseDictionaryVC = dictionaryViewController
					self.morseDictionaryVC.tabBarItem = UITabBarItem(tabBarSystemItem: .Bookmarks, tag: 1)
				} else if let settingsViewController = controller as? SettingsSplitViewController {
					self.settingsVC = settingsViewController
					self.settingsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .More, tag: 1)
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

	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		coordinator.animateAlongsideTransition(nil) { context in
			if let fromVC = context.viewControllerForKey(UITransitionContextFromViewControllerKey) as? TabBarController {
				if fromVC === self {
					if self.homeVC != nil {
						self.homeVC.rotationDidChange()
					}
					if self.morseDictionaryVC != nil {
						self.morseDictionaryVC.rotationDidChange()
					}
				}
			}
		}
	}

	/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// TODO: customize tabbar item

    }
	*/
}
