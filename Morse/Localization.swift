//
//  LocalizedStrings.swift
//  Morse
//
//  Created by Shuyang Sun on 12/11/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let supportedLanguages:[String: (original:String, localized:String)] = [
	// Asia
	"ar": ("العربية", LocalizedStrings.Languages.arabic),
	"zh-Hans": ("简体中文", LocalizedStrings.Languages.chineseSimplified),
	"zh-Hant": ("正體中文", LocalizedStrings.Languages.chineseTraditional),
	// Europe
	"en-GB": ("English (U.K.)", LocalizedStrings.Languages.englishUK),
	// NA
	"en-US": ("English (U.S.)", LocalizedStrings.Languages.englishUS),
	"es": ("Español", LocalizedStrings.Languages.spanish)
]

// This is for auto correction when using Auido as Morse code input. Languages in this list will be auto-corrected with localized UITextChecker, languages are not in this list will be considered as English by default.
let canBeSpellCheckedLanguageCodes:Set<String> = ["en", "es"]
let defaultSpellCheckLanguageCode = "en"

var layoutDirection:UIUserInterfaceLayoutDirection {
	return UIView.userInterfaceLayoutDirectionForSemanticContentAttribute(.Unspecified) == .LeftToRight ? .LeftToRight : .RightToLeft
}

struct LocalizedStrings {
	struct General {
		static let sharePromote = NSLocalizedString("Check this out! I converted text to this Morse code using Morse Transmitter! Download here:", comment: "When the user shares Morse code, this is the prefix string attached to it, followed by App Store URL.")
	}

	struct FeedbackEmail {
		static let subject = NSLocalizedString("Morse Transmitter Feedback", comment: "The subject title for feedback email.")
	}

	struct Prosign {
		static let wait = NSLocalizedString("WAIT", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: wait.")
		static let backToYou = NSLocalizedString("BACK-TO-YOU", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: I'm done, now back to you.")
		static let closing = NSLocalizedString("CLOSING", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: this station is closing.")
		static let attention = NSLocalizedString("!ATTENTION!", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: attention!")
		static let error = NSLocalizedString("ERROR", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: there was an error.")
		static let inviteToTransmitAnyStation = NSLocalizedString("INVITE-ANY-STATION-TO-TRANSMIT", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: any station can start to transmit now.")
		static let inviteToTransmitNamedStation = NSLocalizedString("INVITE-NAMED-STATION-TO-TRANSMIT", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: the named station can start to transmit now.")
		static let shiftToWabunCode = NSLocalizedString("SHIFT-TO-WABUN-CODE", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: shift from Morse code to Wabun code. (Wabun code is used by Japanese)")
		static let endOfContact = NSLocalizedString("END-OF-CONTACT", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: this is the end of contact.")
		static let understood = NSLocalizedString("UNDERSTOOD", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: understood.")
		static let emergency = NSLocalizedString("!!!EMERGENCY!!!", comment: "One of the Morse code prosign language, please make it concise and significant (e.g. capitalize, add dashes if appropriate). This one means: emergency! (the SOS signal)")

		static let titleNewLine = NSLocalizedString("New Line", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleNewPage = NSLocalizedString("New Page", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleWait = NSLocalizedString("Wait", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleBreak = NSLocalizedString("Break", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleNewParagraph = NSLocalizedString("New Paragraph", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleClosing = NSLocalizedString("Closing", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleAttention = NSLocalizedString("Attention", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleError = NSLocalizedString("Error", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleInviteToTransmitAnyStation = NSLocalizedString("Invite (Any)", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleInviteToTransmitNamedStation = NSLocalizedString("Invite (Named)", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleShiftToWabun = NSLocalizedString("Shift to Wabun", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleEndOfContact = NSLocalizedString("End of Contact", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleUnderstood = NSLocalizedString("Understood", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titleEmergency = NSLocalizedString("Emergency", comment: "There are many prosign code in Morse, this is the name of one of them.")
		static let titlesAndMorse = [
			(titleNewLine, "• — • —"),
			(titleNewPage, "• — • — •"),
			(titleWait, "• — • • •"),
			(titleBreak, "— • • • — • —"),
			(titleNewParagraph, "— • • • —"),
			(titleClosing, "— • — • • — • •"),
			(titleAttention, "— • — • —"),
			(titleError, "• • • • • • •"),
			(titleInviteToTransmitAnyStation, "— • —"),
			(titleInviteToTransmitNamedStation, "— • — — •"),
			(titleShiftToWabun, "— • • — — —"),
			(titleEndOfContact, "• • • — • —"),
			(titleUnderstood, "• • • — •"),
			(titleEmergency, "• • • — — — • • •")
		]
	}

	struct Label {
		static let topBarTextLabel = NSLocalizedString("Text", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse.")
		static let topBarMorseLabel = NSLocalizedString("Morse", comment: "On top of the home screen, there are two labels indicating the translate direction. One is Text, the other is Morse.")
		static let topBarMorseDictionary = NSLocalizedString("Dictionary", comment: "This is a label on top of the dictionary page, which is a page where you can lookup all Morse characters and representations.")
		static let wpmWithColon = NSLocalizedString("WPM: ", comment: "This is a label on the output page, followed by the numer of WPM (word per minute).")
		static let pitchWithColon = NSLocalizedString("Pitch: ", comment: "This is a label on the output page, followed by the numer of audio frequency (pitch).")
		static let tutorialOutputVC1 = NSLocalizedString("Adjust in Settings", comment: "This is a label on the output page, tells the user how to change some of the values.")
		static let tutorialWaveformVC1 = NSLocalizedString("Supported WPM: ", comment: "This is a label on the output page, tells the user the range of supported WPM.")
		static let tapToStart = NSLocalizedString("Tap anywhere to play or pause", comment: "This is a label on the output page, tells user how to play or pause the output.")
		static let tapToFinish = NSLocalizedString("Tap anywhere to finish", comment: "This is a label on the output page, tells user how to finish using audio input.")
		static let swipeToDismiss = NSLocalizedString("Swipe down or pinch to go back", comment: "This is a label on the output page, tells user how to go back to home page.")
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
		static let ui = NSLocalizedString("Appearance", comment: "There are categories on the settings page, this is one of the category.")
		static let transmitterConfiguration = NSLocalizedString("Transmitter Configuration", comment: "There are categories on the settings page, this is one of the category.")
		static let upgrades = NSLocalizedString("Upgrades", comment: "There are categories on the settings page, this is one of the category.")
		static let about = NSLocalizedString("About", comment: "There are categories on the settings page, this is one of the category.")
		static let developerOptions = NSLocalizedString("Developer Options", comment: "There are categories on the settings page, this is one of the category.")
		static let languages = NSLocalizedString("Language", comment: "There are many sections on the settings page, this section let the user change the App's language.")
		static let extraTextWhenShare = NSLocalizedString("Share Signature", comment: "There are many sections on the settings page, this switch let the user choose if they want to copy the download link and promotional text when they copy Morse code.")
		static let brightenUpDisplayWhenOutput = NSLocalizedString("Output Brighten Screen", comment: "There are many sections on the settings page, this switch let the user choose if they want to make the screen brighter when outputing Morse code.")
		static let theme = NSLocalizedString("Theme", comment: "There are many sections on the settings page, this switch let the user change the color theme of this App.")
		static let autoNightMode = NSLocalizedString("Switch Automatically", comment: "There are many sections on the settings page, this switch let the user toggle if the app should change to Night theme when the ambient censor detects the surrounding light is low.")
		static let decodeProsign = NSLocalizedString("Decode Prosign", comment: "There are many sections on the settings page, this switch let the user toggle if the app should decode prosign for Morse code.")
		static let audioDecoder = NSLocalizedString("Audio Decoder", comment: "This button on the settings page brings up input configuration page.")
		static let output = NSLocalizedString("Signal Output", comment: "This button on the settings page brings up output configuration page.")
		static let nightModeDescription = NSLocalizedString("When the ambient light is low with Switch Automatically turned on, the app will automatically switch to Night theme.", comment: "There are many sections on the settings page, this one explains what does Auto Switch button in Appearance section do.")
		static let upgradesDescription = NSLocalizedString("Any purchase will remove all ads.", comment: "There are many sections on the settings page, this one explains that any purchase the user makes will remove advertising in the app.")
		static let outputBrightenScreenDescription = NSLocalizedString("When you have it on, the screen will temporarily become brighter while you send Morse signal, so you can use it as a light source.", comment: "Explains what Output Brighten Screen does.")
		static let autoCorrectWordDescription = NSLocalizedString("When you have it on, the App will try to auto-correct mis-spelled words when decoding Morse code. The dictionary changes when you change your language setting.", comment: "Explains what Auto Correct Mis Spelled Words does.")
		static let purchaseUnlockAllThemes = NSLocalizedString("Unlock All Themes", comment: "A button on the settings page for user make in-app purchase to unlock all the thems.")
		static let purchaseEnableAudioDecoder = NSLocalizedString("Enable Audio Decoder", comment: "A button on the settings page for user make in-app purchase to enable Morse audio decoder.")
		static let purchaseRestorePurchases = NSLocalizedString("Restore Purchases", comment: "A button on the settings page for user to restore their previous purchases.")
		static let rateOnAppStore =  NSLocalizedString("Rate on App Store", comment: "A button on the settings page for user to rate on App Store.")
		static let contactDeveloper = NSLocalizedString("Contact Developer", comment: "A button on the settings page to contact developer. (send developer an email)")
		static let reset = NSLocalizedString("Reset", comment: "A button on the settings page to reset some content.")
		static let wpm = NSLocalizedString("WPM (Words Per Minute)", comment: "Settings category: word per minute.")
		static let pitch = NSLocalizedString("Pitch", comment: "Settings category: audio frequency.")
		static let audioDecoderAutoCorrect = NSLocalizedString("Auto Correct Words", comment: "A settings that allows user to choose if they want to use auto correction on audio decoder.")
		static let done = NSLocalizedString("Done", comment: "A Done button.")
		static let automaticAudioDecoderValue = NSLocalizedString("Automatic", comment: "Name of a switch button (audio decoder automatically get wpm and pitch information).")
	}

	struct ThemeName {
		static let defaultName = NSLocalizedString("Default", comment: "Means something's default.")
		static let night = NSLocalizedString("Night", comment: "One of the names for color theme.")
		static let forest = NSLocalizedString("Forest", comment: "One of the names for color theme.")
	}

	struct Languages {
		static let restartReminderFooter = NSLocalizedString("Please restart this App after changing language.", comment: "This is a footer on the first section in language change settings, to reminder user restart the App after changing language.")
		static let defaultGroup = NSLocalizedString("Default", comment: "Users can change language in settings app, this is one of the language groups.")
		static let asia = NSLocalizedString("Asia", comment: "Users can change language in settings app, this is one of the language groups.")
		static let europe = NSLocalizedString("Europe", comment: "Users can change language in settings app, this is one of the language groups.")
		static let northAmerica = NSLocalizedString("North America", comment: "Users can change language in settings app, this is one of the language groups.")
		static let systemDefault = NSLocalizedString("System Default", comment: "Users can change language in settings app, this is one means the language is system default.")
		static let englishUS = NSLocalizedString("English (United States)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let englishUK = NSLocalizedString("English (United Kingdom)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let spanish = NSLocalizedString("Spanish", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let chineseSimplified = NSLocalizedString("Chinese (Simplified)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let chineseTraditional = NSLocalizedString("Chinese (Traditional)", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
		static let arabic = NSLocalizedString("Arabic", comment: "Users can change language in settings app, this is one of the language name that will show in user's prefered language.")
	}

	struct Button {
		static let done = NSLocalizedString("Done", comment: "Button to tap when the user is done with an action.")
	}

	struct Alert {
		static let buttonOK = NSLocalizedString("OK", comment: "One of the buttons on the Alert view.")
		static let buttonCancel = NSLocalizedString("Cancel", comment: "One of the buttons on the Alert view.")
		static let buttonDonnotShowAgain = NSLocalizedString("Don't Show Again", comment: "One of the buttons on the Alert view.")
		static let buttonGotIt = NSLocalizedString("Got It", comment: "One of the buttons on the Alert view.")

		static let titleRestartApp = NSLocalizedString("Please Restart", comment: "One of the titles on the Alert view.")
		static let messageRestartApp = NSLocalizedString("To make new language setting take effect, please restart application with following steps:\n\n1. Double-tap Home button on your device.\n\n2. Swipe up to terminate application in the background.\n\n3. Start application from home screen.", comment: "One of the titles on the Alert view.")
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

		NSNotificationCenter.defaultCenter().postNotificationName(languageDidChangeNotificationName, object: nil)
	}

	func resetLocaleToSystemDefault() {
		self.updateLocalWithIdentifier(appDelegate.firstLaunchSystemLanguageCode)
	}
}
