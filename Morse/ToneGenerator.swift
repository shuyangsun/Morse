//
//  ToneGenerator.swift
//  Morse
//
//  Created by Shuyang Sun on 1/5/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class ToneGenerator: NSObject, EZOutputDataSource, EZOutputDelegate {
	var pitch:Float {
		return appDelegate.ouputPitch
	}
	var sampleRate:Float = defaultSampleRate
	var amplitude:Float = 1
	var theta:Float = 0
	private var _output = EZOutput()

	override init() {
		super.init()
		let inputFormat = EZAudioUtilities.monoFloatFormatWithSampleRate(self.sampleRate)
		self._output = EZOutput(dataSource: self, inputFormat: inputFormat)
		self._output.delegate = self
		self._output.volume = 1
	}

	func play() {
		self._output.startPlayback()
	}

	func stop() {
		self._output.stopPlayback()
	}

	func mute() {
		self._output.volume = 0
	}

	func unmute() {
		self._output.volume = 1
	}

	func output(output: EZOutput!,
		shouldFillAudioBufferList audioBufferList: UnsafeMutablePointer<AudioBufferList>,
		withNumberOfFrames frames: UInt32,
		timestamp: UnsafePointer<AudioTimeStamp>) -> OSStatus {
			let buffer = UnsafeMutablePointer<Float32>(audioBufferList.memory.mBuffers.mData)
			//			let bufferByteSize = audioBufferList.memory.mBuffers.mDataByteSize
			let twoPI = 2.0 * Float(M_PI)
			var theta = self.theta
			let thetaIncrement = twoPI * self.pitch / self.sampleRate;
			// Generate sine wave
			for frame in 0..<Int(frames) {
				buffer[frame] = self.amplitude * sin(theta)
				theta += thetaIncrement
				if theta > twoPI {
					theta -= twoPI
				}
			}
			self.theta = theta
			return 0
	}
}