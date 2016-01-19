//
//  OutputViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/18/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import AVFoundation

class OutputViewController: GAITrackedViewController, MorseOutputPlayerDelegate {

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
	var playButton:UIButton!

	var wpmLabel:UILabel!
	var pitchLabel:UILabel!
	var tutorial1Label:UILabel!
	var tapToStartLabel:UILabel!
	var swipeToDismissLabel:UILabel!
	private var _viewsShouldFadeOutWhenPlaying:[UIView] = []

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
			appDelegate.soundOutputEnabled = newValue
			if !newValue {
				// Stop playing if the user wants to disable sound
				self._toneGenerator.mute()
			}
			let soundImage = UIImage(named: newValue ? theme.soundOnImageName : theme.soundOffImageName)!.imageWithRenderingMode(.AlwaysTemplate)
			self.soundToggleButton.setImage(soundImage, forState: .Normal)

			let tracker = GAI.sharedInstance().defaultTracker
			if newValue {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Output Sound Enabled",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Output Sound Disabled",
					value: nil).build() as [NSObject : AnyObject])
			}
		}
	}
	private var _flashEnabled = appDelegate.flashOutputEnabled {
		willSet {
			appDelegate.flashOutputEnabled = newValue
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
			let flashImage = UIImage(named: newValue ? theme.flashOnImageName : theme.flashOffImageName)!.imageWithRenderingMode(.AlwaysTemplate)
			self.flashToggleButton.setImage(flashImage, forState: .Normal)

			let tracker = GAI.sharedInstance().defaultTracker
			if newValue {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Flash Enabled",
					value: nil).build() as [NSObject : AnyObject])
			} else {
				tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
					action: "button_press",
					label: "Flash Disabled",
					value: nil).build() as [NSObject : AnyObject])
			}
		}
	}
	private var _startDate = NSDate()
	private var _progressTimer = NSTimer()


	// Camera
	private let _rearCamera:AVCaptureDevice! = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
	private let _toneGenerator:ToneGenerator = ToneGenerator()

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
	private let _outputVCTopBarHeight:CGFloat = 76

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}

	// *****************************
	// MARK: MVC Lifecycle
	// *****************************
    override func viewDidLoad() {
        super.viewDidLoad()
		self.screenName = outputVCName

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: topBarHeight))
			self.topBarView.backgroundColor = theme.outputVCTopBarColor
			self.view.addSubview(self.topBarView)
			self.topBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(self._outputVCTopBarHeight)
			})

			if self.progressBarView == nil {
				let x = layoutDirection == .LeftToRight ? 0 : self.view.bounds.width
				self.progressBarView = UIView(frame: CGRect(x: x, y: 0, width: 0, height: topBarHeight))
				self.progressBarView.backgroundColor = theme.progressBarColor
				self.topBarView.addSubview(self.progressBarView)
				self.progressBarView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
				})
				self.topBarView.setNeedsUpdateConstraints()
			}

			if self.percentageLabel == nil {
				self.percentageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self._outputVCTopBarHeight, height: self._outputVCTopBarHeight))
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
				self.flashToggleButton = UIButton(frame: CGRect(x: 0, y: 0, width: self._outputVCTopBarHeight, height: self._outputVCTopBarHeight))
				self.flashToggleButton.backgroundColor = UIColor.clearColor()
				self.flashToggleButton.tintColor = theme.topBarLabelTextColor
				let flashImage = UIImage(named: self._flashEnabled ? theme.flashOnImageName : theme.flashOffImageName)!.imageWithRenderingMode(.AlwaysTemplate)
				self.flashToggleButton.setImage(flashImage, forState: .Normal)
				self.flashToggleButton.tintColor = theme.outputVCButtonTintColor
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
				self.soundToggleButton = UIButton(frame: CGRect(x: 0, y: 0, width: self._outputVCTopBarHeight, height: self._outputVCTopBarHeight))
				self.soundToggleButton.backgroundColor = UIColor.clearColor()
				self.soundToggleButton.tintColor = theme.topBarLabelTextColor
				let soundImage = UIImage(named: self._soundEnabled ? theme.soundOnImageName : theme.soundOffImageName)!.imageWithRenderingMode(.AlwaysTemplate)
				self.soundToggleButton.setImage(soundImage, forState: .Normal)
				self.soundToggleButton.tintColor = theme.outputVCButtonTintColor
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
				self.morseTextBackgroundView = UIView(frame: CGRect(x: 0, y: self._outputVCTopBarHeight - self._morseTextLabelHeight, width: self.view.bounds.width, height: self._morseTextLabelHeight))
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
			self.screenFlashView = UIView(frame: CGRect(x: 0, y: topBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - topBarHeight))
			self.screenFlashView.backgroundColor = UIColor.blackColor()
			let tapGR = UITapGestureRecognizer(target: self, action: "outputWillStart")
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

		if self.playButton == nil {
			self.playButton = UIButton()
			let playImage = UIImage(named: theme.outputPlayButtonImageName)!.imageWithRenderingMode(.AlwaysTemplate)
			self.playButton.setImage(playImage, forState: .Normal)
			self.playButton.tintColor = theme.outputVCButtonTintColor
			self.playButton.addTarget(self, action: "outputWillStart", forControlEvents: .TouchUpInside)
			self.playButton.alpha = 0
			self._viewsShouldFadeOutWhenPlaying.append(self.playButton)
			self.view.addSubview(self.playButton)
			self.playButton.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.centerY.equalTo(self.view).offset(topBarHeight)
			})
		}

		if self.wpmLabel == nil {
			self.wpmLabel = UILabel()
			var text = "\(LocalizedStrings.Label.wpmWithColon)\(appDelegate.outputWPM)"
			if layoutDirection == .RightToLeft {
				text = "\(appDelegate.outputWPM)\(LocalizedStrings.Label.wpmWithColon)"
			}
			self.wpmLabel.attributedText = getAttributedStringFrom(text, withFontSize: hintLabelFontSize, color: theme.outputVCLabelTextColorEmphasized, bold: false)
			self.wpmLabel.opaque = false
			self.wpmLabel.alpha = 0
			self._viewsShouldFadeOutWhenPlaying.append(self.wpmLabel)
			self.view.addSubview(self.wpmLabel)

			self.wpmLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.top.equalTo(self.topBarView.snp_bottom).offset(hintLabelMarginVertical)
			})
		}

		if self.pitchLabel == nil {
			self.pitchLabel = UILabel()
			var text = "\(LocalizedStrings.Label.pitchWithColon)\(Int(appDelegate.outputPitch)) Hz"
			if layoutDirection == .RightToLeft {
				text = "Hz \(Int(appDelegate.outputPitch))\(LocalizedStrings.Label.pitchWithColon)"
			}
			self.pitchLabel.attributedText = getAttributedStringFrom(text, withFontSize: hintLabelFontSize, color: theme.outputVCLabelTextColorEmphasized, bold: false)
			self.pitchLabel.opaque = false
			self.pitchLabel.alpha = 0
			self._viewsShouldFadeOutWhenPlaying.append(self.pitchLabel)
			self.view.addSubview(self.pitchLabel)

			self.pitchLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.top.equalTo(self.wpmLabel.snp_bottom).offset(hintLabelMarginVertical)
			})
		}

		if self.tutorial1Label == nil {
			self.tutorial1Label = UILabel()
			self.tutorial1Label.attributedText = getAttributedStringFrom(LocalizedStrings.Label.tutorialOutputVC1, withFontSize: hintLabelFontSize, color: theme.outputVCLabelTextColorNormal, bold: false)
			self.tutorial1Label.opaque = false
			self.tutorial1Label.alpha = 0
			self._viewsShouldFadeOutWhenPlaying.append(self.tutorial1Label)
			self.view.addSubview(self.tutorial1Label)

			self.tutorial1Label.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.top.equalTo(self.pitchLabel.snp_bottom).offset(hintLabelMarginVertical)
			})
		}

		if self.swipeToDismissLabel == nil {
			self.swipeToDismissLabel = UILabel()
			self.swipeToDismissLabel.attributedText = getAttributedStringFrom(LocalizedStrings.Label.swipeToDismiss, withFontSize: hintLabelFontSize, color: theme.outputVCLabelTextColorNormal, bold: false)
			self.swipeToDismissLabel.opaque = false
			self.swipeToDismissLabel.alpha = 0
			self._viewsShouldFadeOutWhenPlaying.append(self.swipeToDismissLabel)
			self.view.addSubview(self.swipeToDismissLabel)

			self.swipeToDismissLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.bottom.equalTo(self.view).offset(-hintLabelMarginVertical * 2)
			})
		}

		if self.tapToStartLabel == nil {
			self.tapToStartLabel = UILabel()
			self.tapToStartLabel.attributedText = getAttributedStringFrom(LocalizedStrings.Label.tapToStart, withFontSize: hintLabelFontSize, color: theme.outputVCLabelTextColorNormal, bold: false)
			self.tapToStartLabel.opaque = false
			self.tapToStartLabel.alpha = 0
			self._viewsShouldFadeOutWhenPlaying.append(self.tapToStartLabel)
			self.view.addSubview(self.tapToStartLabel)

			self.tapToStartLabel.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.view)
				make.bottom.equalTo(self.swipeToDismissLabel.snp_top).offset(-hintLabelMarginVertical)
			})
		}

		self._toneGenerator.mute()
		self._toneGenerator.play()
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self._outputPlayer.morse = self.morse
		self._outputPlayer.delegate = self
		UIView.animateWithDuration(defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				let _ = self._viewsShouldFadeOutWhenPlaying.map { $0.alpha = 1 }
		}, completion: nil)
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

	func outputWillStart() {
		let tracker = GAI.sharedInstance().defaultTracker
		if self._playing {
			self.stopPlaying()
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Output Played",
				value: nil).build() as [NSObject : AnyObject])
		} else {
			self.startPlaying()
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Output Stopped",
				value: nil).build() as [NSObject : AnyObject])
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
			self._toneGenerator.unmute()
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
		self._toneGenerator.mute()

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
		self.progressBarView.frame = CGRect(x: x, y: 0, width: width, height: self._outputVCTopBarHeight)
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
				let _ = self._viewsShouldFadeOutWhenPlaying.map { $0.alpha = 0 }
				self.view.layoutIfNeeded()
				self.morseTextBackgroundView.alpha = 1.0
				self.percentageLabel.alpha = 1.0
			}) { succeed in
				if succeed {
					self._startDate = NSDate()
					self._outputPlayer.start()
					self._toneGenerator.play()
					if appDelegate.brightenScreenWhenOutput {
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
		self._toneGenerator.stop()
		self._progressTimer.invalidate()
		if appDelegate.brightenScreenWhenOutput {
			UIScreen.mainScreen().brightness = self._originalBrightness
		}
		UIView.animateWithDuration(defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				let _ = self._viewsShouldFadeOutWhenPlaying.map { $0.alpha = 1 }
				self.morseTextBackgroundView.alpha = 0.0
				self.percentageLabel.alpha = 0.0
				let x = layoutDirection == .LeftToRight ? 0 : self.topBarView.bounds.width
				self.progressBarView.frame = CGRect(x: x, y: 0, width: 0, height: self._outputVCTopBarHeight)
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
