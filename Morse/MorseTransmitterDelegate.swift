//
//  MorseTransmitterDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 1/2/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import Foundation

@objc protocol MorseTransmitterDelegate {
	optional func transmitterContentDidChange(_ text:String, morse:String)
}
