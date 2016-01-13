//
//  TableViewTransmitterConfigurationCell.swift
//  Morse
//
//  Created by Shuyang Sun on 1/11/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class TableViewTransmitterConfigurationCell: TableViewCell {

	override var tag:Int {
		willSet {
			self.valueTextField.tag = newValue
			self.minusButton.tag = newValue
			self.plusButton.tag = newValue
			self.slider.tag = newValue
			self.sliderMinLabel.tag = newValue
			self.sliderMaxLabel.tag = newValue
		}
	}

	var valueTextField:UITextField!
	var minusButton:UIButton!
	var plusButton:UIButton!
	var slider:UISlider!
	var sliderMinLabel:UILabel!
	var sliderMaxLabel:UILabel!
	var convertFloatToInteger = true
	var delegate:TableViewTransmitterConfigurationCellDelegate? {
		willSet {
			self.valueTextField?.delegate = newValue
		}
	}
	var isInteractionEnabled = true {
		willSet {
			self.userInteractionEnabled = newValue
			if newValue {
				self.valueTextField.alpha = 1
				self.minusButton.alpha = 1
				self.plusButton.alpha = 1
				self.slider.alpha = 1
				self.sliderMinLabel.alpha = 1
				self.sliderMaxLabel.alpha = 1
			} else {
				self.valueTextField.alpha = transConfigDisabledButtonAlpha
				self.minusButton.alpha = transConfigDisabledButtonAlpha
				self.plusButton.alpha = transConfigDisabledButtonAlpha
				self.slider.alpha = transConfigDisabledButtonAlpha
				self.sliderMinLabel.alpha = transConfigDisabledButtonAlpha
				self.sliderMaxLabel.alpha = transConfigDisabledButtonAlpha
			}
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
		self.tapFeebackEnabled = false

		if self.valueTextField == nil {
			self.valueTextField = UITextField()
			self.valueTextField.backgroundColor = UIColor.clearColor()
			self.valueTextField.borderStyle = .None
			self.valueTextField.textAlignment = .Center
			self.valueTextField.keyboardType = .NumberPad
			self.valueTextField.clearsOnBeginEditing = true
			self.valueTextField.keyboardAppearance = theme.keyboardAppearance
			self.valueTextField.opaque = false
			self.valueTextField.textColor = theme.transConfigLabelTextColorEmphasized
			// Add done button
			let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: transConfigNumPadDoneButtonHeight))
			doneButton.addTarget(self.valueTextField, action: "resignFirstResponder", forControlEvents: .TouchUpInside)
			doneButton.backgroundColor = theme.transValConfigViewNumPadDoneButtonBackgroundColor
			doneButton.setAttributedTitle(getAttributedStringFrom(LocalizedStrings.General.done, withFontSize: transConfigNumPadDoneButtonFontSize, color: theme.transValConfigViewNumPadDoneButtonTextColorNormal, bold: true), forState: .Normal)
			doneButton.setAttributedTitle(getAttributedStringFrom(LocalizedStrings.General.done, withFontSize: transConfigNumPadDoneButtonFontSize, color: theme.transValConfigViewNumPadDoneButtonTextColorHighlighted, bold: true), forState: .Highlighted)
			self.valueTextField.inputAccessoryView = doneButton
			self.addSubview(self.valueTextField)
			self.valueTextField.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self).offset(transConfigVerticalMargin)
				make.centerX.equalTo(self)
				make.leading.equalTo(self)
				make.trailing.equalTo(self)
			})
		}

		if self.minusButton == nil {
			self.minusButton = UIButton()
			self.minusButton.opaque = false
			self.minusButton.setAttributedTitle(getAttributedStringFrom(minusButtonText, withFontSize: transConfigMinusPlusFontSize, color: theme.transValConfigViewPlusMinusButtonTintColorNormal, bold: false), forState: .Normal)
			self.minusButton.setAttributedTitle(getAttributedStringFrom(minusButtonText, withFontSize: transConfigMinusPlusFontSize, color: theme.transValConfigViewPlusMinusButtonTintColorHighlighted, bold: false), forState: .Highlighted)
			self.minusButton.addTarget(self, action: "minusButtonTapped", forControlEvents: .TouchUpInside)
			self.addSubview(self.minusButton)
			self.minusButton.snp_makeConstraints(closure: { (make) -> Void in
				make.centerY.equalTo(self)
				make.leading.equalTo(self).offset(transConfigHorizontalMargin)
			})
		}

		if self.plusButton == nil {
			self.plusButton = UIButton()
			self.plusButton.opaque = false
			self.plusButton.setAttributedTitle(getAttributedStringFrom(plusButtonText, withFontSize: transConfigMinusPlusFontSize, color: theme.transValConfigViewPlusMinusButtonTintColorNormal, bold: false), forState: .Normal)
			self.plusButton.setAttributedTitle(getAttributedStringFrom(plusButtonText, withFontSize: transConfigMinusPlusFontSize, color: theme.transValConfigViewPlusMinusButtonTintColorHighlighted, bold: false), forState: .Highlighted)
			self.plusButton.addTarget(self, action: "plusButtonTapped", forControlEvents: .TouchUpInside)
			self.addSubview(self.plusButton)
			self.plusButton.snp_makeConstraints(closure: { (make) -> Void in
				make.centerY.equalTo(self.minusButton)
				make.trailing.equalTo(self).offset(-transConfigHorizontalMargin)
			})
		}

		if self.slider == nil {
			self.slider = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: tableViewCellHeight))
			self.slider.opaque = false
			self.slider.minimumTrackTintColor = theme.sliderMinTrackTintColor
			self.slider.maximumTrackTintColor = theme.sliderMaxTrackTintColor
			self.slider.thumbTintColor = theme.sliderThumbTintColor
			self.slider.addTarget(self, action: "sliderValueChanged", forControlEvents: .ValueChanged)
			self.addSubview(self.slider)
			self.slider.snp_makeConstraints(closure: { (make) -> Void in
				make.leading.equalTo(self.minusButton.snp_trailing).offset(transConfigHorizontalMargin)
				make.trailing.equalTo(self.plusButton.snp_leading).offset(-transConfigHorizontalMargin)
				make.centerY.equalTo(self.minusButton)
				make.height.equalTo(tableViewCellHeight)
			})
		}

		if self.sliderMinLabel == nil {
			self.sliderMinLabel = UILabel()
			self.sliderMinLabel.opaque = false
			self.sliderMinLabel.textColor = theme.transConfigLabelTextColorNormal
			self.addSubview(self.sliderMinLabel)
			self.sliderMinLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.slider.snp_bottom).offset(transConfigSliderLabelVerticalMargin)
				make.leading.equalTo(self.slider)
			})
		}

		if self.sliderMaxLabel == nil {
			self.sliderMaxLabel = UILabel()
			self.sliderMaxLabel.opaque = false
			self.sliderMaxLabel.textColor = theme.transConfigLabelTextColorNormal
			self.addSubview(self.sliderMaxLabel)
			self.sliderMaxLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerY.equalTo(self.sliderMinLabel)
				make.trailing.equalTo(self.slider)
			})
		}
    }

	func setMinAndMaxValue(sliderMinValue:Float, sliderMaxValue:Float) {
		self.slider.minimumValue = sliderMinValue
		self.slider.maximumValue = sliderMaxValue
		self.sliderMinLabel.attributedText = getAttributedStringFrom(self.convertFloatToInteger ? String(Int(sliderMinValue)) : String(sliderMinValue), withFontSize: tableViewCellDetailTextLabelFontSize, color: theme.transConfigLabelTextColorNormal, bold: true)
		self.sliderMaxLabel.attributedText = getAttributedStringFrom(self.convertFloatToInteger ? String(Int(sliderMaxValue)) : String(sliderMaxValue), withFontSize: tableViewCellDetailTextLabelFontSize, color: theme.transConfigLabelTextColorNormal, bold: true)
	}

	func changeValueText(valueText:String) {
		self.valueTextField.attributedText = getAttributedStringFrom(valueText, withFontSize: transConfigValueLabelFontSize, color: theme.transConfigLabelTextColorEmphasized, bold: true)
	}

	func minusButtonTapped() {
		self.delegate?.transConfigCell?(self, minusButtonTapped: self.minusButton)
	}

	func plusButtonTapped() {
		self.delegate?.transConfigCell?(self, plusButtonTapped: self.plusButton)
	}

	func sliderValueChanged() {
		self.delegate?.transConfigCell?(self, sliderValueChanged: self.slider)
	}
}
