//
//  ToneGenerator.swift
//  Morse
//
//  Created by Shuyang Sun on 1/5/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit
import AVFoundation
//import JavaScriptCore

class ToneGenerator: NSObject, EZOutputDataSource, EZOutputDelegate {
	var pitch:Float {
		return appDelegate.outputPitch
	}
	var sampleRate:Float = defaultSampleRate
	var amplitude:Float = 1
	var theta:Float = 0
	fileprivate var _output = EZOutput()

/*
	private var _webAudioScript:String? {
		if let jsFilePath = NSBundle.mainBundle().pathForResource("webAudioToneGenerator", ofType: "js") {
			do {
				let content = try String(contentsOfFile: jsFilePath, encoding: NSUTF8StringEncoding)
				return content
			} catch  {
				NSLog("Unable to read from \"webAudioToneGenerator.js\" file.")
				return nil
			}
		}
		return nil
	}
*/

	override init() {
		super.init()
		let inputFormat = EZAudioUtilities.monoFloatFormat(withSampleRate: self.sampleRate)
		self._output = EZOutput(dataSource: self, inputFormat: inputFormat)
		self._output.delegate = self
		self._output.volume = 1
/*
		// Test
		print(self._webAudioScript)
		if let script = self._webAudioScript {
			let context = JSContext()
			context.evaluateScript(script)
			let startSignalFuncJSValue = context.objectForKeyedSubscript("myFunc")
			startSignalFuncJSValue.callWithArguments([])
		}
*/
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

	func output(_ output: EZOutput!,
		shouldFill audioBufferList: UnsafeMutablePointer<AudioBufferList>,
		withNumberOfFrames frames: UInt32,
		timestamp: UnsafePointer<AudioTimeStamp>) -> OSStatus {
			let buffer = UnsafeMutablePointer<Float32>(audioBufferList.pointee.mBuffers.mData)
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
