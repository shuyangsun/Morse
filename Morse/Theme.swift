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
	case Blue = "Blue"
	case BlueGrey = "BlueGrey"

	var colorPalates:(primary:MDColorPalette, secondary:MDColorPalette) {
		switch self {
		case .Default: return (.Yellow, .BlueGrey)
		case .Blue: return (.Blue, .Pink)
		case .BlueGrey: return (.BlueGrey, .Pink)
		}
	}

	func primaryColor(withLevel level:ColorLevel) -> UIColor {
		switch level {
		case .Light: return self.colorPalates.primary.P50
		case .Medium: return self.colorPalates.primary.P300
		case .Dark: return self.colorPalates.primary.P500
		}
	}

	func secondaryColor(withLevel level:ColorLevel) -> UIColor {
		switch level {
		case .Light: return self.colorPalates.secondary.P50
		case .Medium: return self.colorPalates.secondary.P300
		case .Dark: return self.colorPalates.secondary.P500
		}
	}
}

enum ColorLevel {
	case Light
	case Medium
	case Dark
}