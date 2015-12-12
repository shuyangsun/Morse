//
//  LocalizedStrings.swift
//  Morse
//
//  Created by Shuyang Sun on 12/11/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import Foundation


struct LocalizedStrings {
	struct Label {
		static let topBarTextLabel = NSLocalizedString("Text", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse (in English).")
		static let topBarMorseLabel = NSLocalizedString("Morse", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse (in English).")
	}

	struct Hint {
		static let textInputHint = NSLocalizedString("Touch to type", comment: "There is a string on the input text view on home screen, promoting user to touch the text box to start typing.")
	}
}
