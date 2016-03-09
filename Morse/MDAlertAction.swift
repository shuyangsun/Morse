//
//  MDAlertAction.swift
//  Morse
//
//  Created by Shuyang Sun on 1/14/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import Foundation

// -------------------------------------------------------------------------------------------------------------------------------------
/** A MDAlertAction helps creating an MDAlertController. An action is basically a button on the alert view controller. */
class MDAlertAction {
	/** Name of the button. */
	var title:String = ""
	/** What happens when the user taps the button. */
	var actionHandler:((MDAlertAction) -> Void)?
	/** Wheather to dismiss the associated alert view controller after user taps the button. */
	var dismissAlertView = true

	/**
	Initialize a MDAlertAction
	- Parameters:
		- title: Name of the button.
		- actionHandler: What happens when the user taps the button.
		- dismissAlertView (default=true): Wheather to dismiss the associated alert view controller after user taps the button.
	*/
	init(title: String, dismissAlert:Bool = true, handler:((MDAlertAction) -> Void)? = nil) {
		self.title = title
		self.dismissAlertView = dismissAlert
		self.actionHandler = handler
	}
}
// -------------------------------------------------------------------------------------------------------------------------------------