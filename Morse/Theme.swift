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

	var statusBarBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.BlueGrey.P700
		}
	}

	var topBarBackgroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.BlueGrey.P500
		}
	}

	var textViewBackgroundColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}

	var textViewTapFeedbackColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.BlueGrey.P200
		}
	}

	var roundButtonBackGroundColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Pink.P300
		}
	}

	var roundButtonTapFeedBackColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Pink.P500
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
		default: return MDColorPalette.BlueGrey.P500
		}
	}

	var cardViewTapfeedbackColor:UIColor {
		switch self {
		default: return MDColorPalette.BlueGrey.P300
		}
	}

	var tabBarBackgroundColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}
}