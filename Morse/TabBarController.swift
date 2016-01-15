//
//  TabBarController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate, UIViewControllerTransitioningDelegate {
	var homeVC:HomeViewController! = nil
	var outputVC:OutputViewController? {
		return self.presentedViewController as? OutputViewController
	}
	var alertVC:MDAlertController? {
		return self.presentedViewController as? MDAlertController
	}
	var morseDictionaryVC:MorseDictionaryViewController! = nil
	var settingsVC:SettingsSplitViewController! = nil
	let cardViewOutputTransitionInteractionController = CardViewOutputTransitionInteractionController()
	private let _cardViewOutputAnimator = CardViewOutputAnimator()
	private let _mdAlertAnimator = MDAlertAnimator()

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return theme.style == .Dark ? .LightContent : .Default
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.tabBar.barTintColor = appDelegate.theme.tabBarBackgroundColor
		let controllers = self.viewControllers
		// Customize tab bar items
		UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -60), forBarMetrics: .Default)
		if controllers != nil {
			for controller in controllers! {
				if let homeViewController = controller as? HomeViewController {
					self.homeVC = homeViewController
					self.homeVC.tabBarItem = UITabBarItem(tabBarSystemItem: .Featured, tag: 0)
				} else if let dictionaryViewController = controller as? MorseDictionaryViewController {
					self.morseDictionaryVC = dictionaryViewController
					self.morseDictionaryVC.tabBarItem = UITabBarItem(tabBarSystemItem: .Bookmarks, tag: 1)
					self.morseDictionaryVC.tabBarItem.title = nil
				} else if let settingsViewController = controller as? SettingsSplitViewController {
					self.settingsVC = settingsViewController
					self.settingsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .More, tag: 2)
					self.settingsVC.tabBarItem.title = nil
				}
			}
		}

		self.transitioningDelegate = self
		self.modalPresentationStyle = .Custom

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColorWithAnimation", name: themeDidChangeNotificationName, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Only support landscape when it's on an iPad
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if isPad {
			return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Landscape]
		} else {
			return UIInterfaceOrientationMask.Portrait
		}
	}

	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		if let outputVC = self.outputVC {
			// Doing this because of a layout bug
			outputVC.view.userInteractionEnabled = false
		}
		coordinator.animateAlongsideTransition(nil) { context in
			if let fromVC = context.viewControllerForKey(UITransitionContextFromViewControllerKey) as? TabBarController {
				if fromVC === self {
					if self.homeVC != nil {
						self.homeVC.rotationDidChange()
					}
					if self.morseDictionaryVC != nil {
						self.morseDictionaryVC.rotationDidChange()
					}
					if let outputVC = self.outputVC {
						outputVC.view.userInteractionEnabled = true
					}
					if let alertVC = self.alertVC {
						alertVC.rotationDidChange()
					}
				}
			}
		}
	}

	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if source is HomeViewController && presented is OutputViewController ||
			source is OutputViewController && presented is HomeViewController {
			self._cardViewOutputAnimator.reverse = false
			return self._cardViewOutputAnimator
		} else if presented is MDAlertController ||
			source is MDAlertController {
			self._mdAlertAnimator.reverse = false
			return self._mdAlertAnimator
		}
		return nil
	}

	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if dismissed is OutputViewController {
			self._cardViewOutputAnimator.reverse = true
			return self._cardViewOutputAnimator
		} else if dismissed is MDAlertController {
			self._mdAlertAnimator.reverse = true
			return self._mdAlertAnimator
		}
		return nil
	}

	func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if animator === self._cardViewOutputAnimator {
			return self.cardViewOutputTransitionInteractionController
		}
		return nil
	}

	func updateColor(animated animated:Bool = true) {
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animateWithDuration(duration,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.tabBarController?.tabBar.barTintColor = theme.tabBarBackgroundColor
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
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// TODO: customize tabbar item

    }
	*/
}

