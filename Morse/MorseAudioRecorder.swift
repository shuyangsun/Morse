//
//  MorseAudioRecorder.swift
//  Morse
//
//  Created by Shuyang Sun on 12/20/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import AVFoundation

class MorseAudioRecorder: NSObject {
	private var _recorder:AVAudioRecorder? = nil
	private var _sampleTimer:NSTimer! = nil

	var delegate:MorseAudioRecorderDelegate? = nil
	var sensitivity:Float = 0.7
	var frequency:Float = 0.03
	var lowPassResults:Float = 0

	init?(sensitivity:Float = 0.7, frequency:Float = 0.03, lowPassResults:Float = 0) {
		super.init()
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
			self.sensitivity = sensitivity
			self.frequency = frequency
			self.lowPassResults = lowPassResults

			// Initialize recorder
			let url = NSURL.fileURLWithPath("/dev/null")
			let settings:[String:AnyObject] = [
				AVSampleRateKey: 44100,
				AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatAppleLossless),
				AVNumberOfChannelsKey: 1,
				AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue
			]
			self._recorder = try AVAudioRecorder(URL: url, settings: settings)
			if self._recorder != nil{
				self._recorder!.prepareToRecord()
				self._recorder!.meteringEnabled = true
			}
		} catch let error as NSError {
			print("Could not create Recorder \(error), \(error.userInfo)")
			return nil
		}
	}

	func startRecording() {
		self._sampleTimer = NSTimer.scheduledTimerWithTimeInterval(audioSampleFrequencyTimeInterval, target: self, selector: "sampleTimerCallback", userInfo: nil, repeats: true)
		self._recorder?.record()
	}

	func stopRecording() {
		self._sampleTimer.invalidate()
		self._recorder?.stop()
	}

	func sampleTimerCallback() {
		if let recorder = self._recorder {
			recorder.updateMeters()

			let alpha:Float = 0.1
			let peakPower = recorder.peakPowerForChannel(0)
			self.lowPassResults = alpha * peakPower + (1 - alpha) * self.lowPassResults

			self.delegate?.audioLevelUpdated?(self.lowPassResults, avgPower: recorder.averagePowerForChannel(0), peakPower: recorder.peakPowerForChannel(0), recognized: self.lowPassResults > 0.95)
			self.lowPassResults = 0
		}
	}
}