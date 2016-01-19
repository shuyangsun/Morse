//
//  SettingsAudioDecoderTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/11/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsAudioDecoderTableViewController: TableViewController, TableViewSwitchCellDelegate, TableViewTransmitterConfigurationCellDelegate {

	// Tags for switches
	private let _configCellTagWPM = 0
	private let _configCellTagPitch = 1
	private let _switchButtonTagAutoWPM = 2
	private let _switchButtonTagAutoPitch = 3
	private let _switchButtonTagAutoCorrect = 4

	private var _textFieldOriginalText:String?

	private func setup() {
//		self.tableView.separatorStyle = .None

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.audioDecoder
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

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setup()
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: settingsAudioDecoderConfigVCName)

		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 1
		case 1: return 3
		case 2: return 3
		default: return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = TableViewCell()
		if indexPath.section == 1 ||  indexPath.section == 2 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.automaticAudioDecoderValue, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				let switchCell = cell as! TableViewSwitchCell
				switchCell.delegate = self
				switchCell.tag = indexPath.section == 1 ? self._switchButtonTagAutoWPM : self._switchButtonTagAutoPitch
				switchCell.switchButton.on = indexPath.section == 1 ? appDelegate.inputWPMAutomatic : appDelegate.inputPitchAutomatic
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Audio Decoder Transmitter Configuration Cell", forIndexPath: indexPath) as! TableViewTransmitterConfigurationCell
				let configCell = cell as! TableViewTransmitterConfigurationCell
				if indexPath.section == 1 { // WPM
					configCell.tag = self._configCellTagWPM
					configCell.setMinAndMaxValue(Float(supportedAudioDecoderWPMRange.startIndex), sliderMaxValue: Float(supportedAudioDecoderWPMRange.endIndex - 1))
					configCell.slider.value = Float(appDelegate.inputWPM)
					configCell.changeValueText(String(appDelegate.inputWPM))
					configCell.isInteractionEnabled = !appDelegate.inputWPMAutomatic
				} else if indexPath.section == 2 { // Pitch
					configCell.tag = self._configCellTagPitch
					configCell.setMinAndMaxValue(Float(supportedAudioDecoderPitchRange.startIndex), sliderMaxValue: Float(supportedAudioDecoderPitchRange.endIndex - 1))
					configCell.slider.value = Float(appDelegate.inputPitch)
					var text = "\(Int(appDelegate.inputPitch)) Hz"
					if layoutDirection == .RightToLeft {
						text = "Hz \(Int(appDelegate.inputPitch))"
					}
					configCell.changeValueText(text)
					configCell.isInteractionEnabled = !appDelegate.inputPitchAutomatic
				}
				configCell.delegate = self
			case 2:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Reset Cell", forIndexPath: indexPath) as! TableViewResetCell
			default: break
			}
		} else if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.audioDecoderAutoCorrect, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				let switchCell = cell as! TableViewSwitchCell
				switchCell.delegate = self
				switchCell.tag = self._switchButtonTagAutoCorrect
				switchCell.switchButton.on = appDelegate.autoCorrectMissSpelledWordsForAudioInput
			default: break
			}
		}

		cell.separatorInset = UIEdgeInsetsZero
		cell.preservesSuperviewLayoutMargins = false
		cell.layoutMargins = UIEdgeInsetsZero
		return cell
    }

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.row {
		case 1: return transConfigCellHeight
		default: return tableViewCellHeight
		}
	}

	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return transConfigSectionHeaderHeight
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		switch section {
		case 1:
			label.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.wpm, withFontSize: transConfigSectionHeaderFontSize, color: theme.transConfigHeaderLabelTextColor, bold: false)
		case 2:
			label.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.pitch, withFontSize: transConfigSectionHeaderFontSize, color: theme.transConfigHeaderLabelTextColor, bold: false)
		default: break
		}
		let outterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: transConfigSectionHeaderHeight))
		outterView.addSubview(label)
		label.snp_makeConstraints { (make) -> Void in
			make.centerX.equalTo(outterView)
			make.centerY.equalTo(outterView)
		}
		return outterView
	}

	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 0: return LocalizedStrings.Settings.autoCorrectWordDescription
		case 1: return LocalizedStrings.Settings.tapOnNumToTypeDescription
		case 2: return LocalizedStrings.Settings.tapOnNumToTypeDescription
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let tracker = GAI.sharedInstance().defaultTracker
		if indexPath.row == 2 {
			switch indexPath.section {
			case 1:
				let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! TableViewTransmitterConfigurationCell
				appDelegate.inputWPM = defaultInputWPM
				cell.slider.value = Float(defaultInputWPM)
				cell.changeValueText("\(defaultInputWPM)")
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Reset Audio Decoder WPM Tapped",
					value: nil).build() as [NSObject : AnyObject])
			case 2:
				let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 2)) as! TableViewTransmitterConfigurationCell
				appDelegate.inputPitch = defaultInputPitch
				cell.slider.value = defaultInputPitch
				var text = "\(Int(defaultInputPitch)) Hz"
				if layoutDirection == .RightToLeft {
					text = "Hz \(Int(defaultInputPitch))"
				}
				cell.changeValueText(text)
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Reset Audio Decoder Pitch Tapped",
					value: nil).build() as [NSObject : AnyObject])
			default: break
			}
		}
	}

	func textFieldDidBeginEditing(textField: UITextField) {
		self.tableView.scrollEnabled = false
		self.tableView.allowsSelection = false
		self._textFieldOriginalText = textField.text
	}

	func textFieldDidEndEditing(textField: UITextField) {
		let tracker = GAI.sharedInstance().defaultTracker
		if textField.tag == self._configCellTagWPM {
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "TextField Audio Decoder WPM Done Button Tapped",
				value: nil).build() as [NSObject : AnyObject])
			var number = appDelegate.inputWPM
			let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! TableViewTransmitterConfigurationCell
			if textField.text != nil && Int(textField.text!) != nil {
				number = Int(textField.text!)!
				number = max(supportedAudioDecoderWPMRange.startIndex, number)
				number = min(supportedAudioDecoderWPMRange.endIndex - 1, number)
				appDelegate.inputWPM = number
				cell.slider.value = Float(number)
			}
			let text = "\(number)"
			cell.changeValueText(text)
		} else if textField.tag == self._configCellTagPitch {
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "TextField Audio Decoder Pitch Done Button Tapped",
				value: nil).build() as [NSObject : AnyObject])
			var number = appDelegate.inputPitch
			let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 2)) as! TableViewTransmitterConfigurationCell
			if textField.text != nil && Float(textField.text!) != nil {
				number = Float(textField.text!)!
				number = max(Float(supportedAudioDecoderPitchRange.startIndex), number)
				number = min(Float(supportedAudioDecoderPitchRange.endIndex - 1), number)
				appDelegate.inputPitch = number
				cell.slider.value = number
			}
			var text = "\(Int(number)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(number))"
			}
			cell.changeValueText(text)
		}
		self.tableView.allowsSelection = true
		self.tableView.scrollEnabled = true
	}

	func switchToggled(switchButton:UISwitch) {
		let tracker = GAI.sharedInstance().defaultTracker
		switch switchButton.tag {
		case self._switchButtonTagAutoWPM:
			appDelegate.inputWPMAutomatic = switchButton.on
			NSTimer.scheduledTimerWithTimeInterval(0.25, target: self.tableView, selector: "reloadData", userInfo: nil, repeats: false)
			if switchButton.on {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Auto WPM Turned On",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Auto WPM Turned Off",
					value: nil).build() as [NSObject : AnyObject])
			}
		case self._switchButtonTagAutoPitch:
			appDelegate.inputPitchAutomatic = switchButton.on
			NSTimer.scheduledTimerWithTimeInterval(0.25, target: self.tableView, selector: "reloadData", userInfo: nil, repeats: false)
			if switchButton.on {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Auto Pitch Turned On",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Auto Pitch Turned Off",
					value: nil).build() as [NSObject : AnyObject])
			}
		case self._switchButtonTagAutoCorrect:
			appDelegate.autoCorrectMissSpelledWordsForAudioInput = switchButton.on
			if switchButton.on {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Audio Decoder Auto Correct Turned On",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "switch_toggle",
					label: "Audio Decoder Auto Correct Turned Off",
					value: nil).build() as [NSObject : AnyObject])
			}
		default: break
		}
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, minusButtonTapped button: UIButton) {
		let tracker = GAI.sharedInstance().defaultTracker
		if cell.tag == self._configCellTagWPM {
			let newValue = max(cell.slider.value - 1, Float(supportedAudioDecoderWPMRange.startIndex))
			appDelegate.inputWPM = Int(newValue)
			cell.slider.value = newValue
			cell.changeValueText("\(Int(newValue))")
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Audio Decoder WPM Minus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		} else if cell.tag == self._configCellTagPitch {
			let newValue = max(cell.slider.value - 1, Float(supportedAudioDecoderPitchRange.startIndex))
			appDelegate.inputPitch = newValue
			cell.slider.value = newValue
			var text = "\(Int(newValue)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(newValue))"
			}
			cell.changeValueText(text)
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Audio Decoder Pitch Minus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		}
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, plusButtonTapped button: UIButton) {
		let tracker = GAI.sharedInstance().defaultTracker
		if cell.tag == self._configCellTagWPM {
			let newValue = min(cell.slider.value + 1, Float(supportedAudioDecoderWPMRange.endIndex - 1))
			appDelegate.inputWPM = Int(newValue)
			cell.slider.value = newValue
			cell.changeValueText("\(Int(newValue))")
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Audio Decoder WPM Plus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		} else if cell.tag == self._configCellTagPitch {
			let newValue = min(cell.slider.value + 1, Float(supportedAudioDecoderPitchRange.endIndex - 1))
			appDelegate.inputPitch = newValue
			cell.slider.value = newValue
			var text = "\(Int(newValue)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(newValue))"
			}
			cell.changeValueText(text)
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Audio Decoder Pitch Plus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		}
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, sliderValueChanged slider: UISlider) {
		if cell.tag == self._configCellTagWPM {
			appDelegate.inputWPM = Int(slider.value)
			cell.changeValueText("\(Int(slider.value))")
		} else if cell.tag == self._configCellTagPitch {
			appDelegate.inputPitch = slider.value
			var text = "\(Int(slider.value)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(slider.value))"
			}
			cell.changeValueText(text)
		}
	}
}
