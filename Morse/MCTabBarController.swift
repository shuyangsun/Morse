//
//  MCTabBarController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MCTabBarController: UITabBarController {

	private var theme:Theme {
		if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
			return delegate.theme
		} else {
			return Theme.Default
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.tabBar.barTintColor = self.theme.tabBarBackgroundColor
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.destinationViewController is MCHomeViewController {
			(segue.destinationViewController as! MCHomeViewController).tabBarHeight = self.tabBar.bounds.height
		}
    }
	*/

}
