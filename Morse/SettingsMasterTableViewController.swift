//
//  SettingsMasterTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import MessageUI

class SettingsMasterTableViewController: TableViewController, UINavigationControllerDelegate, TableViewSwitchCellDelegate, MFMailComposeViewControllerDelegate {

	var animationDurationCell:TableViewCell!
	var animationDurationSlider:UISlider!
	var animationDurationScalar:NSTimeInterval = appDelegate.animationDurationScalar {
		willSet {
			appDelegate.userDefaults.setDouble(newValue, forKey: userDefaultsKeyAnimationDurationScalar)
			appDelegate.userDefaults.synchronize()
		}
	}

	private let _cellIdentifier = "Settings Default Cell Identifier"
	private var _isIPad:Bool {
		if self.traitCollection.verticalSizeClass == .Regular &&
			self.traitCollection.horizontalSizeClass == .Regular {
				return true
		} else {
			return false
		}
	}

	// Tags for switches
	private let _switchButtonTagShareSignature = 0
	private let _switchButtonTagAutoNightMode = 1
	private let _switchButtonTagDecodeProsign = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.settings
		self.navigationController?.navigationBar.barTintColor = appDelegate.theme.navigationBarBackgroundColor
		self.navigationController?.navigationBar.tintColor = appDelegate.theme.navigationBarTitleTextColor
		self.navigationController?.navigationBar.addMDShadow(withDepth: 2)
		self.navigationController?.delegate = self
		var textAttributes = self.navigationController?.navigationBar.titleTextAttributes
		if textAttributes != nil {
			textAttributes![NSForegroundColorAttributeName] = appDelegate.theme.navigationBarTitleTextColor
		} else {
			textAttributes = [NSForegroundColorAttributeName: appDelegate.theme.navigationBarTitleTextColor]
		}
		self.navigationController?.navigationBar.titleTextAttributes = textAttributes

		NSNotificationCenter.defaultCenter().addObserver(self.tableView, selector: "reloadData", name: languageDidChangeNotificationName, object: nil)
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: settingsVCName)

		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.tableView.reloadData()

		self.animationDurationSlider?.value = Float(round(self.animationDurationScalar * 10)/10.0)
		self.animationDurationCell?.detailTextLabel?.attributedText = getAttributedStringFrom("\(round(self.animationDurationScalar * 10)/10.0)", withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		var result = 5
		#if DEBUG
			result++
		#endif
        return result
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 2 // General
		case 1: return 3 // Resets
		case 2: return 2 // Appearance
		case 3: return 3 // Transmitter Config
//		case 4: return 5 // Upgrades
		case 4: return MFMailComposeViewController.canSendMail() ? 3 : 2 // About
		case 5: return 1 // Dev Options
		default: return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = TableViewCell()
		if indexPath.section == 0 { // General
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Languages Cell", forIndexPath: indexPath) as! TableViewCell
				cell.imageView?.image = UIImage(named: theme.settingsLanguageImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.languages, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				let currentLanguageName = supportedLanguages[appDelegate.currentLocaleLanguageCode]
				var languageNameOriginal = ""
				if currentLanguageName == nil {
					languageNameOriginal = LocalizedStrings.Languages.systemDefault
				} else {
					languageNameOriginal = currentLanguageName!.localized
				}
				// Detailed text displays the current language.
				cell.detailTextLabel?.attributedText = getAttributedStringFrom(languageNameOriginal, withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.imageView?.image = UIImage(named: theme.settingsShareExtraTextImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.extraTextWhenShare, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				(cell as! TableViewSwitchCell).delegate = self
				(cell as! TableViewSwitchCell).tag = self._switchButtonTagShareSignature
				(cell as! TableViewSwitchCell).switchButton.on = appDelegate.addExtraTextWhenShare
			default: break
			}
		} else if indexPath.section == 1 { // Actions
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.imageView?.image = UIImage(named: theme.settingsAddTutorialCardsImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.addTutorialCards
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.imageView?.image = UIImage(named: theme.settingsClearCardsImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.clearCards
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 2:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.imageView?.image = UIImage(named: theme.settingsRestoreAlertsImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.restoreAlerts
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			default: break
			}
			cell.separatorInset = UIEdgeInsetsZero
			cell.preservesSuperviewLayoutMargins = false
			cell.layoutMargins = UIEdgeInsetsZero
		} else if indexPath.section == 2 { // Appearance
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Theme Cell", forIndexPath: indexPath) as! TableViewCell
				cell.imageView?.image = UIImage(named: theme.settingsThemeImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.theme
					, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				cell.detailTextLabel?.attributedText = getAttributedStringFrom(appDelegate.userSelectedTheme.name, withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.imageView?.image = UIImage(named: theme.settingsAutoNightModeImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.autoNightMode, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				(cell as! TableViewSwitchCell).delegate = self
				(cell as! TableViewSwitchCell).tag = self._switchButtonTagAutoNightMode
				(cell as! TableViewSwitchCell).switchButton.on = appDelegate.automaticNightMode
			default: break
			}
		} else if indexPath.section == 3 { // Transmitter Config
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Output Cell", forIndexPath: indexPath) as! TableViewCell
				cell.imageView?.image = UIImage(named: theme.settingsSignalOutputImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.output
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Audio Decoder Cell", forIndexPath: indexPath) as! TableViewCell
				cell.imageView?.image = UIImage(named: theme.settingsAudioDecoderImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.audioDecoder
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
			case 2:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.imageView?.image = UIImage(named: theme.settingsDecodeProsignImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.decodeProsign, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				(cell as! TableViewSwitchCell).delegate = self
				(cell as! TableViewSwitchCell).tag = self._switchButtonTagDecodeProsign
				(cell as! TableViewSwitchCell).switchButton.on = appDelegate.prosignTranslationType == .Always
			default: break
			}
//		} else if indexPath.section == 4 { // Upgrades
//			cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
//			switch indexPath.row {
//			case 0:
//				cell.imageView?.image = UIImage(named: theme.settingsPurchaseUnlimitedCardSlotsImageName)?.imageWithRenderingMode(.AlwaysTemplate)
//				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseUnlimitedCardSlots
//					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
//			case 1:
//				cell.imageView?.image = UIImage(named: theme.settingsPurchaseThemesImageName)?.imageWithRenderingMode(.AlwaysTemplate)
//				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseUnlockAllThemes
//					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
//			case 2:
//				cell.imageView?.image = UIImage(named: theme.settingsPurchaseAudioDecoderImageName)?.imageWithRenderingMode(.AlwaysTemplate)
//				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseEnableAudioDecoder
//					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
//			case 3:
//				cell.imageView?.image = UIImage(named: theme.settingsPurchaseAudioDecoderImageName)?.imageWithRenderingMode(.AlwaysTemplate)
//				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseUnlockAllFeatures
//					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
//			case 4:
//				cell.imageView?.image = UIImage(named: theme.settingsRestorePurchasesImageName)?.imageWithRenderingMode(.AlwaysTemplate)
//				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseRestorePurchases
//					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
//			default: break
//			}
//			cell.separatorInset = UIEdgeInsetsZero
//			cell.preservesSuperviewLayoutMargins = false
//			cell.layoutMargins = UIEdgeInsetsZero
		} else if indexPath.section == 4 { // About
			cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
			switch indexPath.row {
			case 0:
				cell.imageView?.image = UIImage(named: theme.settingsTellFriendsImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.tellFriends
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 1:
				cell.imageView?.image = UIImage(named: theme.settingsRateOnAppStoreImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.rateOnAppStore
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 2:
				cell.imageView?.image = UIImage(named: theme.settingsContactDeveloperImageName)?.imageWithRenderingMode(.AlwaysTemplate)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.contactDeveloper
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			default: break
			}
			cell.separatorInset = UIEdgeInsetsZero
			cell.preservesSuperviewLayoutMargins = false
			cell.layoutMargins = UIEdgeInsetsZero
		} else if indexPath.section == 5 { // Dev options
			switch indexPath.row {
			case 0:
				self.animationDurationCell = tableView.dequeueReusableCellWithIdentifier("Settings Slider Cell", forIndexPath: indexPath) as! TableViewCell
				cell = self.animationDurationCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom("Animation Scalar", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				cell.detailTextLabel?.attributedText = getAttributedStringFrom("\(round(self.animationDurationScalar * 10)/10.0)", withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
				cell.detailedTextLabelCouldChange = true
				let tapGR = UITapGestureRecognizer(target: self, action: "resetAnimationDurationScalar")
				cell.textLabel?.addGestureRecognizer(tapGR)
				if self.animationDurationSlider == nil {
					self.animationDurationSlider = UISlider(frame: CGRect(x: cell.contentView.bounds.width - sliderWidth - tableViewCellHorizontalPadding, y: 0, width: sliderWidth, height: cell.bounds.height))
					self.animationDurationSlider.minimumValue = Float(0.1)
					self.animationDurationSlider.maximumValue = Float(20)
					self.animationDurationSlider.value = Float(self.animationDurationScalar)
					self.animationDurationSlider.minimumTrackTintColor = theme.sliderMinTrackTintColor
					self.animationDurationSlider.maximumTrackTintColor = theme.sliderMaxTrackTintColor
//					self.animationDurationSlider.thumbTintColor = theme.sliderThumbTintColor
					self.animationDurationSlider.tag = 999
					self.animationDurationSlider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
					cell.contentView.addSubview(self.animationDurationSlider)
					self.animationDurationSlider.snp_remakeConstraints(closure: { (make) -> Void in
						make.trailing.equalTo(cell.contentView).offset(-tableViewCellHorizontalPadding)
						make.top.equalTo(cell.contentView)
						make.bottom.equalTo(cell.contentView)
						make.width.equalTo(sliderWidth)
					})
				}
			default: break
			}
		}

		cell.imageView?.tintColor = theme.cellImageTintColor
		cell.updateColor()

        return cell
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return LocalizedStrings.Settings.general
		case 1: return LocalizedStrings.Settings.actions
		case 2: return LocalizedStrings.Settings.ui
		case 3: return LocalizedStrings.Settings.transmitterConfiguration
		case 4: return	LocalizedStrings.Settings.upgrades
		case 5: return	LocalizedStrings.Settings.about
		case 6: return LocalizedStrings.Settings.developerOptions
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 0: return LocalizedStrings.Settings.extraTextDescription
		case 2: return LocalizedStrings.Settings.nightModeDescription
		case 3: return LocalizedStrings.Settings.decodeProsignDescription
		case 4: return appDelegate.adsRemoved ? nil : LocalizedStrings.Settings.upgradesDescription
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return tableViewCellHeight
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 1 { // Actions
			switch indexPath.row {
			case 0: // Restore Tutorial Cards
				if appDelegate.showAddedTutorialCardsAlert {
					let alertController = MDAlertController(title: LocalizedStrings.Alert.titleAddTutorialCard, message: LocalizedStrings.Alert.messageAddTutorialCard)
					let action1 = MDAlertAction(title: LocalizedStrings.Alert.buttonGotIt)
					let action2 = MDAlertAction(title: LocalizedStrings.Alert.buttonDonnotShowAgain) {
						action in
						appDelegate.showAddedTutorialCardsAlert = false
					}
					alertController.addAction(action1)
					alertController.addAction(action2)
					alertController.show()
				}

				if let tabbarVC = UIApplication.sharedApplication().windows[0].rootViewController as? TabBarController {
					if let homeVC = tabbarVC.viewControllers![0] as? HomeViewController {
						homeVC.addTutorialCards(false)
					}
				}
			case 1: // Clear cards
				let alertController = MDAlertController(title: LocalizedStrings.Alert.titleClearCards, message: LocalizedStrings.Alert.messageClearCards)
				let action1 = MDAlertAction(title: LocalizedStrings.Alert.buttonYesImSure) {
					action in
					if let tabbarVC = UIApplication.sharedApplication().windows[0].rootViewController as? TabBarController {
						if let homeVC = tabbarVC.viewControllers![0] as? HomeViewController {
							homeVC.deleteAllCards()
						}
					}
				}
				let action2 = MDAlertAction(title: LocalizedStrings.Alert.buttonCancel)
				alertController.addAction(action1)
				alertController.addAction(action2)
				alertController.show()
			case 2: // Rest alerts
				let alertController = MDAlertController(title: LocalizedStrings.Alert.titleResetAlert, message: LocalizedStrings.Alert.messageResetAlert)
				let action1 = MDAlertAction(title: LocalizedStrings.Alert.buttonYes) {
					action in
					appDelegate.resetAlerts()
				}
				let action2 = MDAlertAction(title: LocalizedStrings.Alert.buttonNo)
				alertController.addAction(action1)
				alertController.addAction(action2)
				alertController.show()
			default: break
			}
		} else if indexPath.section == 4 { // About
			switch indexPath.row {
			case 0: // Tell Friends
				let shareStr = LocalizedStrings.General.sharePromote + " " + appStoreLink
				let activityVC = UIActivityViewController(activityItems: [shareStr], applicationActivities: nil)
				activityVC.popoverPresentationController?.sourceView = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
				self.presentViewController(activityVC, animated: true, completion: nil)
			case 1: // Rate on App Store
				// TODO: SKStoreProductViewController?
				UIApplication.sharedApplication().openURL(NSURL(string: appStoreReviewLink)!)
			case 2: // Contact Developer
				let mailController = MFMailComposeViewController()
				mailController.mailComposeDelegate = self
				mailController.setToRecipients([feedbackEmailToRecipient])
				mailController.setSubject(LocalizedStrings.FeedbackEmail.subject)
				mailController.setMessageBody(feedbackEmailMessageBody, isHTML: false)
				self.presentViewController(mailController, animated: true, completion: nil)
			default: break
			}
		}
	}

	override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		super.tableView(tableView, willDisplayHeaderView: view, forSection: section)
		if section == 4 {
			if let footerView = view as? UITableViewHeaderFooterView {
				footerView.textLabel?.textColor = theme.tableViewFooterUpgradesTextColor
			}
		}
	}

	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		switch result {
		case MFMailComposeResultCancelled:
			print("Mail cancelled")
		case MFMailComposeResultSaved:
			print("Mail saved")
		case MFMailComposeResultSent:
			print("Mail sent")
		case MFMailComposeResultFailed:
			if let err = error {
				print("Mail sent failure: %@", [err.localizedDescription])
			}
		default:
			break
		}
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	// *****************************
	// MARK: Callbakcs
	// *****************************
	func sliderValueChanged(slider:UISlider) {
		if slider == self.animationDurationSlider {
			self.animationDurationScalar = NSTimeInterval(slider.value)
			self.animationDurationSlider.value = Float(round(self.animationDurationScalar * 10)/10.0)
			self.animationDurationCell.detailTextLabel?.attributedText = getAttributedStringFrom("\(round(self.animationDurationScalar * 10)/10.0)", withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
		}
	}

	func switchToggled(switchButton:UISwitch) {
		let tracker = GAI.sharedInstance().defaultTracker
		switch switchButton.tag {
		case self._switchButtonTagShareSignature:
			if !switchButton.on && !appDelegate.isAbleToTurnOffPromotionalTextWhenShare {
				switchButton.on = true
				let alertController = MDAlertController(title: LocalizedStrings.Alert.titlePleasePurchaseSomething, message: LocalizedStrings.Alert.messagePleasePurchaseSomething)
				let action = MDAlertAction(title: LocalizedStrings.Alert.buttonGotIt)
				alertController.addAction(action)
				alertController.show()
			}
			appDelegate.userDefaults.setBool(switchButton.on, forKey: userDefaultsKeyExtraTextWhenShare)
			appDelegate.userDefaults.synchronize()
			if switchButton.on {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Share Signature Turned On",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Share Signature Turned Off",
					value: nil).build() as [NSObject : AnyObject])
			}
		case self._switchButtonTagAutoNightMode:
			appDelegate.userDefaults.setBool(switchButton.on, forKey: userDefaultsKeyAutoNightMode)
			appDelegate.userDefaults.synchronize()
			if appDelegate.theme != appDelegate.userSelectedTheme {
				appDelegate.theme = appDelegate.userSelectedTheme
			}
			if switchButton.on {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Auto Night Mode Turned On",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Auto Night Mode Turned Off",
					value: nil).build() as [NSObject : AnyObject])
			}
		case self._switchButtonTagDecodeProsign:
			appDelegate.prosignTranslationType = switchButton.on ? .Always : .None
			if switchButton.on {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Translate Prosign Turned On",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Translate Prosign Turned Off",
					value: nil).build() as [NSObject : AnyObject])
			}
		default: break
		}
	}
	
	func resetAnimationDurationScalar() {
		self.animationDurationSlider.value = 1
		self.animationDurationScalar = 1
		self.animationDurationCell.detailTextLabel?.attributedText = getAttributedStringFrom("1.0", withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
	}

	// *****************************
	// MARK: Update Color
	// *****************************
}
