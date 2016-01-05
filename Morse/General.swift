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

// WPM
let outputMinWPM = 5
let outputMaxWPM = 50

let inputPitchMin:Float = 1
let inputPitchMax:Float = 2000

// Audio
let defaultSampleRate:Float = 44100.0
let fttWindowSize:vDSP_Length = 4096
let audioSampleFrequencyTimeInterval:NSTimeInterval = 0
let defaultInputPitchFrequency:Float = 550
let defaultOutputPitchFrequency:Float = 750
let automaticPitchFrequencyMin:Float = 300
let defaultInputPitchRange:Float = 10
var inputPitchFrequencyRange:Range<Int> {
	let settingsPitch = appDelegate.inputPitchFrequency
	return max(Int(inputPitchMin), Int(ceil(settingsPitch - defaultInputPitchRange)))...max(Int(inputPitchMin), Int(defaultInputPitchRange * 2), Int(ceil(settingsPitch + defaultInputPitchRange)))
}
let printAudiWaveFormWhenDebug = false

// NSUserDefaultKeys
let userDefaultsKeyTheme = "Theme"
let userDefaultsKeyExtraTextWhenShare = "Extra Text When Share"
let userDefaultsKeyNotFirstLaunch = "Not First Launch"
let userDefaultsKeyInteractionSoundDisabled = "Interaction Sound Disabled"
let userDefaultsKeyAnimationDurationScalar = "Animation Duration Scalar"
let userDefaultsKeyAppleLanguages = "AppleLanguages"
let userDefaultsKeyFirstLaunchLanguageCode = "First Launch Language Code"
let userDefaultsKeySoundOutputEnabled = "Sound Output Enableds"
let userDefaultsKeyFlashOutputEnabled = "Flash Output Enableds"
let userDefaultsKeyInputWPM = "Input WPM"
let userDefaultsKeyOutputWPM = "Output WPM"
let userDefaultsKeyBrightenScreenWhenOutput = "Brighten Screen When Output"
let userDefaultsKeyInputPitchFrequency = "Input Pitch Frequency"
let userDefaultsKeyInputPitchAutomatic = "Input Pitch Not Automatic"

// Notification Names
let inputPitchFrequencyDidChangeNotificationName = "Input Frequency Did Change Notification"

let notRecognizedLetterStr = "🙁"

func getAttributedStringFrom(text:String?, withFontSize fontSize:CGFloat = UIFont.systemFontSize(), color:UIColor = UIColor.blackColor(), bold:Bool = false) -> NSMutableAttributedString? {
	return text == nil ? nil : NSMutableAttributedString(string: text!, attributes:
		[NSFontAttributeName: bold ? UIFont.boldSystemFontOfSize(fontSize) : UIFont.systemFontOfSize(fontSize),
			NSForegroundColorAttributeName: color])
}

