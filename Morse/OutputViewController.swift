//
//  OutputViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/18/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import AVFoundation

class OutputViewController: UIViewController, MorseOutputPlayerDelegate {

	// *****************************
	// MARK: Views
	// *****************************
	var topBarView:UIView!
	var progressBarView:UIView!
	var percentageLabel:UILabel!
	var soundToggleButton:UIButton!
	var flashToggleButton:UIButton!
	var morseTextBackgroundView:UIView!
	var morseTextLabel:UILabel!
	var screenFlashView:UIView!

	var panGR:UIPanGestureRecognizer?
	var pinchGR:UIPinchGestureRecognizer?

	// *****************************
	// MARK: Data Variables
	// *****************************
	var morse:String = ""
	private let _flashQueue = dispatch_queue_create("Flash Queue", DISPATCH_QUEUE_SERIAL)
	private let _outputPlayer = MorseOutputPlayer()
	private var _playing = false
	private var _soundEnabled = appDelegate.soundOutputEnabled {
		willSet {
			appDelegate.userDefaults.setBool(newValue, forKey: userDefaultsKeySoundOutputEnabled)
			appDelegate.userDefaults.synchronize()
			if !newValue {
				// Stop playing if the user wants to disable sound
				self._audioPlayer?.volume = 0
			}
		}
	}
	private var _flashEnabled = appDelegate.flashOutputEnabled {
		willSet {
			appDelegate.userDefaults.setBool(newValue, forKey: userDefaultsKeyFlashOutputEnabled)
			appDelegate.userDefaults.synchronize()
			if !newValue {
				// Turn off flash if not enabling flash.
				if self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.On) {
					dispatch_async(self._flashQueue) {
						if let _ = try? self._rearCamera.lockForConfiguration() {}
						self._rearCamera.torchMode = .Off
						self._rearCamera.unlockForConfiguration()
					}
				}
			}
		}
	}
	private var _startDate = NSDate()
	private var _progressTimer = NSTimer()
	private var _brightenScreenWhenOutput:Bool {
		return !appDelegate.donnotBrightenScreenWhenOutput
	}
	

	// Camera
	private let _rearCamera:AVCaptureDevice! = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
	private lazy var _audioPlayer:AVAudioPlayer? = nil

	// *****************************
	// MARK: UI Variables
	// *****************************
	private var _morseTextLabelHeight:CGFloat {
		// Calculate the height required to draw the morse code.
		return ceil(getAttributedStringFrom("• —", withFontSize: morseFontSizeProgressBar, color: UIColor.blackColor(), bold: false)!.size().height) + 2 // + 2 to be safe
	}
	private var _morseTextLabelWidth:CGFloat {
		return self.morseTextLabel.attributedText!.size().width + 10
	}
	private let _doneButtonWidth:CGFloat = 100
	private var _originalBrightness:CGFloat = UIScreen.mainScreen().brightness

	// *****************************
	// MARK: MVC Lifecycle
	// *****************************
    override func viewDidLoad() {
        super.viewDidLoad()

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: self.view.bounds.width, height: topBarHeight + statusBarHeight))
			self.topBarView.backgroundColor = theme.topBarBackgroundColor
			self.view.addSubview(self.topBarView)
			self.topBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(topBarHeight + statusBarHeight)
			})

			if self.progressBarView == nil {
				let x = layoutDirection == .LeftToRight ? 0 : self.view.bounds.width
				self.progressBarView = UIView(frame: CGRect(x: x, y: 0, width: 0, height: topBarHeight + statusBarHeight))
				self.progressBarView.backgroundColor = theme.progressBarColor
				self.topBarView.addSubview(self.progressBarView)
				self.progressBarView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
				})
				self.topBarView.setNeedsUpdateConstraints()
			}

			if self.percentageLabel == nil {
				self.percentageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: topBarHeight, height: topBarHeight))
				self.percentageLabel.backgroundColor = UIColor.clearColor()
				self.percentageLabel.textColor = theme.percentageTextColor
				self.percentageLabel.text = "0%"
				self.percentageLabel.textAlignment = .Center
				self.percentageLabel.opaque = false
				self.percentageLabel.alpha = 0
				self.topBarView.addSubview(self.percentageLabel)
				self.percentageLabel.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.centerX.equalTo(self.topBarView)
					make.width.equalTo(self.percentageLabel.snp_height)
				})
			}

			if self.flashToggleButton == nil {
				self.flashToggleButton = UIButton(frame: CGRect(x: 0, y: 0, width: topBarHeight, height: topBarHeight))
				self.flashToggleButton.backgroundColor = UIColor.clearColor()
				self.flashToggleButton.tintColor = theme.topBarLabelTextColor
				self.flashToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
				self.flashToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
				self.flashToggleButton.setTitle("FLASH", forState: .Normal) // TODO: Use custom image for this button
				self.flashToggleButton.addTarget(self, action: "flashToggleButtonTapped", forControlEvents: .TouchUpInside)
				// If there's no flash available, hide it.
				if !(self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.On)) {
					self.flashToggleButton.userInteractionEnabled = false
					self.flashToggleButton.hidden = true
				}
				self.topBarView.addSubview(self.flashToggleButton)
				self.flashToggleButton.snp_remakeConstraints { (make) -> Void in
					make.top .equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
					make.width.equalTo(self.flashToggleButton.snp_height)
				}
			}

			if self.soundToggleButton == nil {
				self.soundToggleButton = UIButton(frame: CGRect(x: 0, y: 0, width: topBarHeight, height: topBarHeight))
				self.soundToggleButton.backgroundColor = UIColor.clearColor()
				self.soundToggleButton.tintColor = theme.topBarLabelTextColor
				self.soundToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
				self.soundToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
				self.soundToggleButton.setTitle("SOUND", forState: .Normal) // TODO: Use custom image for this button
				self.soundToggleButton.addTarget(self, action: "soundToggleButtonTapped", forControlEvents: .TouchUpInside)
				self.topBarView.addSubview(self.soundToggleButton)
				self.soundToggleButton.snp_remakeConstraints { (make) -> Void in
					make.top .equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.trailing.equalTo(self.topBarView)
					make.width.equalTo(self.soundToggleButton.snp_height)
				}
			}

			if self.morseTextBackgroundView == nil {
				self.morseTextBackgroundView = UIView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight - self._morseTextLabelHeight, width: self.view.bounds.width, height: self._morseTextLabelHeight))
				self.morseTextBackgroundView.backgroundColor = UIColor.clearColor()
				self.morseTextBackgroundView.opaque = false
				self.morseTextBackgroundView.alpha = 0.0
				self.topBarView.addSubview(self.morseTextBackgroundView)
				self.morseTextBackgroundView.snp_remakeConstraints(closure: { (make) -> Void in
					make.leading.equalTo(self.view)
					make.bottom.equalTo(self.topBarView)
					make.height.equalTo(self._morseTextLabelHeight)
					make.trailing.equalTo(self.view)
				})
			}

			if self.morseTextLabel == nil {
				let x = layoutDirection == .LeftToRight ? 0 : self.view.bounds.width
				self.morseTextLabel = UILabel(frame: CGRect(x: x, y: 0, width: 0, height: self._morseTextLabelHeight))
				self.morseTextLabel.backgroundColor = UIColor.clearColor()
				let labelStr = layoutDirection == .LeftToRight ? String(self.morse.characters.reverse()) : self.morse
				self.morseTextLabel.attributedText = getAttributedStringFrom(labelStr, withFontSize: morseFontSizeProgressBar, color: theme.morseTextProgressBarColor, bold: false)
				self.morseTextLabel.textAlignment = .Left
				self.morseTextBackgroundView.addSubview(self.morseTextLabel)
				self.morseTextLabel.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.morseTextBackgroundView)
					make.bottom.equalTo(self.morseTextBackgroundView)
					make.width.equalTo(self.morseTextLabel.attributedText!.size().width + 10) // +10 to be safe
					if layoutDirection == .LeftToRight {
						make.right.equalTo(self.morseTextBackgroundView.snp_left)
					} else {
						make.left.equalTo(self.morseTextBackgroundView.snp_right)
					}
				})
				self.topBarView.setNeedsUpdateConstraints()
			}
		}

		if self.screenFlashView == nil {
			self.screenFlashView = UIView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - statusBarHeight - topBarHeight))
			self.screenFlashView.backgroundColor = UIColor.blackColor()
			let tapGR = UITapGestureRecognizer(target: self, action: "screenFlashViewTapped")
			self.screenFlashView.addGestureRecognizer(tapGR)
			self.view.addSubview(self.screenFlashView)
			self.screenFlashView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.bottom.equalTo(self.view)
			})

			if self.panGR != nil {
				self.screenFlashView.addGestureRecognizer(self.panGR!)
			}
			if self.pinchGR != nil {
				self.screenFlashView.addGestureRecognizer(self.pinchGR!)
			}
		}

		// Setup audioPlayer
		do {
			self._audioPlayer = try AVAudioPlayer(contentsOfURL: morseSoundStandardURL)
			self._audioPlayer?.numberOfLoops = -1
			// Play the audio once without volume so the audio player is prepared, otherwise there will be a lag when the audio file is being played at first time.
			self._audioPlayer?.volume = 0
			self._audioPlayer?.play()
		} catch let error as NSError {
			print("Could not create AVAudioPlayer \(error), \(error.userInfo)")
		}
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self._outputPlayer.morse = self.morse
		self._outputPlayer.delegate = self
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopPlaying()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Only support landscape when it's on an iPad
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if isPad {
			return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Landscape]
		} else {
			return UIInterfaceOrientationMask.Portrait
		}
	}

	// *****************************
	// MARK: User Interaction
	// *****************************

	func soundToggleButtonTapped() {
		// TODO: Button color and image change
		self._soundEnabled = !self._soundEnabled
	}
    
	func flashToggleButtonTapped() {
		// TODO: Button color and image change
		self._flashEnabled = !self._flashEnabled
	}

	func screenFlashViewTapped() {
		if self._playing {
			self.stopPlaying()
		} else {
			self.startPlaying()
		}
	}

	// *****************************
	// MARK: Outputplayer Delegate
	// *****************************

	func startSignal() {
		// Screen Flash
		self.screenFlashView.backgroundColor = UIColor.whiteColor()

		// Sound
		if self._soundEnabled {
			self._audioPlayer?.volume = 1
		}

		// Real Flash
		if self._flashEnabled && self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.On) {
			dispatch_async(self._flashQueue) {
				if let _ = try? self._rearCamera.lockForConfiguration() {}
				self._rearCamera.torchMode = .On
				self._rearCamera.unlockForConfiguration()
			}
		}
	}

	func stopSignal() {
		// Screen Flash
		self.screenFlashView.backgroundColor = UIColor.blackColor()

		// Sound
		self._audioPlayer?.volume = 0

		// Real Flash
		if self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.On) {
			dispatch_async(self._flashQueue) {
				if let _ = try? self._rearCamera.lockForConfiguration() {}
				self._rearCamera.torchMode = .Off
				self._rearCamera.unlockForConfiguration()
			}
		}
	}

	func playEnded() {
		self.stopPlaying()
	}

	// *****************************
	// MARK: Callbacks
	// *****************************

	func updateProgress() {
		let duration = self._outputPlayer.duration
		let completionRatio = duration == 0 ? 1 : min(1, NSDate().timeIntervalSinceDate(self._startDate)/duration)
		self.percentageLabel.text = "\(Int(ceil(completionRatio * 100)))%"
		let width = self.topBarView.bounds.width * CGFloat(completionRatio)
		let x = layoutDirection == .LeftToRight ? 0 : self.topBarView.bounds.width - width
		self.progressBarView.frame = CGRect(x: x, y: 0, width: width, height: topBarHeight + statusBarHeight)
		let sign:CGFloat = layoutDirection == .LeftToRight ? 1:-1
		self.morseTextLabel.transform = CGAffineTransformMakeTranslation(sign * CGFloat(completionRatio) * self.morseTextLabel.bounds.width, 0)
	}

	// *****************************
	// MARK: Private Functions
	// *****************************

	private func startPlaying() {
		// User wants to start playing
		UIView.animateWithDuration(defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.view.layoutIfNeeded()
				self.morseTextBackgroundView.alpha = 1.0
				self.percentageLabel.alpha = 1.0
			}) { succeed in
				if succeed {
					self._startDate = NSDate()
					self._outputPlayer.start()
					if self._brightenScreenWhenOutput {
						self._originalBrightness = UIScreen.mainScreen().brightness
						UIScreen.mainScreen().brightness = 1
					}
					self._progressTimer = NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
				}
		}
		self._playing = true
	}

	private func stopPlaying() {
		// User wants to stop playing
		self._outputPlayer.stop()
		self._progressTimer.invalidate()
		if self._brightenScreenWhenOutput {
			UIScreen.mainScreen().brightness = self._originalBrightness
		}
		UIView.animateWithDuration(defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.morseTextBackgroundView.alpha = 0.0
				self.percentageLabel.alpha = 0.0
				let x = layoutDirection == .LeftToRight ? 0 : self.topBarView.bounds.width
				self.progressBarView.frame = CGRect(x: x, y: 0, width: 0, height: topBarHeight + statusBarHeight)
			}) { succeed in
				if succeed {
					self.percentageLabel.text = "0%"
					self.morseTextLabel.transform = CGAffineTransformIdentity
				}
		}
		self._playing = false
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
