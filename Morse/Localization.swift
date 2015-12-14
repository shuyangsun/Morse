//
//  LocalizedStrings.swift
//  Morse
//
//  Created by Shuyang Sun on 12/11/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let supportedLanguages:[String: (original:String, localized:String)] = [
	"en": ("English", LocalizedStrings.Languages.english),
	"zh-Hans": ("简体中文", LocalizedStrings.Languages.chineseSimplified),
	"zh-Hant": ("正體中文", LocalizedStrings.Languages.chineseTraditional),
	"ar": ("العربية", LocalizedStrings.Languages.arabic)
]

var layoutDirection:UIUserInterfaceLayoutDirection {
	return UIView.userInterfaceLayoutDirectionForSemanticContentAttribute(.Unspecified)
}

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

	struct Settings {
		static let settings = NSLocalizedString("Settings", comment: "The title for settings page.")
		static let general = NSLocalizedString("General", comment: "There are categories on the settings page, this is one of the category.")
		static let ui = NSLocalizedString("User Interface", comment: "There are categories on the settings page, this is one of the category.")
		static let developer = NSLocalizedString("Developer", comment: "There are categories on the settings page, this is one of the category.")
		static let languages = NSLocalizedString("Languages", comment: "There are many sections on the settings page, this section let the user change the App's language.")
		static let switchLayoutDirection = NSLocalizedString("Switch Layout Direction", comment: "There are many sections on the settings page, this switch let the user change some of the UI's layout direction.")
		static let theme = NSLocalizedString("Color Theme", comment: "There are many sections on the settings page, this switch let the user change the color theme of this App.")
	}

	struct Languages {
		static let asia = NSLocalizedString("Asia", comment: "Users can change language in settings app, this is one of the language groups.")
		static let northAmerica = NSLocalizedString("North America", comment: "Users can change language in settings app, this is one of the language groups.")
		static let systemDefault = NSLocalizedString("System Default", comment: "Users can change language in settings app, this is one means the language is system default.")
		static let english = NSLocalizedString("English", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let chineseSimplified = NSLocalizedString("Chinese (Simplified)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let chineseTraditional = NSLocalizedString("Chinese (Traditional)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let arabic = NSLocalizedString("Arabic", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
	}
}

extension AppDelegate {
	var currentLocaleLanguageCode:String {
		return NSLocale.preferredLanguages().first!
	}

	func updateLocalWithIdentifier(languageCode:String) {
		var locale = self.userDefaults.objectForKey(userDefaultsKeyAppleLanguages) as! [String]
		if languageCode.isEmpty {
			// Restore to default
		} else {
			// If the new locale is not the current preferred locale:
			if locale.first! != languageCode {
				// Find the locale first.
				let ind = locale.indexOf(languageCode)
				if ind != nil {
					locale.removeAtIndex(ind!)
				}
				locale.insert(languageCode, atIndex: 0)
			}
			self.userDefaults.setObject(locale, forKey: userDefaultsKeyAppleLanguages)
		}
	}

	func resetLocaleToSystemDefault() {
		self.updateLocalWithIdentifier(appDelegate.firstLaunchSystemLanguageCode)
	}
}
