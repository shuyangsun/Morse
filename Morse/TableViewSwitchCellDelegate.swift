//
//  TableViewSwitchCellDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 1/10/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import Foundation

@objc protocol TableViewSwitchCellDelegate {
	@objc optional func switchToggled(_ switchButton:UISwitch)
}
