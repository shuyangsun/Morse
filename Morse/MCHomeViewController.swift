//
//  MCHomeViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let INPUT_TEXT_FIELD_HEIGHT:CGFloat = 300

class MCHomeViewController: UIViewController {

	// *****************************
	// MARK: Internal Properties
	// *****************************

	// *****************************
	// MARK: Private Properties
	// *****************************

	private var inputTextField = UITextField()
	private var scrollView = UIScrollView()

	private var viewWidth:CGFloat {
		return self.view.bounds.width
	}

	private var viewHeight:CGFloat {
		return self.view.bounds.height - self.tabBarHeight
	}

	private var tabBarHeight:CGFloat {
		if let tabBarController = self.tabBarController {
			return tabBarController.tabBar.bounds.height
		} else {
			return 0
		}
	}

	// *****************************
	// MARK: Public Functions
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// TODO: Custom tab bar item
		self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 0)

		self.inputTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.viewWidth, height: INPUT_TEXT_FIELD_HEIGHT))
		self.view.addSubview(self.inputTextField)

		self.scrollView = UIScrollView(frame: CGRect(x: 0, y: INPUT_TEXT_FIELD_HEIGHT + 1, width: self.viewWidth, height: self.viewHeight - INPUT_TEXT_FIELD_HEIGHT))
		self.view.addSubview(self.scrollView)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
