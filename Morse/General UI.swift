//
//  General UI.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let TAP_FEED_BACK_DURATION:NSTimeInterval = 0.5

func getAttributedStringFrom(text:String?, withFontSize fontSize:CGFloat = UIFont.systemFontSize(), color:UIColor = UIColor.blackColor()) -> NSMutableAttributedString? {
	return text == nil ? nil : NSMutableAttributedString(string: text!, attributes:
		[NSFontAttributeName: UIFont.systemFontOfSize(fontSize),
			NSForegroundColorAttributeName: color])
}