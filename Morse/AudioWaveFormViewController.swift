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
			self._fft = EZAudioFFTRolling.fftWithWindowSize(9000,
				sampleRate: Float(self.microphone.audioStreamBasicDescription().mSampleRate))
		}
		self._fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
		dispatch_async(dispatch_get_main_queue()) {
			// Update plot for general audio
			self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
			let maxFrequency = self._fft.maxFrequency
			// If the frequency should be detected, update the filtered audio plot and call analysis method on transmitter
			if inputPitchFrequencyRange.contains(Int(maxFrequency)) {
				self.audioPlotPitchFiltered.updateBuffer(buffer[0], withBufferSize: bufferSize)
				self.transmitter.microphone(microphone,
					hasAudioReceived: buffer,
					withBufferSize: bufferSize,
					withNumberOfChannels: numberOfChannels,
					maxFrequencyMagnitude: self._fft.maxFrequencyMagnitude)
			} else {
				buffer[0].memory = 0
				self.audioPlotPitchFiltered.updateBuffer(buffer[0], withBufferSize: 1)
				self.transmitter.microphone(microphone,
					hasAudioReceived: buffer,
					withBufferSize: 1,
					withNumberOfChannels: numberOfChannels,
					maxFrequencyMagnitude: 0)
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
