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

	var wpmLabel:UILabel!
	var pitchLabel:UILabel!
	var tutorial1Label:UILabel!
	var tapToFinishLabel:UILabel!

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

		self.view.backgroundColor = theme.audioPlotBackgroundColor

		// Setup audio plot
		self.audioPlot = EZAudioPlot(frame: self.view.frame)
		self.audioPlot.backgroundColor = UIColor.clearColor()
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
		self.audioPlotPitchFiltered.backgroundColor = UIColor.clearColor()
		self.audioPlotPitchFiltered.color = theme.audioPlotPitchFilteredColor
		self.audioPlotPitchFiltered.plotType = .Rolling
		self.audioPlotPitchFiltered.shouldMirror = true
		self.audioPlotPitchFiltered.shouldFill = true
		self.audioPlotPitchFiltered.setRollingHistoryLength(audioPlotRollingHistoryLength)
		self.view.addSubview(self.audioPlotPitchFiltered)
		self.audioPlotPitchFiltered.snp_makeConstraints { (make) -> Void in
			make.edges.equalTo(self.view)
		}

		if self.wpmLabel == nil {
			self.wpmLabel = UILabel()
			self.updateWPMLabel(true)
			self.view.addSubview(self.wpmLabel)

			self.wpmLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.top.equalTo(self.view).offset(hintLabelMarginVertical * 2)
			})
		}

		if self.pitchLabel == nil {
			self.pitchLabel = UILabel()
			self.updatePitchLabel(true)
			self.view.addSubview(self.pitchLabel)

			self.pitchLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.top.equalTo(self.wpmLabel.snp_bottom).offset(hintLabelMarginVertical)
			})
		}

		if self.tutorial1Label == nil {
			self.tutorial1Label = UILabel()
			var text = "\(LocalizedStrings.Label.tutorialWaveformVC1)\(supportedAudioDecoderWPMRange.startIndex)-\(supportedAudioDecoderWPMRange.endIndex - 1)"
			if layoutDirection == .RightToLeft {
				text = "\(supportedAudioDecoderWPMRange.endIndex - 1)-\(supportedAudioDecoderWPMRange.startIndex)\(LocalizedStrings.Label.tutorialWaveformVC1)"
			}
			self.tutorial1Label.attributedText = getAttributedStringFrom(text, withFontSize: hintLabelFontSize, color: theme.waveformVCLabelTextColorNormal, bold: false)
			self.view.addSubview(self.tutorial1Label)

			self.tutorial1Label.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.top.equalTo(self.pitchLabel.snp_bottom).offset(hintLabelMarginVertical)
			})
		}

		if self.tapToFinishLabel == nil {
			self.tapToFinishLabel = UILabel()
			self.tapToFinishLabel.attributedText = getAttributedStringFrom(LocalizedStrings.Label.tapToFinish, withFontSize: hintLabelFontSize, color: theme.waveformVCLabelTextColorNormal, bold: false)
			self.view.addSubview(self.tapToFinishLabel)

			self.tapToFinishLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.bottom.equalTo(self.view).offset(-hintLabelMarginVertical * 2)
			})
		}

		// WARNNING: This chunk of code has to be executed before calling "self.microphone.startFetchingAudio()"!
		if appDelegate.inputPitchAutomatic {
			appDelegate.userDefaults.setFloat(automaticPitchMin, forKey: userDefaultsKeyInputPitch)
			appDelegate.userDefaults.synchronize()
		}

		// Setup mircrophone
		self.microphone = EZMicrophone(microphoneDelegate: self)
		self.microphone.device = EZAudioDevice.currentInputDevice()
		self.microphone.startFetchingAudio()

		// Setup transmitter
		self.transmitter.resetForAudioInput()

		// Register for notification
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateWPMLabelWithoutAutomaticStatus", name: inputWPMDidChangeNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePitchLabelWithoutAutomaticStatus", name: inputPitchDidChangeNotificationName, object: nil)
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: audioDecoderVCName)

		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
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
		// COMS 430 Demo 2: dispatch audio related stuff onto main queue.
		dispatch_async(dispatch_get_main_queue()) {
			// Update plot for general audio
			self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
			let maxFrequency = self._fft.maxFrequency

			// If the frequency is set to automatic, update frequency
			if appDelegate.inputPitchAutomatic {
				// Should change frequency will be set later by an algorithm determining if the frequency should be changed while on automatic input frequency setting.
				// The algorithm count number of frequency's occurence above a certain threshol (automaticPitchMin), and pick the frequency that occured most of the time.
				var shouldChangeFrequency = false
				// Convert the maxFrequency to an Int, since the record dictionary is an integer.
				let maxFreqInt = Int(ceil(maxFrequency))
				// If this new frequency is above the threashold for automatic detection, add it to the dictionary
				if maxFrequency >= automaticPitchMin {
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
					if let currentInputPitchFreqOccurence = self._pitchCountDictionary[Int(ceil(appDelegate.inputPitch))] {
						// Now both the new and old frequency have an occurence record, now choose the one that occured more times.
						if numOccurence > 1 && numOccurence >= currentInputPitchFreqOccurence {
							shouldChangeFrequency = true
						}
					} else {
						// Now this new frequency is above threshold, but the old one is not. So should change frequency to the new one.
						shouldChangeFrequency = true
					}
				}

				if shouldChangeFrequency {
					appDelegate.inputPitch = maxFrequency
				}
			}

			// If the frequency should be detected, update the filtered audio plot and call analysis method on transmitter
			if inputPitchRange.contains(Int(maxFrequency)) {
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

	func updatePitchLabel(showAutomaticStatus:Bool = false) {
		var pitchNumberText = "\(Int(appDelegate.inputPitch)) Hz"
		if showAutomaticStatus && appDelegate.inputPitchAutomatic {
			pitchNumberText = LocalizedStrings.Settings.automaticAudioDecoderValue
		}
		let text = "\(LocalizedStrings.Label.pitchWithColon)\(pitchNumberText)"
		self.pitchLabel.attributedText = getAttributedStringFrom(text, withFontSize: hintLabelFontSize, color: theme.waveformVCLabelTextColorEmphasized, bold: false)
	}

	func updateWPMLabel(showAutomaticStatus:Bool = false) {
		var wpmNumberText = String(appDelegate.inputWPM)
		if showAutomaticStatus && appDelegate.inputWPMAutomatic {
			wpmNumberText = LocalizedStrings.Settings.automaticAudioDecoderValue
		}
		let text = "\(LocalizedStrings.Label.wpmWithColon)\(wpmNumberText)"
		self.wpmLabel.attributedText = getAttributedStringFrom(text, withFontSize: hintLabelFontSize, color: theme.waveformVCLabelTextColorEmphasized, bold: false)
	}

	func updateWPMLabelWithoutAutomaticStatus() {
		self.updateWPMLabel(false)
	}

	func updatePitchLabelWithoutAutomaticStatus() {
		self.updatePitchLabel(false)
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
