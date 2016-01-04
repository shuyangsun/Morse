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
	struct General {
		static let sharePromote = NSLocalizedString("Check this out! I converted text to this Morse code using Morse Transmitter! Download here:", comment: "When the user shares Morse code, this is the prefix string attached to it, followed by App Store URL.")
	}

	struct Label {
		static let topBarTextLabel = NSLocalizedString("Text", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse.")
		static let topBarMorseLabel = NSLocalizedString("Morse", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse.")
		static let topBarMorseDictionary = NSLocalizedString("Dictionary", comment: "This is a label on top of the dictionary page, which is a page where you can lookup all Morse characters and representations.")
	}

	struct Hint {
		static let textInputHint = NSLocalizedString("Touch to type", comment: "There is a string on the input text view on home screen, promoting user to touch the text box to start typing.")
	}

	struct LaunchCard {
		static let text1 = NSLocalizedString("Welcome to Morse Transmitter!", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
		static let text2 = NSLocalizedString("Tap me to output or share.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
		static let text3 = NSLocalizedString("Hold me to expand.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
		static let text4 = NSLocalizedString("Swipe to delete me.", comment: "When user launches the app for the first time, there are tutorial cards on the home screen. This is one of the text that will be on the screen.")
	}

	struct Settings {
		static let settings = NSLocalizedString("Settings", comment: "The title for settings page.")
		static let general = NSLocalizedString("General", comment: "There are categories on the settings page, this is one of the category.")
		static let ui = NSLocalizedString("User Interface", comment: "There are categories on the settings page, this is one of the category.")
		static let about = NSLocalizedString("About", comment: "There are categories on the settings page, this is one of the category.")
		static let developerOptions = NSLocalizedString("Developer Options", comment: "There are categories on the settings page, this is one of the category.")
		static let languages = NSLocalizedString("Language", comment: "There are many sections on the settings page, this section let the user change the App's language.")
		static let extraTextWhenShare = NSLocalizedString("Greeting Text", comment: "There are many sections on the settings page, this switch let the user choose if they want to copy the download link and promotional text when they copy Morse code.")
		static let brightenUpDisplayWhenOutput = NSLocalizedString("Output Brighten Screen", comment: "There are many sections on the settings page, this switch let the user choose if they want to make the screen brighter when outputing Morse code.")
		static let theme = NSLocalizedString("Theme", comment: "There are many sections on the settings page, this switch let the user change the color theme of this App.")
		static let automatic = NSLocalizedString("Automatic", comment: "A setting that indicates something is done automatically.")
		static let outputWPM = NSLocalizedString("Output WPM (Word Per Minute)", comment: "There are many sections on the settings page, this one changes the output WPM.")
		static let inputPitch = NSLocalizedString("Input Pitch (Audio Frequency)", comment: "There are many sections on the settings page, this one changes the frequency should be detected for input audio.")
	}

	struct Languages {
		static let defaultGroup = NSLocalizedString("Default", comment: "Users can change language in settings app, this is one of the language groups.")
		static let asia = NSLocalizedString("Asia", comment: "Users can change language in settings app, this is one of the language groups.")
		static let northAmerica = NSLocalizedString("North America", comment: "Users can change language in settings app, this is one of the language groups.")
		static let systemDefault = NSLocalizedString("System Default", comment: "Users can change language in settings app, this is one means the language is system default.")
		static let english = NSLocalizedString("English", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let chineseSimplified = NSLocalizedString("Chinese (Simplified)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let chineseTraditional = NSLocalizedString("Chinese (Traditional)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let arabic = NSLocalizedString("Arabic", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
	}

	struct Button {
		static let output = NSLocalizedString("Output", comment: "One of the buttons on the back of card view, it alows user to output Morse code with flash or speaker.")
		static let share = NSLocalizedString("Share", comment: "One of the buttons on the back of card view, it alows user to share Morse code.")
		static let done = NSLocalizedString("Done", comment: "Button to tap when the user is done with an action.")
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
			self.userDefaults.synchronize()
		}
	}

	func resetLocaleToSystemDefault() {
		self.updateLocalWithIdentifier(appDelegate.firstLaunchSystemLanguageCode)
	}
}
