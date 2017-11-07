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
	fileprivate let _cardViewOutputAnimator = CardViewOutputAnimator()
	fileprivate let _mdAlertAnimator = MDAlertAnimator()

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return theme.style == .dark ? .lightContent : .default
	}
	/** Indicates if App Store rating prompt has been show during this launch of application. */
	var didShowAppStoreRatingPrompt = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.tabBar.barTintColor = theme.tabBarBackgroundColor
		self.tabBar.tintColor = theme.tabBarSelectedTintColor
		let controllers = self.viewControllers
		// Customize tab bar items
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.clear],
                                                            for: .normal)
		if controllers != nil {
			for controller in controllers! {
				if let homeViewController = controller as? HomeViewController {
					self.homeVC = homeViewController
					let image = UIImage(named:theme.tabBarItemHomeUnselectedImageName)!
					let homeTabBarItem = UITabBarItem(title: nil, image: image.imageWithTintColor(theme.tabBarUnselectedTintColor).withRenderingMode(.alwaysOriginal), selectedImage: image.withRenderingMode(.alwaysTemplate))
					homeTabBarItem.tag = 0
					homeTabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
					self.homeVC.tabBarItem = homeTabBarItem
				} else if let dictionaryViewController = controller as? MorseDictionaryViewController {
					self.morseDictionaryVC = dictionaryViewController
					let image = UIImage(named:theme.tabBarItemDictionaryUnselectedImageName)!
					let dictionaryTabBarItem = UITabBarItem(title: nil, image: image.imageWithTintColor(theme.tabBarUnselectedTintColor).withRenderingMode(.alwaysOriginal), selectedImage: image.withRenderingMode(.alwaysTemplate))
					dictionaryTabBarItem.tag = 1
					dictionaryTabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
					self.morseDictionaryVC.tabBarItem = dictionaryTabBarItem
				} else if let settingsViewController = controller as? SettingsSplitViewController {
					self.settingsVC = settingsViewController
					let image = UIImage(named:theme.tabBarItemSettingsUnselectedImageName)!
					let settingsTabBarItem = UITabBarItem(title: nil, image: image.imageWithTintColor(theme.tabBarUnselectedTintColor).withRenderingMode(.alwaysOriginal), selectedImage: image.withRenderingMode(.alwaysTemplate))
					settingsTabBarItem.tag = 2
					settingsTabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
					self.settingsVC.tabBarItem = settingsTabBarItem
				}
			}
		}

		self.transitioningDelegate = self
		self.modalPresentationStyle = .custom

		NotificationCenter.default.addObserver(self, selector: #selector(updateColorWithAnimation),name: Notification.Name(themeDidChangeNotificationName), object: nil)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self._showAppStoreRatingPrompt()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Only support landscape when it's on an iPad
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		if isPad {
			return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscape]
		} else {
			return UIInterfaceOrientationMask.portrait
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if let outputVC = self.outputVC {
			// Doing this because of a layout bug
			outputVC.view.isUserInteractionEnabled = false
		}
		coordinator.animate(alongsideTransition: nil) { context in
			if let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from) as? TabBarController {
				if fromVC === self {
					if self.homeVC != nil {
						self.homeVC.rotationDidChange()
					}
					if self.morseDictionaryVC != nil {
						self.morseDictionaryVC.rotationDidChange()
					}
					if let outputVC = self.outputVC {
						outputVC.view.isUserInteractionEnabled = true
					}
					if let alertVC = self.alertVC {
						alertVC.rotationDidChange()
					}
				}
			}
		}
	}

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if dismissed is OutputViewController {
			self._cardViewOutputAnimator.reverse = true
			return self._cardViewOutputAnimator
		} else if dismissed is MDAlertController {
			self._mdAlertAnimator.reverse = true
			return self._mdAlertAnimator
		}
		return nil
	}

	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if animator === self._cardViewOutputAnimator {
			return self.cardViewOutputTransitionInteractionController
		}
		return nil
	}

	/**
	 Check conditions and shows App Store rating prompt when the user launches app if appropriate. Frequency is specified in General.swift.
	 */
	fileprivate func _showAppStoreRatingPrompt() {
		print(appDelegate.appLaunchCount)
		// Check if the user wants to show prompt, and if the prompt has already been shown.
		if !self.didShowAppStoreRatingPrompt && appDelegate.showRateOnAppStorePrompt {
			if appDelegate.lastRatedVersionString == nil ||
				appDelegate.lastRatedVersionString != ProcessInfo.processInfo.operatingSystemVersionString {
			let launchCount = appDelegate.appLaunchCount
			// Determine if the app should show prompt during this launch
			if launchCount == appStoreRatingPromptFrequency.firstTime ||
				(launchCount - appStoreRatingPromptFrequency.firstTime) % appStoreRatingPromptFrequency.repeatStride == 0 {
				let ratePrompt = MDAlertController(title: LocalizedStrings.Alert.titleRateOnAppStorePromote, message: LocalizedStrings.Alert.messageRateOnAppStorePromote)
				let actionRateIt = MDAlertAction(title: LocalizedStrings.Alert.buttonRateIt) {
					action in
					appDelegate.setRatedThisVersion()
					UIApplication.shared.openURL(URL(string: appStoreReviewLink)!)
				}
				let actionNextTime = MDAlertAction(title: LocalizedStrings.Alert.buttonNextTime)
				let actionNo = MDAlertAction(title: LocalizedStrings.Alert.buttonNo) {
					action in
					appDelegate.showRateOnAppStorePrompt = false
				}
				ratePrompt.addAction(actionRateIt, actionNextTime, actionNo)
				ratePrompt.show()
			}
			}
		}
		self.didShowAppStoreRatingPrompt = true
	}

	/**
	 Responsible for updating the UI when user changes the theme.
	 - parameter animated: A boolean determines if the theme change should be animated.
	 */
	func updateColor(animated:Bool = true) {
		self.homeVC.tabBarItem.image = UIImage(named:theme.tabBarItemHomeUnselectedImageName)!.imageWithTintColor(theme.tabBarUnselectedTintColor).withRenderingMode(.alwaysOriginal)
		self.morseDictionaryVC.tabBarItem.image = UIImage(named:theme.tabBarItemDictionaryUnselectedImageName)!.imageWithTintColor(theme.tabBarUnselectedTintColor).withRenderingMode(.alwaysOriginal)
		self.settingsVC.tabBarItem.image = UIImage(named:theme.tabBarItemSettingsUnselectedImageName)!.imageWithTintColor(theme.tabBarUnselectedTintColor).withRenderingMode(.alwaysOriginal)
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animate(withDuration: duration,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				self.tabBar.tintColor = theme.tabBarSelectedTintColor
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

