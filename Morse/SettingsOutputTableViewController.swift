//
//  SettingsOutputTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/12/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

import UIKit

class SettingsOutputTableViewController: TableViewController, TableViewSwitchCellDelegate, TableViewTransmitterConfigurationCellDelegate {

	// Tags for switches
	private let _configCellTagWPM = 0
	private let _configCellTagPitch = 1
	private let _switchButtonTagBrightenScreen = 2

	private var _textFieldOriginalText:String?

	private func setup() {

		self.view.backgroundColor = theme.tableViewBackgroundColor
		self.tableView.separatorColor = theme.tableViewSeparatorColor
		//		self.tableView.separatorStyle = .None

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.output
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
		tracker.set(kGAIScreenName, value: settingsOutputConfigVCName)

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
		case 1: return 2
		case 2: return 2
		default: return 0
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = TableViewCell()
		if indexPath.section == 1 ||  indexPath.section == 2 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Audio Decoder Transmitter Configuration Cell", forIndexPath: indexPath) as! TableViewTransmitterConfigurationCell
				let configCell = cell as! TableViewTransmitterConfigurationCell
				if indexPath.section == 1 { // WPM
					configCell.tag = self._configCellTagWPM
					configCell.setMinAndMaxValue(Float(supportedOutputWPMRange.startIndex), sliderMaxValue: Float(supportedOutputWPMRange.endIndex - 1))
					configCell.slider.value = Float(appDelegate.outputWPM)
					configCell.changeValueText(String(appDelegate.outputWPM))
				} else if indexPath.section == 2 { // Pitch
					configCell.tag = self._configCellTagPitch
					configCell.setMinAndMaxValue(Float(supportedOutputPitchRange.startIndex), sliderMaxValue: Float(supportedOutputPitchRange.endIndex - 1))
					configCell.slider.value = Float(appDelegate.outputPitch)
					var text = "\(Int(appDelegate.outputPitch)) Hz"
					if layoutDirection == .RightToLeft {
						text = "Hz \(Int(appDelegate.outputPitch))"
					}
					configCell.changeValueText(text)
				}
				configCell.delegate = self
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Reset Cell", forIndexPath: indexPath) as! TableViewResetCell
			default: break
			}
		} else if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
				cell.tapFeebackEnabled = false
				cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.Settings.brightenUpDisplayWhenOutput, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				let switchCell = cell as! TableViewSwitchCell
				switchCell.delegate = self
				switchCell.tag = self._switchButtonTagBrightenScreen
				switchCell.switchButton.on = appDelegate.brightenScreenWhenOutput
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
		case 0:
			if indexPath.section == 1 || indexPath.section == 2 {
				return transConfigCellHeight
			}
		default: return tableViewCellHeight
		}
		return tableViewCellHeight
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
		case 0: return LocalizedStrings.Settings.outputBrightenScreenDescription
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let tracker = GAI.sharedInstance().defaultTracker
		if indexPath.row == 1 {
			switch indexPath.section {
			case 1:
				let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! TableViewTransmitterConfigurationCell
				appDelegate.outputWPM = defaultOutputWPM
				cell.slider.value = Float(defaultOutputWPM)
				cell.changeValueText("\(defaultOutputWPM)")
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Reset Output WPM Tapped",
					value: nil).build() as [NSObject : AnyObject])
			case 2:
				let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as! TableViewTransmitterConfigurationCell
				appDelegate.outputPitch = defaultOutputPitch
				cell.slider.value = defaultOutputPitch
				var text = "\(Int(defaultOutputPitch)) Hz"
				if layoutDirection == .RightToLeft {
					text = "Hz \(Int(defaultOutputPitch))"
				}
				cell.changeValueText(text)
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Reset Output Pitch Tapped",
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
			var number = appDelegate.outputWPM
			let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! TableViewTransmitterConfigurationCell
			if textField.text != nil && Int(textField.text!) != nil {
				number = Int(textField.text!)!
				number = max(supportedOutputWPMRange.startIndex, number)
				number = min(supportedOutputWPMRange.endIndex - 1, number)
				appDelegate.outputWPM = number
				cell.slider.value = Float(number)
			}
			let text = "\(number)"
			cell.changeValueText(text)
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "TextField Output WPM Done Button Tapped",
				value: nil).build() as [NSObject : AnyObject])
		} else if textField.tag == self._configCellTagPitch {
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "TextField Output Pitch Done Button Tapped",
				value: nil).build() as [NSObject : AnyObject])
			var number = appDelegate.outputPitch
			let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as! TableViewTransmitterConfigurationCell
			if textField.text != nil && Float(textField.text!) != nil {
				number = Float(textField.text!)!
				number = max(Float(supportedOutputPitchRange.startIndex), number)
				number = min(Float(supportedOutputPitchRange.endIndex - 1), number)
				appDelegate.outputPitch = number
				cell.slider.value = number
			}
			var text = "\(Int(number)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(number))"
			}
			cell.changeValueText(text)
		}
		self.tableView.scrollEnabled = true
		self.tableView.allowsSelection = true
	}

	func switchToggled(switchButton:UISwitch) {
		switch switchButton.tag {
		case self._switchButtonTagBrightenScreen:
			appDelegate.brightenScreenWhenOutput = switchButton.on
		default: break
		}
		let tracker = GAI.sharedInstance().defaultTracker
		if switchButton.on {
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "switch_toggle",
				label: "Output Brighten Screen Turned On",
				value: nil).build() as [NSObject : AnyObject])
		} else {
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "switch_toggle",
				label: "Output Brighten Screen Turned Off",
				value: nil).build() as [NSObject : AnyObject])
		}
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, minusButtonTapped button: UIButton) {
		let tracker = GAI.sharedInstance().defaultTracker
		if cell.tag == self._configCellTagWPM {
			let newValue = max(cell.slider.value - 1, Float(supportedOutputWPMRange.startIndex))
			appDelegate.outputWPM = Int(newValue)
			cell.slider.value = newValue
			cell.changeValueText("\(Int(newValue))")
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Output WPM Minus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		} else if cell.tag == self._configCellTagPitch {
			let newValue = max(cell.slider.value - 1, Float(supportedOutputPitchRange.startIndex))
			appDelegate.outputPitch = newValue
			cell.slider.value = newValue
			var text = "\(Int(newValue)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(newValue))"
			}
			cell.changeValueText(text)
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Output Pitch Minus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		}
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, plusButtonTapped button: UIButton) {
		let tracker = GAI.sharedInstance().defaultTracker
		if cell.tag == self._configCellTagWPM {
			let newValue = min(cell.slider.value + 1, Float(supportedOutputWPMRange.endIndex - 1))
			appDelegate.outputWPM = Int(newValue)
			cell.slider.value = newValue
			cell.changeValueText("\(Int(newValue))")
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Output WPM Plus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		} else if cell.tag == self._configCellTagPitch {
			let newValue = min(cell.slider.value + 1, Float(supportedOutputPitchRange.endIndex - 1))
			appDelegate.outputPitch = newValue
			cell.slider.value = newValue
			var text = "\(Int(newValue)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(newValue))"
			}
			cell.changeValueText(text)
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Output Pitch Plus Tapped",
				value: nil).build() as [NSObject : AnyObject])
		}
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, sliderValueChanged slider: UISlider) {
		if cell.tag == self._configCellTagWPM {
			appDelegate.outputWPM = Int(slider.value)
			cell.changeValueText("\(Int(slider.value))")
		} else if cell.tag == self._configCellTagPitch {
			appDelegate.outputPitch = slider.value
			var text = "\(Int(slider.value)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(slider.value))"
			}
			cell.changeValueText(text)
		}
	}

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
			}, completion: nil)
		self.tableView.reloadData()
	}
}