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
	var doneButton:UIButton!
	var percentageLabel:UILabel!
	var soundToggleButton:UIButton!
	var flashToggleButton:UIButton?
	var morseTextBackgroundView:UIView!
	var morseTextLabel:UILabel!
	var screenFlashView:UIView!

	// *****************************
	// MARK: Data Variables
	// *****************************
	var morse:String = "" {
		willSet {
			self._outputPlayer.morse = newValue
		}
	}
	private let _outputPlayer = MorseOutputPlayer()
	private var _playing = false
	private var _soundEnabled = appDelegate.soundOutputEnabled {
		willSet {
			appDelegate.userDefaults.setBool(newValue, forKey: userDefaultsKeySoundOutputEnabled)
			appDelegate.userDefaults.synchronize()
		}
	}
	private var _flashEnabled = appDelegate.flashOutputEnabled {
		willSet {
			appDelegate.userDefaults.setBool(newValue, forKey: userDefaultsKeyFlashOutputEnabled)
			appDelegate.userDefaults.synchronize()
			if !newValue {
				// Turn off flash if not enabling flash.
				if self.rearCamera != nil && self.rearCamera.hasTorch && self.rearCamera.hasFlash && self.rearCamera.isTorchModeSupported(.On) {
					dispatch_async(dispatch_queue_create("FLASH QUEUE", DISPATCH_QUEUE_SERIAL)) {
						if let _ = try? self.rearCamera.lockForConfiguration() {}
						self.rearCamera.torchMode = .Off
						self.rearCamera.unlockForConfiguration()
					}
				}
			}
		}
	}
	private var startDate = NSDate()
	private var progressTimer = NSTimer()
	private var brightenScreenWhenOutput:Bool {
//		return appDelegate.brightenScreenWhenOutput
		return true
	}

	// Camera
	private var rearCamera:AVCaptureDevice! = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

	// *****************************
	// MARK: UI Variables
	// *****************************
	private var morseTextLabelHeight:CGFloat {
		// Calculate the height required to draw the morse code.
		return ceil(getAttributedStringFrom("• —", withFontSize: morseFontSizeProgressBar, color: UIColor.blackColor(), bold: false)!.size().height) + 2 // + 2 to be safe
	}
	private let doneButtonWidth:CGFloat = 100
	private var controlButtonWidth:CGFloat = 50
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
				self.progressBarView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: topBarHeight + statusBarHeight))
				self.progressBarView.backgroundColor = theme.progressBarColor
				self.topBarView.addSubview(self.progressBarView)
				self.progressBarView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.left.equalTo(self.topBarView)
				})
			}

			if self.doneButton == nil {
				self.doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.doneButtonWidth, height: topBarHeight))
				self.doneButton.backgroundColor = UIColor.clearColor()
				self.doneButton.tintColor = theme.topBarLabelTextColor
				self.doneButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
				self.doneButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
				self.doneButton.setTitle(LocalizedStrings.Button.done, forState: .Normal)
				self.doneButton.addTarget(self, action: "doneButtonTapped", forControlEvents: .TouchUpInside)
				self.topBarView.addSubview(self.doneButton)
				self.doneButton.snp_remakeConstraints { (make) -> Void in
					make.top .equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
					make.width.equalTo(self.doneButtonWidth)
				}
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

			if self.soundToggleButton == nil {
				self.soundToggleButton = UIButton(frame: CGRect(x: 0, y: self.view.bounds.width - self.controlButtonWidth, width: self.controlButtonWidth, height: topBarHeight))
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
					make.width.equalTo(self.controlButtonWidth)
				}
			}

			if self.flashToggleButton == nil && self.rearCamera != nil && self.rearCamera.hasTorch && self.rearCamera.hasFlash && self.rearCamera.isTorchModeSupported(.On) {
				self.flashToggleButton = UIButton(frame: CGRect(x: 0, y: self.view.bounds.width - self.controlButtonWidth * 2, width: self.controlButtonWidth, height: topBarHeight))
				self.flashToggleButton!.backgroundColor = UIColor.clearColor()
				self.flashToggleButton!.tintColor = theme.topBarLabelTextColor
				self.flashToggleButton!.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
				self.flashToggleButton!.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
				self.flashToggleButton!.setTitle("FLASH", forState: .Normal) // TODO: Use custom image for this button
				self.flashToggleButton!.addTarget(self, action: "flashToggleButtonTapped", forControlEvents: .TouchUpInside)
				self.topBarView.addSubview(self.flashToggleButton!)
				self.flashToggleButton!.snp_remakeConstraints { (make) -> Void in
					make.top .equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.trailing.equalTo(self.soundToggleButton.snp_leading)
					make.width.equalTo(self.controlButtonWidth)
				}
			}

			if self.morseTextBackgroundView == nil {
				self.morseTextBackgroundView = UIView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight - self.morseTextLabelHeight, width: self.view.bounds.width, height: self.morseTextLabelHeight))
				self.morseTextBackgroundView.backgroundColor = UIColor.clearColor()
				self.morseTextBackgroundView.opaque = false
				self.morseTextBackgroundView.alpha = 0.0
				self.topBarView.addSubview(self.morseTextBackgroundView)
				self.morseTextBackgroundView.snp_remakeConstraints(closure: { (make) -> Void in
					make.left.equalTo(self.view)
					make.right.equalTo(self.view)
					make.bottom.equalTo(self.topBarView)
					make.height.equalTo(self.morseTextLabelHeight)
				})
			}

			if self.morseTextLabel == nil {
				self.morseTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.morseTextLabelHeight))
				self.morseTextLabel.backgroundColor = UIColor.clearColor()
				self.morseTextLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: morseFontSizeProgressBar, color: theme.morseTextProgressBarColor, bold: false)
				self.morseTextLabel.textAlignment = .Left
				self.morseTextBackgroundView.addSubview(self.morseTextLabel)
				self.morseTextLabel.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.morseTextBackgroundView)
					make.left.equalTo(self.morseTextBackgroundView)
					make.bottom.equalTo(self.morseTextBackgroundView)
					make.width.equalTo(self.morseTextLabel.attributedText!.size().width + 10) // +10 to be safe
				})
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
		}

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

	func doneButtonTapped() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

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

		// Real Flash
		if self._flashEnabled && self.rearCamera != nil && self.rearCamera.hasTorch && self.rearCamera.hasFlash && self.rearCamera.isTorchModeSupported(.On) {
			dispatch_async(dispatch_queue_create("FLASH QUEUE", DISPATCH_QUEUE_SERIAL)) {
				if let _ = try? self.rearCamera.lockForConfiguration() {}
				self.rearCamera.torchMode = .On
				self.rearCamera.unlockForConfiguration()
			}
		}
	}

	func stopSignal() {
		// Screen Flash
		self.screenFlashView.backgroundColor = UIColor.blackColor()

		// Real Flash
		if self.rearCamera != nil && self.rearCamera.hasTorch && self.rearCamera.hasFlash && self.rearCamera.isTorchModeSupported(.On) {
			dispatch_async(dispatch_queue_create("FLASH QUEUE", DISPATCH_QUEUE_SERIAL)) {
				if let _ = try? self.rearCamera.lockForConfiguration() {}
				self.rearCamera.torchMode = .Off
				self.rearCamera.unlockForConfiguration()
			}
		}
	}

	func playEnded() {
		self.stopPlaying()
	}

	// *****************************
	// MARK: Callbacks
	// *****************************

	func progressChanged() {
		let duration = self._outputPlayer.duration
		let completionRatio = duration == 0 ? 1 : min(1, NSDate().timeIntervalSinceDate(self.startDate)/duration)
		self.percentageLabel.text = "\(Int(ceil(completionRatio * 100)))%"
		self.progressBarView.frame = CGRect(x: 0, y: 0, width: self.topBarView.bounds.width * CGFloat(completionRatio), height: topBarHeight + statusBarHeight)
		self.morseTextLabel.transform = CGAffineTransformMakeTranslation(-CGFloat(completionRatio) * self.morseTextLabel.bounds.width, 0)
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
					self.startDate = NSDate()
					self._outputPlayer.start()
					if self.brightenScreenWhenOutput {
						self._originalBrightness = UIScreen.mainScreen().brightness
						UIScreen.mainScreen().brightness = 1
					}
					self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: self, selector: "progressChanged", userInfo: nil, repeats: true)
				}
		}
		self._playing = true
	}

	private func stopPlaying() {
		// User wants to stop playing
		self._outputPlayer.stop()
		self.progressTimer.invalidate()
		if self.brightenScreenWhenOutput {
			UIScreen.mainScreen().brightness = self._originalBrightness
		}
		UIView.animateWithDuration(defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.view.layoutIfNeeded()
				self.morseTextBackgroundView.alpha = 0.0
				self.percentageLabel.alpha = 0.0
				self.progressBarView.frame = CGRect(x: 0, y: 0, width: 0, height: topBarHeight + statusBarHeight)
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
