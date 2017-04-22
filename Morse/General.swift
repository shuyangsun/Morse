//
//  General UI.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

var appDelegate:AppDelegate {
	return UIApplication.shared.delegate as! AppDelegate
}

var isPad:Bool {
	return UI_USER_INTERFACE_IDIOM() == .pad
}

var isPhone:Bool {
	return UI_USER_INTERFACE_IDIOM() == .phone
}

var forceTouchAvailable:Bool {
	return UIView().traitCollection.forceTouchCapability == .available
}

// At what level should the App switch to "Night" theme if "Auto Night Mode" is on.
let defaultAutoNightModeThreshold:Float = 0.2
// How often should the App check screen's brightness level to decide if should switch to "Night" theme.
let defaultAutoNightModeUpdateTimeInterval:TimeInterval = 5
let defaultbannerStatusUpdateTimeInterval:TimeInterval = 1

let prosignContainerLeft = "["
let prosignContainerRight = "]"

// WPM
let outputMinWPM = 5
let outputMaxWPM = 50
let defaultOutputWPM = 20
let defaultInputWPM = 20

let supportedAudioDecoderWPMRange = 14...22
let supportedAudioDecoderPitchRange = 150...5000
let supportedOutputWPMRange = 5...50
let supportedOutputPitchRange = supportedAudioDecoderPitchRange

let inputPitchMin:Float = 1
let inputPitchMax:Float = 2000

// Audio
let defaultSampleRate:Float = 44100.0
let fttWindowSize:vDSP_Length = 4096
let audioSampleFrequencyTimeInterval:TimeInterval = 0
let defaultInputPitch:Float = 800
let defaultOutputPitch:Float = 800
let automaticPitchMin:Float = 500
var defaultInputPitchErrorRange:Float = 7
var inputPitchRange:CountableRange<Int> {
	let settingsPitch = appDelegate.inputPitch
	return max(Int(inputPitchMin), Int(ceil(settingsPitch - defaultInputPitchErrorRange)))...max(Int(inputPitchMin), Int(defaultInputPitchErrorRange * 2), Int(ceil(settingsPitch + defaultInputPitchErrorRange)))
}
let printAudiWaveFormWhenDebug = false

// NSUserDefaultKeys
let userDefaultsKeyTheme = "Theme"
let userDefaultsKeyAdsRemoved = "Ads Removed"
let userDefaultsKeyIsAbleToTurnOffPromotionalTextWhenShare = "Is Able To Turn Off Promotional Text When Share"
let userDefaultsKeyUserSelectedTheme = "Theme User Selected"
let userDefaultsKeyExtraTextWhenShare = "Extra Text When Share"
let userDefaultsKeyProsignTranslationType = "Prosign Translation Type"
let userDefaultsKeyNotFirstLaunch = "Not First Launch"
let userDefaultsKeyInteractionSoundDisabled = "Interaction Sound Disabled"
let userDefaultsKeyAnimationDurationScalar = "Animation Duration Scalar"
let userDefaultsKeyAppleLanguages = "AppleLanguages"
let userDefaultsKeyFirstLaunchLanguageCode = "First Launch Language Code"
let userDefaultsKeySoundOutputEnabled = "Sound Output Enableds"
let userDefaultsKeyFlashOutputEnabled = "Flash Output Enableds"
let userDefaultsKeyInputWPM = "Input WPM"
let userDefaultsKeyInputWPMAutomatic = "Input WPM Automatic"
let userDefaultsKeyOutputWPM = "Output WPM"
let userDefaultsKeyBrightenScreenWhenOutput = "Brighten Screen When Output"
let userDefaultsKeyInputPitch = "Input Pitch"
let userDefaultsKeyInputPitchAutomatic = "Input Pitch Not Automatic"
let userDefaultsKeyOutputPitch = "Output Pitch"
let userDefaultsKeyAutoCorrectMisSpelledWordsForAudioInput = "Auto Correct Mis-Spelled Words For Audio Input"
let userDefaultsKeyAutoNightMode = "Auto Night Mode"
let userDefaultsKeyAutoNightModeThreshold = "Auto Night Mode Threshold"
let userDefaultsKeyShowRestarAlert = "Show Restart Alert"
let userDefaultsKeyShowAddedTutorialCardsAlert = "Show Added Tutorial Cards Alert"
let userDefaultsKeyShowAppStoreRatingPrompt = "Show App Store RatingPrompt"
let userDefaultsKeyLastRatedVersion = "Last Rated Version"
let userDefaultsKeyAppLaunchCount = "App Launch Count"

// Notification Names
let inputPitchDidChangeNotificationName = "Input Frequency Did Change Notification"
let inputWPMDidChangeNotificationName = "Input WPM Did Change Notification"
let themeDidChangeNotificationName = "Theme Did Change Notification"
let languageDidChangeNotificationName = "Language Did Change Notification"
let adsShouldDisplayDidChangeNotificationName = "Ads Should Display Did Change Notification"

let notRecognizedLetterStr = "🙁"

// Feedback Email
let feedbackEmailToRecipient = "MorseTransmitter@gmail.com"
let feedbackEmailMessageBody = ""

// App Store related
let appID = "1079473715"
let appStoreLink = "itms-apps://itunes.apple.com/app/id\(appID)"
let appStoreReviewLink = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
let privacyPolicyLink = "https://www.iubenda.com/privacy-policy/7785904"
let appStoreRatingPromptFrequency = (firstTime:2, repeatStride:6)

func getAttributedStringFrom(_ text:String?, withFontSize fontSize:CGFloat = UIFont.systemFontSize, color:UIColor = UIColor.black, bold:Bool = false) -> NSMutableAttributedString? {
	return text == nil ? nil : NSMutableAttributedString(string: text!, attributes:
		[NSFontAttributeName: bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize),
			NSForegroundColorAttributeName: color])
}

extension UIImage {
	func imageWithTintColor(_ color:UIColor) -> UIImage! {
		let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		 UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
		let context = UIGraphicsGetCurrentContext()
		self.draw(in: rect)
		context.setFillColor(color.cgColor)
		context.setBlendMode(.sourceAtop)
		context.fill(rect)
		let res = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return res
	}
}

//-------------------------------- GCD Wrapper --------------------------------
enum DispatchFuncType { case async, sync }
enum DispatchQueueType { case concurrent, serial }
enum DispatchPriority { case high, `default`, low, background }

/**
 A wrapper function to call GCD functions, to make the code more readable.
	- parameters:
		- type: Type of dispatch function to call. Async or Sync, default is Async.
		- queueType: Type of queue to create. Concurrent or Serial, default is Serial.
		- priority: Priority of concurrent queue. High, Default, Low, or Background. By default it's set to "Default" priority. If the queueType is Serial, this parameter will be ignored.
		- label: Label for serial queue. If the queueType is Concurrent, this parameter will be ignored. By default this is an empty string.
		- block: Task block to submit. This cannot be nil.
 */
func dispatch(_ type:DispatchFuncType = .async,
              queueType:DispatchQueueType = .concurrent,
              priority:DispatchPriority = .default,
              label:String = "",
              block:((Void)->Void))
{
	let queue:DispatchQueue
	if queueType == .serial {
		queue = DispatchQueue(label: label, attributes: [])
	} else {
		let identifier:dispatch_queue_priority_t
		switch priority {
		case .high: identifier = DispatchQueue.GlobalQueuePriority.high
		case .default: identifier = DispatchQueue.GlobalQueuePriority.default
		case .low: identifier = DispatchQueue.GlobalQueuePriority.low
		case .background: identifier = DispatchQueue.GlobalQueuePriority.background
		}
		queue = DispatchQueue.global(priority: identifier)
	}
	if type == .async {
		queue.async(execute: block)
	} else if type == .sync {
		queue.sync(execute: block)
	}
}

