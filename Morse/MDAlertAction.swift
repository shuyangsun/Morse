//
//  MDAlertAction.swift
//  Morse
//
//  Created by Shuyang Sun on 1/14/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import Foundation

class MDAlertAction {
	var title:String = ""
	var actionHandler:((MDAlertAction) -> Void)?
	var dismissAlertView = true

	init(title: String, dismissAlert:Bool = true, handler:((MDAlertAction) -> Void)? = nil) {
		self.title = title
		self.dismissAlertView = dismissAlert
		self.actionHandler = handler
	}
}