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
	var duration:TimeInterval {
		return self._timeStamp.isEmpty ? 0 : self._timeStamp.last!
	}

	// *****************************
	// MARK: Calculated Variables
	// *****************************
	fileprivate var _timeStampScalar:Float {
		return 60.0/Float(appDelegate.outputWPM * MorseTransmitter.standardWordLength)
	}

	// *****************************
	// MARK: Private Variables
	// *****************************
	fileprivate let _transmitter = MorseTransmitter()
	fileprivate var _timeStamp:[TimeInterval] = []
	fileprivate var _timers:Set<Timer> = Set()

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
		DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async {
			let _ = self._timers.map { $0.invalidate() }
			//		NSObject.cancelPreviousPerformRequestsWithTarget(self) // FIXME: BUG, not working. Invalidate timers one by one can result in performance issue.
			self._timers = []
		}
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

	fileprivate func createTimers(fromTimeStamp timeStamp:[TimeInterval]) -> Set<Timer>? {
		if timeStamp.count <= 1 || timeStamp.count % 2 == 1 {
			return nil
		}

		var res:Set<Timer> = Set()
		for i in 0..<timeStamp.count where i % 2 == 0{
			let onTimer = Timer.scheduledTimer(timeInterval: timeStamp[i], target: self, selector: #selector(MorseOutputPlayer.startSignal), userInfo: nil, repeats: false)
			let offTimer = Timer.scheduledTimer(timeInterval: timeStamp[i + 1], target: self, selector: #selector(MorseOutputPlayer.stopSignal), userInfo: nil, repeats: false)

			res.insert(onTimer)
			res.insert(offTimer)
		}
		let endTimer = Timer.scheduledTimer(timeInterval: timeStamp.last!, target: self, selector: #selector(MorseOutputPlayer.playEnded), userInfo: nil, repeats: false)
		res.insert(endTimer)
		return res
	}
}
