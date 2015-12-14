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

// NSUserDefaultKeys
let userDefaultsKeyTheme = "Theme"
let userDefaultsKeySwapButtonLayout = "Swap Button Layout"
let userDefaultsKeyNotFirstLaunch = "Not First Launch"
let userDefaultKeyInteractionSoundDisabled = "Interaction Sound Disabled"
let userDefaultKeyAnimationDurationScalar = "Animation Duration Scalar"

let TAP_FEED_BACK_DURATION:NSTimeInterval = 0.5

func getAttributedStringFrom(text:String?, withFontSize fontSize:CGFloat = UIFont.systemFontSize(), color:UIColor = UIColor.blackColor(), bold:Bool = false) -> NSMutableAttributedString? {
	return text == nil ? nil : NSMutableAttributedString(string: text!, attributes:
		[NSFontAttributeName: bold ? UIFont.boldSystemFontOfSize(fontSize) : UIFont.systemFontOfSize(fontSize),
			NSForegroundColorAttributeName: color])
}

enum Direction:Int {
	case Top = 1
	case Right = 2
	case Bottom = 3
	case Left = 4
}