//
//  MorseOutputPlayerDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 12/18/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import Foundation

protocol MorseOutputPlayerDelegate {
	func startSignal()
	func stopSignal()
	func playEnded()
}