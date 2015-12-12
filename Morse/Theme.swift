//
//  Theme.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

enum Theme: String {
	case Default = "Default"

	// *****************************
	// MARK: Colors For UI
	// *****************************

	private var defaultTapFeedbackColorDark:UIColor {
		return UIColor(hex: 0x000000, alpha: 0.3)
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
		default: return self.defaultTapFeedbackColorDark
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

	var keyboardButtonViewBackgroundColor:UIColor {
		switch self {
		default: return self.textViewBackgroundColor
		}
	}

	var keyboardButtonViewTapFeedbackColor:UIColor {
		switch self {
		default: return self.textViewTapFeedbackColor
		}
	}

	var scrollViewBackgroundColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}

	var scrollViewOverlayColor:UIColor {
		switch self {
		default: return UIColor(hex: 0x000, alpha: 0.35)
		}
	}

	var cardViewBackgroudColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P400
		}
	}

	var cardViewExpandedBackgroudColor:UIColor {
		switch self {
		default: return self.cardViewBackgroudColor
		}
	}

	var cardViewTapfeedbackColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: 0.3)
		}
	}

	var cardViewTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var cardViewMorseColor:UIColor {
		switch self {
		default: return UIColor(hex:0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var tabBarBackgroundColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}
}