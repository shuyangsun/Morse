//
//  OutputSettingsViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/10/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class OutputSettingsViewController: UIViewController {

	var scrollView:UIScrollView!

	private func setup() {
		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.output
		self.navigationController?.navigationBar.barTintColor = appDelegate.theme.navigationBarBackgroundColor
		self.navigationController?.navigationBar.tintColor = appDelegate.theme.navigationBarTitleTextColor

		if self.scrollView == nil {
			self.scrollView = UIScrollView(frame: self.view.bounds)
			self.scrollView.backgroundColor = appDelegate.theme.scrollViewBackgroundColor
			self.scrollView.userInteractionEnabled = true
			self.scrollView.bounces = true
			self.scrollView.showsHorizontalScrollIndicator = false
			self.scrollView.showsVerticalScrollIndicator = true
			self.scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
			self.view.addSubview(self.scrollView)

			self.scrollView.snp_remakeConstraints { (make) -> Void in
				make.edges.equalTo(self.view)
			}
		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColorWithAnimation", name: themeDidChangeNotificationName, object: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func updateColor(animated animated:Bool = true) {
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animateWithDuration(duration,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.scrollView.backgroundColor = theme.scrollViewBackgroundColor
			}, completion: nil)
	}

	// This method is for using selector
	func updateColorWithAnimation() {
		self.updateColor(animated: true)
	}

	// This method is for using selector
	func updateColorWithoutAnimation() {
		self.updateColor()
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
