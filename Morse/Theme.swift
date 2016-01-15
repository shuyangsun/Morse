//
//  Theme.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

var theme:Theme {
	get {
		return appDelegate.theme
	}
	set {
		appDelegate.theme = newValue
	}
}

enum ThemeStyle {
	case Light
	case Dark
}

enum Theme: Int {
	static let numberOfThemes = 2

	case Default = 0, Night

	var name:String {
		switch self {
		case .Default: return LocalizedStrings.ThemeName.defaultName
		case .Night: return LocalizedStrings.ThemeName.night
		}
	}

	var style:ThemeStyle {
		switch self {
		case .Night: return .Dark
		default: return .Light
		}
	}

	var keyboardAppearance:UIKeyboardAppearance {
		switch self.style {
		case .Light: return .Default
		case .Dark: return .Dark
		}
	}

	var scrollViewIndicatorStyle: UIScrollViewIndicatorStyle {
		switch self.style {
		case .Light: return .Default
		case .Dark: return .White
		}
	}

	// *****************************
	// MARK: Colors
	// *****************************

	private var defaultTapFeedbackColorDark:UIColor {
		return UIColor(hex: 0x000000, alpha: 0.2)
	}

	private var defaultTapFeedbackColorLight:UIColor {
		return UIColor(hex: 0xFFFFFF, alpha: 0.3)
	}

	var statusBarBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P700
		case .Night: return MDColorPalette.Grey.P900
		}
	}

	var topBarBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P500
		case .Night: return MDColorPalette.Grey.P800
		}
	}

	var topBarLabelTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var cancelButtonColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}

	var textViewBackgroundColor:UIColor {
		switch self {
		case .Night: return MDColorPalette.Grey.P700
		default: return UIColor.whiteColor()
		}
	}

	var textViewBreakLineColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: 0.1)
		default: return UIColor(hex: 0x000, alpha: 0.1)
		}
	}

	var textViewTapFeedbackColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P200
		case .Night: return MDColorPalette.Grey.P500
		}
	}

	var textViewHintTextColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	var textViewInputTextColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		default: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		}
	}

	var textViewOutputTextColor:UIColor {
		switch self {
		default: return self.textViewInputTextColor
		}
	}

	var roundButtonBackgroundColor:UIColor? {
		switch self {
		case .Default: return MDColorPalette.Red.A200!
//		case .Night: return MDColorPalette.Blue.A200!
		case .Night: return nil
		}
	}

	var roundButtonTapFeedbackColor:UIColor {
		switch self {
		default: return self.defaultTapFeedbackColorLight
		}
	}

	var keyboardButtonBackgroundColor:UIColor {
		switch self {
		default: return UIColor.clearColor()
		}
	}

	var keyboardButtonTapFeedbackColor:UIColor {
		switch self {
		default: return self.textViewTapFeedbackColor
		}
	}

	var scrollViewBackgroundColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: 0xEEEEEE)
		case .Night: return MDColorPalette.Grey.P900
		}
	}

	var scrollViewOverlayColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0x000, alpha: 0.8)
		default: return UIColor(hex: 0x000, alpha: 0.35)
		}
	}

	var cardViewBackgroudColor:UIColor {
		switch self {
		case .Default: return UIColor.whiteColor()
		case .Night: return MDColorPalette.Grey.P800
		}
	}

	var cardViewProsignBackgroudColor:UIColor {
		switch self {
		default: return self.cardViewBackgroudColor
		}
	}

	var cardViewProsignEmergencyBackgroundColor:UIColor {
		switch self {
		default: return MDColorPalette.Red.P500
		}
	}

	var cardViewExpandedBackgroudColor:UIColor {
		switch self {
		default: return self.cardViewBackgroudColor
		}
	}

	var cardViewTapfeedbackColor:UIColor {
		switch self {
		default: return self.textViewTapFeedbackColor
		}
	}

	var cardViewTextColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var cardViewMorseColor:UIColor {
		switch self {
		case .Default: return UIColor(hex:0x000, alpha: MDDarkTextSecondaryAlpha)
		case .Night: return UIColor(hex:0xFFFFFF, alpha: MDDarkTextSecondaryAlpha)
		}
	}

	var cardViewProsignTextColor:UIColor {
		switch self {
		default: return self.cardViewTextColor
		}
	}

	var cardViewProsignMorseColor:UIColor {
		switch self {
		default: return self.cardViewMorseColor
		}
	}

	var cardViewProsignEmergencyTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var cardViewProsignEmergencyMorseColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var cardBackViewBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P500
		case .Night: return MDColorPalette.Grey.P700
		}
	}

	var cardBackViewButtonTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var cardBackViewButtonSelectedTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDDarkTextHintAlpha)
		}
	}

	var cardViewBorderColor:UIColor {
		switch self {
		default: return UIColor.clearColor()
		}
	}

	// Output VC
	var outputVCTopBarColor:UIColor {
		switch self {
		default: return UIColor.blackColor()
		}
	}

	var progressBarColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P500
		case .Night: return MDColorPalette.Grey.P800
		}
	}

	var percentageTextColor:UIColor {
		switch self {
		case .Default: return self.topBarLabelTextColor
		case .Night: return MDColorPalette.Grey.P400
		}
	}

	var morseTextProgressBarColor:UIColor {
		switch self {
		default: return self.percentageTextColor
		}
	}

	var outputVCLabelTextColorEmphasized:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var outputVCLabelTextColorNormal:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	var waveformVCLabelTextColorEmphasized:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var waveformVCLabelTextColorNormal:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	// Tab bar VC
	var tabBarBackgroundColor:UIColor {
		switch self {
		default: return self.scrollViewBackgroundColor
		}
	}

	var navigationBarBackgroundColor:UIColor {
		switch self {
		default: return self.topBarBackgroundColor
		}
	}

	var navigationBarTitleTextColor:UIColor {
		switch self {
		default: return self.topBarLabelTextColor
		}
	}

	var tableViewCellBackgroundColor:UIColor {
		switch self {
		case .Default: return UIColor.whiteColor()
		case .Night: return MDColorPalette.Grey.P800
		}
	}

	var tableViewCellSelectedBackgroundColor:UIColor {
		switch self {
//		case .Default: return MDColorPalette.Blue.P300
//		case .Night: return MDColorPalette.Blue.A200!
		default: return self.tableViewCellBackgroundColor
		}
	}

	var tableViewBackgroundColor:UIColor {
		switch self {
		default: return self.scrollViewBackgroundColor
		}
	}

	var tableViewSeparatorColor:UIColor? {
		switch self {
		case .Night: return MDColorPalette.Grey.P600
		default: return nil
		}
	}

	var cellTitleTextColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		default: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		}
	}

	var cellTitleTextSelectedColor:UIColor {
		switch self {
		default: return self.cellTitleTextColor
		}
	}

	var cellDetailTitleTextColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		default: return UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)
		}
	}

	var cellDetailTitleTextSelectedColor:UIColor {
		switch self {
		default: return self.cellDetailTitleTextColor
		}
	}

	var tableViewCellCheckmarkColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Red.A200!
		case .Night: return MDColorPalette.Blue.A200!
		}
	}

	var cellTapFeedBackColor:UIColor {
		switch self {
		default: return self.textViewTapFeedbackColor
		}
	}

	var tableViewHeaderTextColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		default: return UIColor(hex: 0x000, alpha: MDDarkTextSecondaryAlpha)
		}
	}

	var tableViewFooterTextColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		default: return UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)
		}
	}

	var sliderMinTrackTintColor:UIColor? {
		switch self {
		case .Default: return MDColorPalette.Red.A100!
		case .Night: return MDColorPalette.Blue.A200!
		}
	}

	var sliderMaxTrackTintColor:UIColor? {
		switch self {
		default: return nil
		}
	}

	var sliderThumbTintColor:UIColor? {
		switch self {
		default: return self.sliderMinTrackTintColor
		}
	}

	var switchOnTintColor:UIColor? {
		switch self {
		default: return self.sliderMinTrackTintColor
		}
	}

	// Audio VC

	var audioPlotBackgroundColor:UIColor {
		switch self {
		default: return UIColor(hex: 0x000, alpha: 0.8)
		}
	}

	var audioPlotColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: 0.5)
		}
	}

	var audioPlotPitchFilteredColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: MDColorPalette.Blue.P500.hex, alpha: 0.8)
		case .Night: return UIColor(hex: MDColorPalette.Blue.A400!.hex, alpha: 0.8)
		}
	}

	var scrollViewBlurTintColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: 0.2)
		default: return UIColor(hex: 0x000, alpha: 0.2)
		}
	}

	var transValConfigViewPlusMinusButtonTintColorNormal:UIColor {
		switch self {
		case .Default: return self.roundButtonBackgroundColor!
		case .Night: return self.switchOnTintColor!
		}
	}

	var transValConfigViewNumPadDoneButtonBackgroundColor:UIColor {
		switch self {
		default: return MDColorPalette.Blue.A200!
		}
	}

	var transValConfigViewNumPadDoneButtonTextColorNormal:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var transValConfigViewNumPadDoneButtonTextColorHighlighted:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	var mdAlertControllerBackgroundColor:UIColor {
		switch self.style {
		default: return UIColor(hex: 0x000, alpha: 0.65)
		}
	}

	var mdAlertControllerAlertBackgroundColor:UIColor {
		switch self.style {
		case .Light: return UIColor.whiteColor()
		case .Dark: return MDColorPalette.Grey.P800
		}
	}

	var mdAlertControllerTitleTextColor:UIColor {
		switch self.style {
		case .Light: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		case .Dark: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var mdAlertControllerMessageTextColor:UIColor {
		switch self.style {
		case .Light: return UIColor(hex: 0x000, alpha: MDDarkTextSecondaryAlpha)
		case .Dark: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var mdAlertControllerButtonTextColorNormal:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.A200!
		case .Night: return MDColorPalette.Blue.A100!
		}
	}

	var mdAlertControllerButtonTextColorHighlighted:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.A100!
		case .Night: return MDColorPalette.Blue.A100!
		}
	}

	var mdAlertControllerButtonTapFeedbackColor:UIColor {
		switch self {
		default: return UIColor(hex: self.mdAlertControllerButtonTextColorNormal.hex, alpha: 0.3)
		}
	}

	// *****************************
	// MARK: Numbers
	// *****************************

	var cardViewHorizontalMargin:CGFloat {
		switch self {
		default: return isPhone ? 16 : 32
		}
	}

	var cardViewGroupVerticalMargin:CGFloat {
		switch self {
		default: return cardViewHorizontalMargin
		}
	}

	var cardViewGap:CGFloat {
		switch self {
		default: return isPhone ? 16 : 8
		}
	}

	var cardViewHeight:CGFloat {
		switch self {
		default: return 86
		}
	}

	var cardViewBorderWidth:CGFloat {
		switch self {
		default: return 0
		}
	}

	var cardViewCornerRadius:CGFloat {
		switch self {
		default: return 2
		}
	}

	var scrollViewBlurRadius:CGFloat {
		switch self {
		default: return 15
		}
	}

	var mdAlertControllerAlertCornerRadius:CGFloat {
		switch self {
		default: return self.cardViewCornerRadius
		}
	}

	// *****************************
	// MARK: Shadows
	// *****************************

	var cardViewMDShadowLevelDefault:Int {
		switch self {
		default: return 1
		}
	}

	var roundButtonMDShadowLevelDefault:Int {
		switch self {
		case .Night: return 0
		default: return 3
		}
	}

	var roundButtonMDShadowLevelTapped:Int {
		switch self {
		case .Night: return 0
		default: return 4
		}
	}

	// *****************************
	// MARK: Things Don't Really Change
	// *****************************

	var resetCellBackgroundColor:UIColor {
		switch self {
		default: return MDColorPalette.Red.P300
		}
	}

	var resetCellTapFeedbackColor:UIColor {
		switch self {
		default: return MDColorPalette.Red.P200
		}
	}

	var resetCellTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var transConfigHeaderLabelTextColor:UIColor {
		switch self {
		default: return self.tableViewHeaderTextColor
		}
	}

	var transConfigLabelTextColorEmphasized:UIColor {
		switch self {
		default: return self.cellTitleTextColor
		}
	}

	var transConfigLabelTextColorNormal:UIColor {
		switch self {
		default: return self.cellDetailTitleTextColor
		}
	}

	var transValConfigViewPlusMinusButtonTintColorHighlighted:UIColor {
		switch self {
		default: return UIColor(hex: self.transValConfigViewPlusMinusButtonTintColorNormal.hex, alpha: 0.5)
		}
	}
}