//
//  General UI.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

var appDelegate:AppDelegate {
	return UIApplication.sharedApplication().delegate as! AppDelegate
}

var isPad:Bool {
	return UI_USER_INTERFACE_IDIOM() == .Pad
}

var isPhone:Bool {
	return UI_USER_INTERFACE_IDIOM() == .Phone
}

var forceTouchAvailable:Bool {
	return UIView().traitCollection.forceTouchCapability == .Available
}

let prosignContainerLeft = "["
let prosignContainerRight = "]"

// WPM
let outputMinWPM = 5
let outputMaxWPM = 50
let defaultOutputWPM = 20
let defaultInputWPM = 20

let inputPitchMin:Float = 1
let inputPitchMax:Float = 2000

// Audio
let defaultSampleRate:Float = 44100.0
let fttWindowSize:vDSP_Length = 4096
let audioSampleFrequencyTimeInterval:NSTimeInterval = 0
let defaultInputPitch:Float = 550
let defaultOutputPitch:Float = 800
let automaticPitchMin:Float = 500
var defaultInputPitchErrorRange:Float = 7
var inputPitchRange:Range<Int> {
	let settingsPitch = appDelegate.inputPitch
	return max(Int(inputPitchMin), Int(ceil(settingsPitch - defaultInputPitchErrorRange)))...max(Int(inputPitchMin), Int(defaultInputPitchErrorRange * 2), Int(ceil(settingsPitch + defaultInputPitchErrorRange)))
}
let printAudiWaveFormWhenDebug = false

// NSUserDefaultKeys
let userDefaultsKeyTheme = "Theme"
let userDefaultsKeyExtraTextWhenShare = "Extra Text When Share"
let userDefaultsKeyProsignTranslationTypeRaw = "Prosign Translation Type Raw"
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

// Notification Names
let inputPitchDidChangeNotificationName = "Input Frequency Did Change Notification"

let notRecognizedLetterStr = "🙁"

func getAttributedStringFrom(text:String?, withFontSize fontSize:CGFloat = UIFont.systemFontSize(), color:UIColor = UIColor.blackColor(), bold:Bool = false) -> NSMutableAttributedString? {
	return text == nil ? nil : NSMutableAttributedString(string: text!, attributes:
		[NSFontAttributeName: bold ? UIFont.boldSystemFontOfSize(fontSize) : UIFont.systemFontOfSize(fontSize),
			NSForegroundColorAttributeName: color])
}

