//
//  SettingsMasterTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsMasterTableViewController: UITableViewController {

	var extraTextWhenShareSwitch:UISwitch!
	var brightenUpScreenSwitch:UISwitch!
	var inputPitchAutomaticSwitch:UISwitch!

	var outputWPMCell:TableViewCell!
	var outputWPMSlider:UISlider!
	var outputWPM:Int = appDelegate.outputWPM {
		willSet {
			appDelegate.userDefaults.setInteger(newValue, forKey: userDefaultsKeyOutputWPM)
			appDelegate.userDefaults.synchronize()
		}
	}

	var inputPitchCell:TableViewCell!
	var inputPitchSlider:UISlider!
	var inputPitch:Float = appDelegate.inputPitchFrequency {
		willSet {
			appDelegate.userDefaults.setFloat(newValue, forKey: userDefaultsKeyInputPitchFrequency)
			appDelegate.userDefaults.synchronize()
		}
	}

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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.settings
		self.navigationController?.navigationBar.barTintColor = appDelegate.theme.navigationBarBackgroundColor
		self.navigationController?.navigationBar.tintColor = appDelegate.theme.navigationBarTitleTextColor
		var textAttributes = self.navigationController?.navigationBar.titleTextAttributes
		if textAttributes != nil {
			textAttributes![NSForegroundColorAttributeName] = appDelegate.theme.navigationBarTitleTextColor
		} else {
			textAttributes = [NSForegroundColorAttributeName: appDelegate.theme.navigationBarTitleTextColor]
		}
		self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		self.extraTextWhenShareSwitch.on = appDelegate.addExtraTextWhenShare
		self.brightenUpScreenSwitch.on = appDelegate.brightenScreenWhenOutput
		self.inputPitchAutomaticSwitch.on = appDelegate.inputPitchAutomatic

		if self.outputWPMSlider != nil {
			self.outputWPMSlider.value = Float(self.outputWPM)
			self.outputWPMCell.textLabel?.attributedText = getAttributedStringFrom("\(self.outputWPM)", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
		}

		if self.inputPitchSlider != nil {
			self.inputPitchSlider.value = Float(round(self.inputPitch * 10)/10.0)
			self.inputPitchCell.textLabel?.attributedText = getAttributedStringFrom("\(round(self.inputPitch * 10)/10.0) Hz", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
		}

		if self.animationDurationSlider != nil {
			self.animationDurationSlider.value = Float(round(self.animationDurationScalar * 10)/10.0)
			self.animationDurationCell.detailTextLabel?.attributedText = getAttributedStringFrom("\(round(self.animationDurationScalar * 10)/10.0)", withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
		}
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
		case 1: return 2 // UI
		case 2: return 1 // Output WPM
		case 3: return 2 // Input Pitch
		case 4: return 0 // About
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
					languageNameOriginal = currentLanguageName!.original
				}
				// Detailed text displays the current language. 
				cell.detailTextLabel?.attributedText = getAttributedStringFrom(languageNameOriginal, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
				if !self._isIPad {
					cell.accessoryType = .DisclosureIndicator
				}
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.extraTextWhenShare, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				if self.extraTextWhenShareSwitch == nil {
					self.extraTextWhenShareSwitch = UISwitch()
					self.extraTextWhenShareSwitch.onTintColor = theme.switchOnTintColor
					self.extraTextWhenShareSwitch.addTarget(self, action: "switchToggled:", forControlEvents: .ValueChanged)
					cell.contentView.addSubview(self.extraTextWhenShareSwitch)
					self.extraTextWhenShareSwitch.snp_makeConstraints(closure: { (make) -> Void in
						make.centerY.equalTo(cell.contentView)
						make.height.equalTo(switchButtonHeight)
						make.width.equalTo(switchButtonWidth)
						make.trailing.equalTo(cell.contentView).offset(-tableViewCellTrailingPadding)
					})
				}
			default: break
			}
		} else if indexPath.section == 1 { // UI
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Theme Cell", forIndexPath: indexPath) as! TableViewCell
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.theme
					, withFontSize: 16, color: appDelegate.theme.cellTitleTextColor, bold: false)
				if !self._isIPad {
					cell.accessoryType = .DisclosureIndicator
				}
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.brightenUpDisplayWhenOutput, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				if self.brightenUpScreenSwitch == nil {
					self.brightenUpScreenSwitch = UISwitch()
					self.brightenUpScreenSwitch.onTintColor = theme.switchOnTintColor
					self.brightenUpScreenSwitch.addTarget(self, action: "switchToggled:", forControlEvents: .ValueChanged)
					cell.contentView.addSubview(self.brightenUpScreenSwitch)
					self.brightenUpScreenSwitch.snp_makeConstraints(closure: { (make) -> Void in
						make.centerY.equalTo(cell.contentView)
						make.height.equalTo(switchButtonHeight)
						make.width.equalTo(switchButtonWidth)
						make.trailing.equalTo(cell.contentView).offset(-tableViewCellTrailingPadding)
					})
				}
			default: break
			}
		} else if indexPath.section == 2 { // Output WPM
			switch indexPath.row {
			case 0:
				self.outputWPMCell = tableView.dequeueReusableCellWithIdentifier("Settings Slider Cell", forIndexPath: indexPath) as! TableViewCell
				cell = self.outputWPMCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText = getAttributedStringFrom("\(self.outputWPM)", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				cell.textLabelCouldChange = true
				if self.outputWPMSlider == nil {
					self.outputWPMSlider = UISlider(frame: CGRect(x: cell.contentView.bounds.width - sliderWidth - tableViewCellTrailingPadding, y: 0, width: sliderWidth, height: cell.bounds.height))
					self.outputWPMSlider.minimumValue = Float(outputMinWPM)
					self.outputWPMSlider.maximumValue = Float(outputMaxWPM)
					self.outputWPMSlider.value = Float(self.outputWPM)
					self.outputWPMSlider.minimumTrackTintColor = theme.sliderMinTrackTintColor
					self.outputWPMSlider.maximumTrackTintColor = theme.sliderMaxTrackTintColor
//					self.outputWPMSlider.thumbTintColor = theme.sliderThumbTintColor
					self.outputWPMSlider.tag = 0
					self.outputWPMSlider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
					cell.contentView.addSubview(self.outputWPMSlider)
					self.outputWPMSlider.snp_remakeConstraints(closure: { (make) -> Void in
						make.trailing.equalTo(cell.contentView).offset(-tableViewCellTrailingPadding)
						make.top.equalTo(cell.contentView)
						make.bottom.equalTo(cell.contentView)
						make.width.equalTo(sliderWidth)
					})
				}
				cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			default: break
			}
		} else if indexPath.section == 3 { // Input Pitch
			switch indexPath.row {
			case 0:
				self.inputPitchCell = tableView.dequeueReusableCellWithIdentifier("Settings Slider Cell", forIndexPath: indexPath) as! TableViewCell
				cell = self.inputPitchCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText = getAttributedStringFrom("\(round(self.inputPitch * 10)/10.0) Hz", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				cell.textLabelCouldChange = true
				if self.inputPitchSlider == nil {
					self.inputPitchSlider = UISlider(frame: CGRect(x: cell.contentView.bounds.width - sliderWidth - tableViewCellTrailingPadding, y: 0, width: sliderWidth, height: cell.bounds.height))
					self.inputPitchSlider.minimumValue = Float(inputPitchMin)
					self.inputPitchSlider.maximumValue = Float(inputPitchMax)
					self.inputPitchSlider.value = Float(self.inputPitch)
					self.inputPitchSlider.minimumTrackTintColor = theme.sliderMinTrackTintColor
					self.inputPitchSlider.maximumTrackTintColor = theme.sliderMaxTrackTintColor
				//	self.outputWPMSlider.thumbTintColor = theme.sliderThumbTintColor
					self.inputPitchSlider.tag = 1
					self.inputPitchSlider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
					cell.contentView.addSubview(self.inputPitchSlider)
					self.inputPitchSlider.snp_remakeConstraints(closure: { (make) -> Void in
						make.trailing.equalTo(cell.contentView).offset(-tableViewCellTrailingPadding)
						make.top.equalTo(cell.contentView)
						make.bottom.equalTo(cell.contentView)
						make.width.equalTo(sliderWidth)
					})
				}
				cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.automatic, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				if self.inputPitchAutomaticSwitch == nil {
					self.inputPitchAutomaticSwitch = UISwitch()
					self.inputPitchAutomaticSwitch.onTintColor = theme.switchOnTintColor
					self.inputPitchAutomaticSwitch.addTarget(self, action: "switchToggled:", forControlEvents: .ValueChanged)
					cell.contentView.addSubview(self.inputPitchAutomaticSwitch)
					self.inputPitchAutomaticSwitch.snp_makeConstraints(closure: { (make) -> Void in
						make.centerY.equalTo(cell.contentView)
						make.height.equalTo(switchButtonHeight)
						make.width.equalTo(switchButtonWidth)
						make.trailing.equalTo(cell.contentView).offset(-tableViewCellTrailingPadding)
					})
				}
			default: break
			}
		} else if indexPath.section == 4 { // About

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
		case 2: return LocalizedStrings.Settings.outputWPM
		case 3: return	LocalizedStrings.Settings.inputPitch
		case 4: return	LocalizedStrings.Settings.about
		case 5: return LocalizedStrings.Settings.developerOptions
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
		if slider === self.outputWPMSlider {
			self.outputWPM = Int(slider.value)
			self.outputWPMSlider.value = Float(self.outputWPM)
			self.outputWPMCell.textLabel?.attributedText = getAttributedStringFrom("\(self.outputWPM)", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
		} else if slider == self.inputPitchSlider {
			self.inputPitch	= slider.value
			self.inputPitchSlider.value = Float(round(self.inputPitch * 10)/10.0)
			self.inputPitchCell.textLabel?.attributedText = getAttributedStringFrom("\(round(self.inputPitch * 10)/10.0) Hz", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
		} else if slider == self.animationDurationSlider {
			self.animationDurationScalar = NSTimeInterval(slider.value)
			self.animationDurationSlider.value = Float(round(self.animationDurationScalar * 10)/10.0)
			self.animationDurationCell.detailTextLabel?.attributedText = getAttributedStringFrom("\(round(self.animationDurationScalar * 10)/10.0)", withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
		}
	}

	func switchToggled(switchButton:UISwitch) {
		if switchButton === self.extraTextWhenShareSwitch {
			appDelegate.userDefaults.setBool(switchButton.on, forKey: userDefaultsKeyExtraTextWhenShare)
			appDelegate.userDefaults.synchronize()
		} else if switchButton === self.brightenUpScreenSwitch {
			appDelegate.userDefaults.setBool(switchButton.on, forKey: userDefaultsKeyBrightenScreenWhenOutput)
			appDelegate.userDefaults.synchronize()
		} else if switchButton === self.inputPitchAutomaticSwitch {
			appDelegate.userDefaults.setBool(switchButton.on, forKey: userDefaultsKeyInputPitchAutomatic)
			appDelegate.userDefaults.synchronize()
//			if switchButton.on {
//				self.inputPitchSlider.value = automaticPitchFrequencyMin
//				self.inputPitch = automaticPitchFrequencyMin
//				self.inputPitchCell.textLabel?.attributedText = getAttributedStringFrom("\(round(self.inputPitch * 10)/10.0) Hz", withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
//			}
		}
	}
	
	func resetAnimationDurationScalar() {
		self.animationDurationSlider.value = 1
		self.animationDurationScalar = 1
		self.animationDurationCell.detailTextLabel?.attributedText = getAttributedStringFrom("1.0", withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
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
