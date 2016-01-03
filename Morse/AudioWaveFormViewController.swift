//
//  AudioWaveFormViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/1/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class AudioWaveFormViewController: UIViewController, EZMicrophoneDelegate {
	var audioPlot:EZAudioPlot!
	var microphone:EZMicrophone!
	var transmitter:MorseTransmitter! {
		willSet {
			newValue.resetForAudioInput()
		}
	}

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
		self.audioPlot.plotType = .Rolling
		self.audioPlot.shouldFill = true
		self.audioPlot.shouldMirror = true
	}
    
	func microphone(microphone: EZMicrophone!,
		hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>,
		withBufferSize bufferSize: UInt32,
		withNumberOfChannels numberOfChannels: UInt32) {
		dispatch_async(dispatch_get_main_queue()) {
			self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
			self.transmitter.microphone(microphone,
				hasAudioReceived: buffer,
				withBufferSize: bufferSize,
				withNumberOfChannels: numberOfChannels)
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
