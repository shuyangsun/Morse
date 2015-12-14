//
//  General UI.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

let TAP_FEED_BACK_DURATION:NSTimeInterval = 0.5

let tableViewCellHeight:CGFloat = 50

var statusBarHeight:CGFloat {
	return UIApplication.sharedApplication().statusBarFrame.size.height
}

enum Direction:Int {
	case Top = 1
	case Right = 2
	case Bottom = 3
	case Left = 4
}

