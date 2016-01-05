//
//  AudioWaveFormViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/1/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class AudioWaveFormViewController: UIViewController, EZMicrophoneDelegate {
	var audioPlotPitchFiltered:EZAudioPlot!
	var audioPlot:EZAudioPlot!
	var microphone:EZMicrophone!
	private var _pitchCountDictionary:Dictionary<Int, Int> = Dictionary()

	var transmitter:MorseTransmitter! {
		willSet {
			newValue.resetForAudioInput()
		}
	}

	private var _fft:EZAudioFFTRolling!

    override func viewDidLoad() {
        super.viewDidLoad()

		let session = AVAudioSession.sharedInstance()
		do {
			try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try session.setActive(true)
		} catch {
			NSLog("Error setting up audio session category.")
		}

		// Setup audio plot
		self.audioPlot = EZAudioPlot(frame: self.view.frame)
		self.audioPlot.backgroundColor = theme.audioPlotBackgroundColor
		self.audioPlot.color = theme.audioPlotColor
		self.audioPlot.plotType = .Rolling
		self.audioPlot.shouldMirror = true
		self.audioPlot.shouldFill = true
		self.audioPlot.setRollingHistoryLength(audioPlotRollingHistoryLength)
		self.view.addSubview(self.audioPlot)
		self.audioPlot.snp_makeConstraints { (make) -> Void in
			make.edges.equalTo(self.view)
		}

		self.audioPlotPitchFiltered = EZAudioPlot(frame: self.view.frame)
		self.audioPlotPitchFiltered.backgroundColor = theme.audioPlotBackgroundColor
		self.audioPlotPitchFiltered.color = theme.audioPlotPitchFilteredColor
		self.audioPlotPitchFiltered.plotType = .Rolling
		self.audioPlotPitchFiltered.shouldMirror = true
		self.audioPlotPitchFiltered.shouldFill = true
		self.audioPlotPitchFiltered.setRollingHistoryLength(audioPlotRollingHistoryLength)
		self.view.addSubview(self.audioPlotPitchFiltered)
		self.audioPlotPitchFiltered.snp_makeConstraints { (make) -> Void in
			make.edges.equalTo(self.view)
		}

		// WARNNING: This chunk of code has to be executed before calling "self.microphone.startFetchingAudio()"!
		if appDelegate.inputPitchAutomatic {
			appDelegate.userDefaults.setFloat(automaticPitchFrequencyMin, forKey: userDefaultsKeyInputPitchFrequency)
			appDelegate.userDefaults.synchronize()
		}

		// Setup mircrophone
		self.microphone = EZMicrophone(microphoneDelegate: self)
		self.microphone.device = EZAudioDevice.currentInputDevice()
		self.microphone.startFetchingAudio()

		// Setup transmitter
		self.transmitter.resetForAudioInput()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func drawRollingPlot() {
		self.audioPlotPitchFiltered.plotType = .Rolling
		self.audioPlotPitchFiltered.shouldFill = true
		self.audioPlotPitchFiltered.shouldMirror = true
	}
    
	func microphone(microphone: EZMicrophone!,
		hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>,
		withBufferSize bufferSize: UInt32,
		withNumberOfChannels numberOfChannels: UInt32) {
		if self._fft == nil {
			self._fft = EZAudioFFTRolling.fftWithWindowSize(fttWindowSize,
				sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate))
		}
		self._fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
		dispatch_async(dispatch_get_main_queue()) {
			// Update plot for general audio
			self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
			let maxFrequency = self._fft.maxFrequency

			// If the frequency is set to automatic, update frequency
			if appDelegate.inputPitchAutomatic {
				// Should change frequency will be set later by an algorithm determining if the frequency should be changed while on automatic input frequency setting.
				// The algorithm count number of frequency's occurence above a certain threshol (automaticPitchFrequencyMin), and pick the frequency that occured most of the time.
				var shouldChangeFrequency = false
				// Convert the maxFrequency to an Int, since the record dictionary is an integer.
				let maxFreqInt = Int(ceil(maxFrequency))
				// If this new frequency is above the threashold for automatic detection, add it to the dictionary
				if maxFrequency >= automaticPitchFrequencyMin {
					if let occurCount = self._pitchCountDictionary[maxFreqInt] {
						// If the new frequency is already in the record, increase it by one.
						self._pitchCountDictionary[maxFreqInt] = occurCount + 1
					} else {
						// If the new frequency is not already in the record, set it to one.
						self._pitchCountDictionary[maxFreqInt] = 1
					}
				}
				// Check if this new frequency has a occuring number in the dictionary, if yes, proceed; if no, it must be below the threshold.
				if let numOccurence = self._pitchCountDictionary[maxFreqInt] {
					// Now this new frequency is above threshold, and has a occurency record.
					// Check if the old frequency has a record or is above the threashold.
					if let currentInputPitchFreqOccurence = self._pitchCountDictionary[Int(ceil(appDelegate.inputPitchFrequency))] {
						// Now both the new and old frequency have an occurence record, now choose the one that occured more times.
						if numOccurence >= currentInputPitchFreqOccurence {
							shouldChangeFrequency = true
						}
					} else {
						// Now this new frequency is above threshold, but the old one is not. So should change frequency to the new one.
						shouldChangeFrequency = true
					}
				}

				if shouldChangeFrequency {
					appDelegate.userDefaults.setFloat(maxFrequency, forKey: userDefaultsKeyInputPitchFrequency)
					appDelegate.userDefaults.synchronize()
					// Send out a notification so that values on the settings page can be updated.
					NSNotificationCenter.defaultCenter().postNotificationName(inputPitchFrequencyDidChangeNotificationName, object: nil)
				}
			}

			// If the frequency should be detected, update the filtered audio plot and call analysis method on transmitter
			if inputPitchFrequencyRange.contains(Int(maxFrequency)) {
				// Update the filtred audio plot with the real data.
				self.audioPlotPitchFiltered.updateBuffer(buffer[0], withBufferSize: bufferSize)
				self.transmitter.microphone(microphone, maxFrequencyMagnitude: self._fft.maxFrequencyMagnitude)
			} else {
				// Update the filtered audio plot with 0.
				buffer[0].memory = 0
				self.audioPlotPitchFiltered.updateBuffer(buffer[0], withBufferSize: 1)
				self.transmitter.microphone(microphone, maxFrequencyMagnitude: 0)
			}
		}
	}

	func microphone(microphone: EZMicrophone!, hasAudioStreamBasicDescription audioStreamBasicDescription: AudioStreamBasicDescription) {
		EZAudioUtilities.printASBD(audioStreamBasicDescription)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
