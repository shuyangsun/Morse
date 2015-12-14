//
//  LocalizedStrings.swift
//  Morse
//
//  Created by Shuyang Sun on 12/11/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let layoutDirection = UIView.userInterfaceLayoutDirectionForSemanticContentAttribute(.Unspecified)

struct LocalizedStrings {
	struct Label {
		static let topBarTextLabel = NSLocalizedString("Text", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse (in English).")
		static let topBarMorseLabel = NSLocalizedString("Morse", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse (in English).")
	}

	struct Hint {
		static let textInputHint = NSLocalizedString("Touch to type", comment: "There is a string on the input text view on home screen, promoting user to touch the text box to start typing.")
	}

	struct LaunchCard {
		static let text1 = NSLocalizedString("Welcome to Morse Transmitter!", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
		static let text2 = NSLocalizedString("Tap me to expand.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
		static let text3 = layoutDirection == .LeftToRight ? NSLocalizedString("Swipe to right to delete me.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.") : NSLocalizedString("Swipe to left to delete me.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
		static let text4 = layoutDirection == .LeftToRight ? NSLocalizedString("Swipe to left to output and share this Morse code.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.") : NSLocalizedString("Swipe to right to output and share this Morse code.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
	}
}
