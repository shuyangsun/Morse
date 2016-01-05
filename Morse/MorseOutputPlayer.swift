//
//  MorseOutputPlayer.swift
//  Morse
//
//  Created by Shuyang Sun on 12/18/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

//--------------------------------------------------------------------------------------------------------
// This class is responsible for playing a Morse code. How it "plays" it depends on the callback function.
// TimeInterval scalar is automatically fetched and calculated from userDefaults.outputWPM
// The only things need to be set is Morse code (during initialization), and delegate.
// Delegate is a MorseOutputPlayerDelegate, which implements 3 functions: startSignal(), stopSignal(), playEnded()
//--------------------------------------------------------------------------------------------------------

class MorseOutputPlayer: NSObject {
	// *****************************
	// MARK: Public Variables
	// *****************************
	var morse:String = "" {
		willSet {
			self._transmitter.morse = newValue
			if let res = self._transmitter.getTimeStamp(withScalar: self._timeStampScalar) {
				self._timeStamp = res
			}
		}
	}
	var delegate:MorseOutputPlayerDelegate?
	var duration:NSTimeInterval {
		return self._timeStamp.isEmpty ? 0 : self._timeStamp.last!
	}

	// *****************************
	// MARK: Calculated Variables
	// *****************************
	private var _timeStampScalar:Float {
		return 60.0/Float(appDelegate.outputWPM * MorseTransmitter.standardWordLength)
	}

	// *****************************
	// MARK: Private Variables
	// *****************************
	private let _transmitter = MorseTransmitter()
	private var _timeStamp:[NSTimeInterval] = []
	private var _timers:Set<NSTimer> = Set()

	// *****************************
	// MARK: Initializers
	// *****************************
	override init() {
		super.init()
		self.morse = ""
	}

	// *****************************
	// MARK: Public Functions
	// *****************************

	func start() {
		if let timers = self.createTimers(fromTimeStamp: self._timeStamp) {
			self._timers = timers
		}
	}

	func stop() {
		self.stopSignal()
		let _ = self._timers.map { $0.invalidate() }
//		NSObject.cancelPreviousPerformRequestsWithTarget(self) // FIXME: BUG, not working. Invalidate timers one by one can result in performance issue.
		self._timers = []
	}

	func startSignal() {
		self.delegate?.startSignal()
	}

	func stopSignal() {
		self.delegate?.stopSignal()
	}

	func playEnded() {
		self.delegate?.playEnded()
	}

	// *****************************
	// MARK: Private Functions
	// *****************************

	private func createTimers(fromTimeStamp timeStamp:[NSTimeInterval]) -> Set<NSTimer>? {
		if timeStamp.count <= 1 || timeStamp.count % 2 == 1 {
			return nil
		}

		var res:Set<NSTimer> = Set()
		for var i = 0; i < timeStamp.count - 1; i += 2 {
			let onTimer = NSTimer.scheduledTimerWithTimeInterval(timeStamp[i], target: self, selector: "startSignal", userInfo: nil, repeats: false)
			let offTimer = NSTimer.scheduledTimerWithTimeInterval(timeStamp[i + 1], target: self, selector: "stopSignal", userInfo: nil, repeats: false)

			res.insert(onTimer)
			res.insert(offTimer)
		}
		let endTimer = NSTimer.scheduledTimerWithTimeInterval(timeStamp.last!, target: self, selector: "playEnded", userInfo: nil, repeats: false)
		res.insert(endTimer)
		return res
	}
}