//
//  General UI.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let TAP_FEED_BACK_DURATION:TimeInterval = 0.4
let defaultAnimationDuration:TimeInterval = 0.35

let topBarHeight:CGFloat = 56
let textBackgroundViewHeight:CGFloat = 140
let backButtonAnimationOffset:CGFloat = 30
let webViewUnloadedTopBarAlpha:CGFloat = 0.75

let textViewInputFontSize:CGFloat = 16
let textViewOutputFontSize:CGFloat = 16

let cardViewTextFontSizeDictionary:CGFloat = 22
let cardViewTextProsignFontSizeDictionary:CGFloat = 16
let cardViewMorseFontSizeDictionary:CGFloat = 16
let cardViewExpandButtonPadding:CGFloat = 5
let morseFontSizeProgressBar:CGFloat = 14
let hintLabelFontSize:CGFloat = 18
let hintLabelMarginVertical:CGFloat = 15

let cardViewLabelPaddingVerticle:CGFloat = 16
let cardViewLabelPaddingHorizontal:CGFloat = 15
let cardViewLabelVerticalGap:CGFloat = 10
let cardBackViewButtonPadding:CGFloat = 5.0
let cardBackViewButtonWidth:CGFloat = 76
let cardBackViewButtonHeight:CGFloat = cardBackViewButtonWidth

let dictionaryVCCardViewMinWidth:CGFloat = 155

let audioPlotRollingHistoryLength:Int32 = 150

let slideAndPinchStartDistance:CGFloat = 15
let slideAndPinchRatioToDismiss:CGFloat = 0

let switchButtonWidth = 51
let switchButtonHeight = 31

var sliderWidth:CGFloat {
	return 200
}

let tableViewCellHeight:CGFloat = 60
let tableViewCellHorizontalPadding:CGFloat = 18
let tableViewCellTextLabelFontSize:CGFloat = 16
let tableViewCellDetailTextLabelFontSize:CGFloat = tableViewCellTextLabelFontSize

let transConfigCellHeight:CGFloat = 150
let transConfigVerticalMargin:CGFloat = 15
let transConfigSliderLabelVerticalMargin:CGFloat = transConfigVerticalMargin/2.0
let transConfigHorizontalMargin:CGFloat = tableViewCellHorizontalPadding
let transConfigSectionHeaderFontSize:CGFloat = 18
let transConfigSectionHeaderHeight:CGFloat = 50
let transConfigValueLabelFontSize:CGFloat = 22
let transConfigMinusPlusFontSize:CGFloat = 32
let transConfigDisabledButtonAlpha:CGFloat = 0.3
let transConfigNumPadDoneButtonHeight:CGFloat = tableViewCellHeight
let transConfigNumPadDoneButtonFontSize:CGFloat = tableViewCellTextLabelFontSize
let minusButtonText = "−"
let plusButtonText = "+"

let mdAlertMaxWidth:CGFloat = 450
let mdAlertTitleFontSize:CGFloat = 18
let mdAlertMessageFontSize:CGFloat = 18
let mdAlertButtonFontSize:CGFloat = 16
let mdAlertButtonHeight:CGFloat = tableViewCellHeight
let mdAlertPaddingVertical:CGFloat = 15
let mdAlertPaddingHorizontal:CGFloat = 20
let mdAlertMarginHorizontal:CGFloat = 35
let mdAlertMarginVertical:CGFloat = mdAlertButtonHeight
let mdAlertMinHeight:CGFloat = 150

private var cardViewHeight:CGFloat {
	//		return 74 // This is Google Translate card view's height
	return 86
}

var statusBarHeight:CGFloat {
	return UIApplication.shared.statusBarFrame.size.height
}

var animationDurationScalar:TimeInterval {
	return appDelegate.animationDurationScalar
}

enum Direction:Int {
	case bottomToTop = 1
	case leftToRight = 2
	case topToBottom = 3
	case rightToLeft = 4
}


extension UIView {

    class func animateWithScaledDuration(_ duration: TimeInterval, animations: @escaping () -> Void) {
		self.animate(withDuration: duration * animationDurationScalar,
			animations: animations)
	}

    class func animateWithScaledDuration(_ duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
		self.animate(withDuration: duration * animationDurationScalar,
			animations: animations,
			completion: completion)
	}

    class func animateWithScaledDuration(_ duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
		self.animate(withDuration: duration * animationDurationScalar,
			delay: delay,
			options: options,
			animations: animations,
			completion: completion)
	}

    class func animateWithScaledDuration(_ duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
		self.animate(withDuration: duration * animationDurationScalar,
			delay: delay,
			usingSpringWithDamping: dampingRatio,
			initialSpringVelocity: velocity,
			options: options,
			animations: animations,
			completion: completion)
	}
}
