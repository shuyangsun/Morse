//
//  SettingsMasterTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsMasterTableViewController: TableViewController, UINavigationControllerDelegate, TableViewSwitchCellDelegate {

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		self.view.backgroundColor = theme.tableViewBackgroundColor
		self.tableView.separatorColor = theme.tableViewSeparatorColor

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.settings
		self.navigationController?.navigationBar.barTintColor = appDelegate.theme.navigationBarBackgroundColor
		self.navigationController?.navigationBar.tintColor = appDelegate.theme.navigationBarTitleTextColor
		self.navigationController?.delegate = self
		var textAttributes = self.navigationController?.navigationBar.titleTextAttributes
		if textAttributes != nil {
			textAttributes![NSForegroundColorAttributeName] = appDelegate.theme.navigationBarTitleTextColor
		} else {
			textAttributes = [NSForegroundColorAttributeName: appDelegate.theme.navigationBarTitleTextColor]
		}
		self.navigationController?.navigationBar.titleTextAttributes = textAttributes

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "languageDidChange", name: languageDidChangeNotificationName, object: nil)
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
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
		case 1: return 2 // Appearance
		case 2: return 2 // Transmitter Config
		case 3: return 3 // Upgrades
		case 4: return 2 // About
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
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.languages, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				let currentLanguageName = supportedLanguages[appDelegate.currentLocaleLanguageCode]
				var languageNameOriginal = ""
				if currentLanguageName == nil {
					languageNameOriginal = LocalizedStrings.Languages.systemDefault
				} else {
					languageNameOriginal = currentLanguageName!.localized
				}
				// Detailed text displays the current language. 
				cell.detailTextLabel?.attributedText = getAttributedStringFrom(languageNameOriginal, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.extraTextWhenShare, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				(cell as! TableViewSwitchCell).delegate = self
				(cell as! TableViewSwitchCell).switchButton.tag = self._switchButtonTagShareSignature
				(cell as! TableViewSwitchCell).switchButton.on = appDelegate.addExtraTextWhenShare
			default: break
			}
		} else if indexPath.section == 1 { // Appearance
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Theme Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.theme
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
				cell.detailTextLabel?.attributedText = getAttributedStringFrom(appDelegate.userSelectedTheme.name, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.autoNightMode, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				(cell as! TableViewSwitchCell).delegate = self
				(cell as! TableViewSwitchCell).switchButton.tag = self._switchButtonTagAutoNightMode
				(cell as! TableViewSwitchCell).switchButton.on = appDelegate.automaticNightMode
			default: break
			}
		} else if indexPath.section == 2 { // Transmitter Config
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Audio Decoder Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.audioDecoder
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Output Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.output
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			default: break
			}
			cell.accessoryType = .DisclosureIndicator
		} else if indexPath.section == 3 { // Upgrades
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseUnlockAllThemes
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseEnableAudioDecoder
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 2:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.purchaseRestorePreviousPurchase
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			default: break
			}
		} else if indexPath.section == 4 { // About
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.rateOnAppStore
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Basic Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.contactDeveloper
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
			default: break
			}
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
					self.animationDurationSlider = UISlider(frame: CGRect(x: cell.contentView.bounds.width - sliderWidth - tableViewCellTrailingPadding, y: 0, width: sliderWidth, height: cell.bounds.height))
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
						make.trailing.equalTo(cell.contentView).offset(-tableViewCellTrailingPadding)
						make.top.equalTo(cell.contentView)
						make.bottom.equalTo(cell.contentView)
						make.width.equalTo(sliderWidth)
					})
				}
			default: break
			}
		}
		
        // Configure the cell...
		cell.selectionStyle = .None

        return cell
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return LocalizedStrings.Settings.general
		case 1: return LocalizedStrings.Settings.ui
		case 2: return LocalizedStrings.Settings.transmitterConfiguration
		case 3: return	LocalizedStrings.Settings.upgrades
		case 4: return	LocalizedStrings.Settings.about
		case 5: return LocalizedStrings.Settings.developerOptions
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 1: return LocalizedStrings.Settings.nightModeDescription
		case 3: return LocalizedStrings.Settings.upgradesDescription
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return tableViewCellHeight
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
		switch switchButton.tag {
		case self._switchButtonTagShareSignature:
			appDelegate.userDefaults.setBool(switchButton.on, forKey: userDefaultsKeyExtraTextWhenShare)
			appDelegate.userDefaults.synchronize()
		case self._switchButtonTagAutoNightMode:
			appDelegate.userDefaults.setBool(switchButton.on, forKey: userDefaultsKeyAutoNightMode)
			appDelegate.userDefaults.synchronize()
			if appDelegate.theme != appDelegate.userSelectedTheme {
				appDelegate.theme = appDelegate.userSelectedTheme
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

	override func updateColor(animated animated:Bool = false) {
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animateWithDuration(duration,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.tableView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.view.backgroundColor = theme.tableViewBackgroundColor
				self.tableView.separatorColor = theme.tableViewSeparatorColor
				self.navigationController?.navigationBar.barTintColor = theme.navigationBarBackgroundColor
				self.navigationController?.navigationBar.tintColor = theme.navigationBarTitleTextColor
				self.tabBarController?.tabBar.barTintColor = theme.tabBarBackgroundColor
				// Update header and foooter color
				for sec in 0..<self.numberOfSectionsInTableView(self.tableView) {
					if let headerView = self.tableView(self.tableView, viewForFooterInSection: sec) {
						print(headerView)
					}
				}
		}, completion: nil)
		self.tableView.reloadData()
		// Update cell colors:
		for sec in 0..<self.numberOfSectionsInTableView(self.tableView) {
			for row in 0..<self.tableView(self.tableView, numberOfRowsInSection: sec) {
				if let cell = self.tableView(self.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: row, inSection: sec)) as? TableViewCell {
					cell.updateColor()
				}
			}
		}
	}

	func languageDidChange() {
		self.tableView.reloadData()
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
