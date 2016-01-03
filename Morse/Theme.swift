//
//  Theme.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

var theme:Theme {
	return appDelegate.theme
}

private let scrollViewOverlayAlpha:CGFloat = 0.45

enum Theme: String {
	case Default = "Default"

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
		}
	}

	var topBarBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P500
		}
	}

	var topBarLabelTextColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var cancelButtonColor:UIColor {
		switch self {
		case .Default: return UIColor.whiteColor()
		}
	}

	var textViewBackgroundColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}

	var textViewTapFeedbackColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P200
		}
	}

	var roundButtonBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Red.A200!
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
		default: return UIColor(hex: 0xEEEEEE)
		}
	}

	var scrollViewOverlayColor:UIColor {
		switch self {
		default: return UIColor(hex: 0x000, alpha: scrollViewOverlayAlpha)
		}
	}

	var cardViewBackgroudColor:UIColor {
		switch self {
		case .Default: return UIColor.whiteColor()
		}
	}

	var cardViewExpandedBackgroudColor:UIColor {
		switch self {
		default: return self.cardViewBackgroudColor
		}
	}

	var cardViewTapfeedbackColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P200
		}
	}

	var cardViewTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		}
	}

	var cardViewMorseColor:UIColor {
		switch self {
		case .Default: return UIColor(hex:0x000, alpha: MDDarkTextSecondaryAlpha)
		}
	}

	var cardBackViewBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P500
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
	var progressBarColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P300
		}
	}

	var percentageTextColor:UIColor {
		switch self {
		default: return self.topBarLabelTextColor
		}
	}

	var morseTextProgressBarColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	// Tab bar VC

	var tabBarBackgroundColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: 0xEEEEEE)
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

	var cellBackgroundColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}

	var cellSelectedBackgroundColor:UIColor {
		switch self {
		case .Default: return self.cellBackgroundColor
		}
	}

	var cellTitleTextColor:UIColor {
		switch self {
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
		default: return UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)
		}
	}

	var cellDetailTitleTextSelectedColor:UIColor {
		switch self {
		default: return self.cellDetailTitleTextColor
		}
	}

	var cellCheckmarkColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Red.A200!
		}
	}

	var cellTapFeedBackColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P200
		}
	}

	var sliderMinTrackTintColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Red.A100!
		}
	}

	var sliderMaxTrackTintColor:UIColor {
		switch self {
		default: return UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)
		}
	}

	var sliderThumbTintColor:UIColor {
		switch self {
		default: return self.sliderMinTrackTintColor
		}
	}

	var switchOnTintColor:UIColor {
		switch self {
		default: return self.sliderMinTrackTintColor
		}
	}

	var audioPlotBackgroundColor:UIColor {
		switch self {
		default: return UIColor.clearColor()
		}
	}

	var audioPlotColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: 0xFFFFFF, alpha: scrollViewOverlayAlpha)
		}
	}

	// *****************************
	// MARK: Length
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

	// *****************************
	// MARK: Shadows
	// *****************************

	var cardViewMDShadowLevelDefault:Int {
		switch self {
		default: return 1
		}
	}
}