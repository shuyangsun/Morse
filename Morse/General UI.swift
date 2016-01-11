//
//  General UI.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let TAP_FEED_BACK_DURATION:NSTimeInterval = 0.4
let defaultAnimationDuration:NSTimeInterval = 0.35

let topBarHeight:CGFloat = 56

let textViewInputFontSize:CGFloat = 16
let textViewOutputFontSize:CGFloat = 16

let cardViewTextFontSizeDictionary:CGFloat = 22
let cardViewTextProsignFontSizeDictionary:CGFloat = 16
let cardViewMorseFontSizeDictionary:CGFloat = 16
let morseFontSizeProgressBar:CGFloat = 14
let hintLabelFontSize:CGFloat = 18
let hintLabelMarginVertical:CGFloat = 15

let cardViewLabelPaddingVerticle:CGFloat = 16
let cardViewLabelPaddingHorizontal:CGFloat = 15
let cardViewLabelVerticalGap:CGFloat = 10
let cardBackViewButtonPadding:CGFloat = 5.0

let dictionaryVCCardViewMinWidth:CGFloat = 155

let audioPlotRollingHistoryLength:Int32 = 150

let slideAndPinchStartDistance:CGFloat = 15
let slideAndPinchRatioToDismiss:CGFloat = 0

let switchButtonWidth = 51
let switchButtonHeight = 31

var sliderWidth:CGFloat {
	return 200
}

let tableViewCellTextLabelWidth:CGFloat = 100
let tableViewCellHeight:CGFloat = 50
let tableViewCellTrailingPadding:CGFloat = 18
let tableViewCellTextLabelFontSize:CGFloat = 16
let tableViewCellDetailTextLabelFontSize:CGFloat = 12

let defaultTransmitterValueConfigurationViewHeight:CGFloat = 100

let appStoreURLString = "http://www.test.com"

private var cardViewHeight:CGFloat {
	//		return 74 // This is Google Translate card view's height
	return 86
}

var statusBarHeight:CGFloat {
	return UIApplication.sharedApplication().statusBarFrame.size.height
}

var animationDurationScalar:NSTimeInterval {
	return appDelegate.animationDurationScalar
}

enum Direction:Int {
	case BottomToTop = 1
	case LeftToRight = 2
	case TopToBottom = 3
	case RightToLeft = 4
}

