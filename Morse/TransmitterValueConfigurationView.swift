//
//  TransmitterValueConfigurationView.swift
//  Morse
//
//  Created by Shuyang Sun on 1/10/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class TransmitterValueConfigurationView: UIView {

	var showBorderTop = false {
		willSet {
			self.borderTopView.hidden = !newValue
		}
	}
	var showBorderBottom = false {
		willSet {
			self.borderBottomView.hidden = !newValue
		}
	}
	var showAutoButton = false {
		willSet {
			self.autoLabel.hidden = !newValue
			self.autoSwitch.hidden = !newValue
		}
	}

	var borderBottomView:UIView!
	var borderTopView:UIView!

	var valueNameLabel:UILabel!
	var autoLabel:UILabel!
	var autoSwitch:UISwitch!
	var minusButton:UIButton!
	var plusButton:UIButton!
	var valueSlider:UISlider!
	var sliderMinLabel:UILabel!
	var sliderMaxLabel:UILabel!
	var resetButton:UIButton!

	override convenience init(frame: CGRect) {
		self.init(frame: frame, showBorderTop: false, showBorderBottom: false, showAutoButton: false)
	}

	init(frame:CGRect, showBorderTop:Bool = false, showBorderBottom:Bool = false, showAutoButton:Bool = false) {
		super.init(frame: frame)
		self.backgroundColor = theme.transValConfigViewBackgroundColor

		// Setup UI elements
		// TODO

		// Setup appearance style
		self.showBorderTop = showBorderTop
		self.showBorderBottom = showBorderBottom
		self.showAutoButton = showAutoButton
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func updateColor(animated animated:Bool = true) {
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animateWithDuration(duration,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				// TODO
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

}
