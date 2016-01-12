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

	private func setup() {

		self.view.backgroundColor = theme.tableViewBackgroundColor
		self.tableView.separatorColor = theme.tableViewSeparatorColor
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 3
		case 1: return 3
		default: return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = TableViewCell()
		switch indexPath.row {
		case 0:
			cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Cell", forIndexPath: indexPath) as! TableViewSwitchCell
			cell.tapFeebackEnabled = false
			cell.textLabel?.attributedText =  getAttributedStringFrom(LocalizedStrings.General.automatic, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
			let switchCell = cell as! TableViewSwitchCell
			switchCell.displaySwitchNextToLabel = true
			switchCell.delegate = self
			switchCell.switchButton.tag = indexPath.section == 0 ? self._switchButtonTagAutoWPM : self._switchButtonTagAutoPitch
			switchCell.switchButton.on = indexPath.section == 0 ? appDelegate.inputWPMAutomatic : appDelegate.inputPitchAutomatic
		case 1:
			cell = tableView.dequeueReusableCellWithIdentifier("Settings Audio Decoder Transmitter Configuration Cell", forIndexPath: indexPath) as! TableViewTransmitterConfigurationCell
			let configCell = cell as! TableViewTransmitterConfigurationCell
			if indexPath.section == 0 { // WPM
				configCell.tag = self._configCellTagWPM
				configCell.setMinAndMaxValue(Float(supportedAudioDecoderWPMRange.startIndex), sliderMaxValue: Float(supportedAudioDecoderWPMRange.endIndex - 1))
				configCell.slider.value = Float(appDelegate.inputWPM)
				configCell.changeValueText(String(appDelegate.inputWPM))
				configCell.isInteractionEnabled = !appDelegate.inputWPMAutomatic
			} else if indexPath.section == 1 { // Pitch
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
		case 0:
			label.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.wpm, withFontSize: transConfigSectionHeaderFontSize, color: theme.transConfigHeaderLabelTextColor, bold: false)
		case 1:
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

	func switchToggled(switchButton:UISwitch) {
		switch switchButton.tag {
		case self._switchButtonTagAutoWPM:
			appDelegate.inputWPMAutomatic = switchButton.on
		case self._switchButtonTagAutoPitch:
			appDelegate.inputPitchAutomatic = switchButton.on
		default: break
		}
		NSTimer.scheduledTimerWithTimeInterval(0.25, target: self.tableView, selector: "reloadData", userInfo: nil, repeats: false)
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, minusButtonTapped button: UIButton) {
		if cell.tag == self._configCellTagWPM {
			let newValue = max(cell.slider.value - 1, Float(supportedAudioDecoderWPMRange.startIndex))
			appDelegate.inputWPM = Int(newValue)
			cell.slider.value = newValue
			cell.changeValueText("\(Int(newValue))")
		} else if cell.tag == self._configCellTagPitch {
			let newValue = max(cell.slider.value - 1, Float(supportedAudioDecoderPitchRange.startIndex))
			appDelegate.inputPitch = newValue
			cell.slider.value = newValue
			var text = "\(Int(newValue)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(newValue))"
			}
			cell.changeValueText(text)
		}
	}

	func transConfigCell(cell: TableViewTransmitterConfigurationCell, plusButtonTapped button: UIButton) {
		if cell.tag == self._configCellTagWPM {
			let newValue = min(cell.slider.value + 1, Float(supportedAudioDecoderWPMRange.endIndex - 1))
			appDelegate.inputWPM = Int(newValue)
			cell.slider.value = newValue
			cell.changeValueText("\(Int(newValue))")
		} else if cell.tag == self._configCellTagPitch {
			let newValue = min(cell.slider.value + 1, Float(supportedAudioDecoderPitchRange.endIndex - 1))
			appDelegate.inputPitch = newValue
			cell.slider.value = newValue
			var text = "\(Int(newValue)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(newValue))"
			}
			cell.changeValueText(text)
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
