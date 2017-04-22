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
	fileprivate var _viewsShouldFadeOutWhenPlaying:[UIView] = []

	var panGR:UIPanGestureRecognizer?
	var pinchGR:UIPinchGestureRecognizer?

	// *****************************
	// MARK: Data Variables
	// *****************************
	var morse:String = ""
	fileprivate let _hardwareInitializationQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
	fileprivate let _outputPlayer = MorseOutputPlayer()
	fileprivate var _playing = false
	fileprivate var _soundEnabled = appDelegate.soundOutputEnabled {
		willSet {
			appDelegate.soundOutputEnabled = newValue
			if !newValue {
				// Stop playing if the user wants to disable sound
				self._toneGenerator.mute()
			}
			let soundImage = UIImage(named: newValue ? theme.soundOnImageName : theme.soundOffImageName)!.withRenderingMode(.alwaysTemplate)
			self.soundToggleButton.setImage(soundImage, for: UIControlState())

			let tracker = GAI.sharedInstance().defaultTracker
			if newValue {
				tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
					action: "button_press",
					label: "Output Sound Enabled",
					value: nil).build() as [AnyHashable: Any])
			} else {
				tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
					action: "button_press",
					label: "Output Sound Disabled",
					value: nil).build() as [AnyHashable: Any])
			}
		}
	}
	fileprivate var _flashEnabled = appDelegate.flashOutputEnabled {
		willSet {
			self._hardwareInitializationQueue.async {
				appDelegate.flashOutputEnabled = newValue
				if !newValue {
					// Turn off flash if not enabling flash.
					if self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.on) {
						if let _ = try? self._rearCamera.lockForConfiguration() {}
						self._rearCamera.torchMode = .off
						self._rearCamera.unlockForConfiguration()
					}
				}
			}
			let flashImage = UIImage(named: newValue ? theme.flashOnImageName : theme.flashOffImageName)!.withRenderingMode(.alwaysTemplate)
			self.flashToggleButton.setImage(flashImage, for: UIControlState())

			let tracker = GAI.sharedInstance().defaultTracker
			if newValue {
				tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
					action: "button_press",
					label: "Flash Enabled",
					value: nil).build() as [AnyHashable: Any])
			} else {
				tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
					action: "button_press",
					label: "Flash Disabled",
					value: nil).build() as [AnyHashable: Any])
			}
		}
	}
	fileprivate var _startDate = Date()
	fileprivate var _progressTimer = Timer()


	// Camera
	fileprivate let _rearCamera:AVCaptureDevice! = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
	fileprivate let _toneGenerator:ToneGenerator = ToneGenerator()

	// *****************************
	// MARK: UI Variables
	// *****************************
	fileprivate var _morseTextLabelHeight:CGFloat {
		// Calculate the height required to draw the morse code.
		return ceil(getAttributedStringFrom("• —", withFontSize: morseFontSizeProgressBar, color: UIColor.black, bold: false)!.size().height) + 2 // + 2 to be safe
	}
	fileprivate var _morseTextLabelWidth:CGFloat {
		return self.morseTextLabel.attributedText!.size().width + 10
	}
	fileprivate let _doneButtonWidth:CGFloat = 100
	fileprivate var _originalBrightness:CGFloat = UIScreen.main.brightness
	fileprivate let _outputVCTopBarHeight:CGFloat = 76

	override var prefersStatusBarHidden : Bool {
		return true
	}

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
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
				let x = layoutDirection == .leftToRight ? 0 : self.view.bounds.width
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
				self.percentageLabel.backgroundColor = UIColor.clear
				self.percentageLabel.textColor = theme.percentageTextColor
				self.percentageLabel.text = "0%"
				self.percentageLabel.textAlignment = .center
				self.percentageLabel.isOpaque = false
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
				self.flashToggleButton.backgroundColor = UIColor.clear
				self.flashToggleButton.tintColor = theme.topBarLabelTextColor
				let flashImage = UIImage(named: self._flashEnabled ? theme.flashOnImageName : theme.flashOffImageName)!.withRenderingMode(.alwaysTemplate)
				self.flashToggleButton.setImage(flashImage, for: UIControlState())
				self.flashToggleButton.tintColor = theme.outputVCButtonTintColor
				self.flashToggleButton.addTarget(self, action: #selector(OutputViewController.flashToggleButtonTapped), for: .touchUpInside)
				// If there's no flash available, hide it.
				if !(self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.on)) {
					self.flashToggleButton.isUserInteractionEnabled = false
					self.flashToggleButton.isHidden = true
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
				self.soundToggleButton.backgroundColor = UIColor.clear
				self.soundToggleButton.tintColor = theme.topBarLabelTextColor
				let soundImage = UIImage(named: self._soundEnabled ? theme.soundOnImageName : theme.soundOffImageName)!.withRenderingMode(.alwaysTemplate)
				self.soundToggleButton.setImage(soundImage, for: UIControlState())
				self.soundToggleButton.tintColor = theme.outputVCButtonTintColor
				self.soundToggleButton.addTarget(self, action: #selector(OutputViewController.soundToggleButtonTapped), for: .touchUpInside)
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
				self.morseTextBackgroundView.backgroundColor = UIColor.clear
				self.morseTextBackgroundView.isOpaque = false
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
				let x = layoutDirection == .leftToRight ? 0 : self.view.bounds.width
				self.morseTextLabel = UILabel(frame: CGRect(x: x, y: 0, width: 0, height: self._morseTextLabelHeight))
				self.morseTextLabel.backgroundColor = UIColor.clear
				let labelStr = layoutDirection == .leftToRight ? String(self.morse.characters.reversed()) : self.morse
				self.morseTextLabel.attributedText = getAttributedStringFrom(labelStr, withFontSize: morseFontSizeProgressBar, color: theme.morseTextProgressBarColor, bold: false)
				self.morseTextLabel.textAlignment = .left
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
			self.screenFlashView.backgroundColor = UIColor.black
			let tapGR = UITapGestureRecognizer(target: self, action: #selector(OutputViewController.outputWillStart))
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
			let playImage = UIImage(named: theme.outputPlayButtonImageName)!.withRenderingMode(.alwaysTemplate)
			self.playButton.setImage(playImage, for: UIControlState())
			self.playButton.tintColor = theme.outputVCButtonTintColor
			self.playButton.addTarget(self, action: #selector(OutputViewController.outputWillStart), for: .touchUpInside)
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
			let text = "\(LocalizedStrings.Label.wpmWithColon)\(appDelegate.outputWPM)"
			self.wpmLabel.attributedText = getAttributedStringFrom(text, withFontSize: hintLabelFontSize, color: theme.outputVCLabelTextColorEmphasized, bold: false)
			self.wpmLabel.isOpaque = false
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
			let text = "\(LocalizedStrings.Label.pitchWithColon)\(Int(appDelegate.outputPitch)) Hz"
			self.pitchLabel.attributedText = getAttributedStringFrom(text, withFontSize: hintLabelFontSize, color: theme.outputVCLabelTextColorEmphasized, bold: false)
			self.pitchLabel.isOpaque = false
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
			self.tutorial1Label.isOpaque = false
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
			self.swipeToDismissLabel.isOpaque = false
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
			self.tapToStartLabel.isOpaque = false
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self._outputPlayer.morse = self.morse
		self._outputPlayer.delegate = self
		UIView.animate(withDuration: defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				let _ = self._viewsShouldFadeOutWhenPlaying.map { $0.alpha = 1 }
		}, completion: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopPlaying()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Only support landscape when it's on an iPad
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		if isPad {
			return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscape]
		} else {
			return UIInterfaceOrientationMask.portrait
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
			tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
				action: "button_press",
				label: "Output Played",
				value: nil).build() as [AnyHashable: Any])
		} else {
			self.startPlaying()
			tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
				action: "button_press",
				label: "Output Stopped",
				value: nil).build() as [AnyHashable: Any])
		}
	}

	// *****************************
	// MARK: Outputplayer Delegate
	// *****************************

	func startSignal() {
		// Screen Flash
		self.screenFlashView.backgroundColor = UIColor.white

		// Sound
		if self._soundEnabled {
			self._toneGenerator.unmute()
		}

		// Real Flash
		if self._flashEnabled && self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.on) {
			self._hardwareInitializationQueue.async {
				if let _ = try? self._rearCamera.lockForConfiguration() {}
				self._rearCamera.torchMode = .on
				self._rearCamera.unlockForConfiguration()
			}
		}
	}

	func stopSignal() {
		// Screen Flash
		self.screenFlashView.backgroundColor = UIColor.black

		// Sound
		self._toneGenerator.mute()

		// Real Flash
		if self._rearCamera != nil && self._rearCamera.hasTorch && self._rearCamera.hasFlash && self._rearCamera.isTorchModeSupported(.on) {
			self._hardwareInitializationQueue.async {
				if let _ = try? self._rearCamera.lockForConfiguration() {}
				self._rearCamera.torchMode = .off
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
		let completionRatio = duration == 0 ? 1 : min(1, Date().timeIntervalSince(self._startDate)/duration)
		self.percentageLabel.text = "\(Int(ceil(completionRatio * 100)))%"
		let width = self.topBarView.bounds.width * CGFloat(completionRatio)
		let x = layoutDirection == .leftToRight ? 0 : self.topBarView.bounds.width - width
		self.progressBarView.frame = CGRect(x: x, y: 0, width: width, height: self._outputVCTopBarHeight)
		let sign:CGFloat = layoutDirection == .leftToRight ? 1:-1
		self.morseTextLabel.transform = CGAffineTransform(translationX: sign * CGFloat(completionRatio) * self.morseTextLabel.bounds.width, y: 0)
	}

	// *****************************
	// MARK: Private Functions
	// *****************************

	fileprivate func startPlaying() {
		// User wants to start playing
		UIView.animate(withDuration: defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				let _ = self._viewsShouldFadeOutWhenPlaying.map { $0.alpha = 0 }
				self.view.layoutIfNeeded()
				self.morseTextBackgroundView.alpha = 1.0
				self.percentageLabel.alpha = 1.0
			}) { succeed in
				self._startDate = Date()
				self._outputPlayer.start()
				self._toneGenerator.play()
				if appDelegate.brightenScreenWhenOutput {
					self._originalBrightness = UIScreen.main.brightness
					UIScreen.main.brightness = 1
				}
				self._progressTimer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(OutputViewController.updateProgress), userInfo: nil, repeats: true)
		}
		self._playing = true
	}

	fileprivate func stopPlaying() {
		// User wants to stop playing
		self._outputPlayer.stop()
		self._toneGenerator.stop()
		self._progressTimer.invalidate()
		if appDelegate.brightenScreenWhenOutput {
			UIScreen.main.brightness = self._originalBrightness
		}
		UIView.animate(withDuration: defaultAnimationDuration * animationDurationScalar,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				let _ = self._viewsShouldFadeOutWhenPlaying.map { $0.alpha = 1 }
				self.morseTextBackgroundView.alpha = 0.0
				self.percentageLabel.alpha = 0.0
				let x = layoutDirection == .leftToRight ? 0 : self.topBarView.bounds.width
				self.progressBarView.frame = CGRect(x: x, y: 0, width: 0, height: self._outputVCTopBarHeight)
			}) { succeed in
				self.percentageLabel.text = "0%"
				self.morseTextLabel.transform = CGAffineTransform.identity
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
