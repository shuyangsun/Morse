//
//  MorseAudioRecorderDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 12/20/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import Foundation

@objc protocol MorseAudioRecorderDelegate {
	@objc optional func audioLevelUpdated(_ level:Float, avgPower:Float, peakPower:Float, recognized:Bool)
}
