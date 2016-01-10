//
//  SettingsSplitViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

	var statusBarView:UIView!

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return theme.style == .Dark ? .LightContent : .Default
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.delegate = self
		self.preferredDisplayMode = .AllVisible

//		self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: statusBarHeight))
//		self.statusBarView.backgroundColor = appDelegate.theme.statusBarBackgroundColor
//		self.view.addSubview(statusBarView)
//		self.statusBarView.snp_makeConstraints { (make) -> Void in
//			make.top.equalTo(self.view)
//			make.leading.equalTo(self.view)
//			make.trailing.equalTo(self.view)
//			make.height.equalTo(statusBarHeight)
//		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
//		if secondaryViewController is UINavigationController &&
//			(secondaryViewController as! UINavigationController).topViewController is SettingsLanguagesTableViewController &&
//			((secondaryViewController as! UINavigationController).topViewController as! SettingsLanguagesTableViewController).tableView == nil {
//			return true
//		} else {
//			return false
//		}
		return true
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
