//
//  HomeTopSectionViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/11/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import AVFoundation

// *****************************
// MARK: Localized Strings
// *****************************

class HomeTopSectionViewController: UIViewController, UITextViewDelegate, MorseTransmitterDelegate {

	// *****************************
	// MARK: Views
	// *****************************

	// Top bar views
	var statusBarView: UIView!
	var topBarView: UIView!
	var topBarLabelText: UILabel!
	var topBarLabelMorse: UILabel!

	// Text views
	var textBackgroundView: UIView!
	var inputTextView: UITextView!
	var outputTextView: UITextView!
	var textBoxTapFeedBackView: UIView!

	var breakLineView:UIView!

	// Button
	var roundButtonView: RoundButtonView!
	var backButton: BackButton!
	var keyboardButton: UIButton!
	var microphoneButton:UIButton!

	// *****************************
	// MARK: UI Related Variables
	// *****************************

	var keyboardButtonViewHeight:CGFloat {
		return topBarHeight
	}

	fileprivate var roundButtonMargin:CGFloat {
		return 8
	}

	fileprivate var roundButtonRadius:CGFloat {
		return topBarHeight/2.0 - self.roundButtonMargin
	}

	fileprivate var backButtonWidth:CGFloat {
		return topBarHeight
	}

	fileprivate var isDuringInput:Bool {
		return self.homeViewController.isDuringInput
	}

	fileprivate var _keyboardHeight:CGFloat = 0

	// *****************************
	// MARK: Data Related Variables
	// *****************************

	let transmitter = MorseTransmitter()

	var isDirectionEncode:Bool = true {
		didSet {
			self.inputTextView.attributedText = self.attributedHintTextInput
			self.outputTextView.attributedText = self.attributedHintTextOutput
		}
	}

	fileprivate var hintTextInput:String {
		//		if self.isDirectionEncode {
		//			return "Touch to type"
		//		} else {
		//			return "___ ___   ___ ___ ___   . ___ .   . . .   ."
		//		}
		return "  " + LocalizedStrings.Hint.textInputHint
	}

	// This is deprecatec code, but may be useful in the future
	fileprivate var hintTextOutput:String {
		//		if self.isDirectionEncode {
		//			return "___ ___   ___ ___ ___   . ___ .   . . .   ."
		//		} else {
		//			return "Touch to type"
		//		}
		return ""
	}

	fileprivate var attributedHintTextInput:NSMutableAttributedString {
		return NSMutableAttributedString(string: self.hintTextInput, attributes:
			[NSFontAttributeName: UIFont.systemFont(ofSize: textViewInputFontSize),
				NSForegroundColorAttributeName: theme.textViewHintTextColor])
	}

	fileprivate var attributedHintTextOutput:NSMutableAttributedString {
		return NSMutableAttributedString(string: self.hintTextOutput, attributes:
			[NSFontAttributeName: UIFont.systemFont(ofSize: textViewOutputFontSize),
				NSForegroundColorAttributeName: theme.textViewHintTextColor])
	}

	// *****************************
	// MARK: Other Variables
	// *****************************

	// Return the home view controller this one is embedded in
	var homeViewController:HomeViewController! {
		return self.parent as! HomeViewController
	}

	// *****************************
	// MARK: MVC Lifecycle
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = appDelegate.theme.textViewBackgroundColor

		// *****************************
		// Configure Status Bar View
		// *****************************

		if self.statusBarView == nil {
			self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: statusBarHeight))
			self.statusBarView.backgroundColor = appDelegate.theme.statusBarBackgroundColor
			self.view.addSubview(self.statusBarView)
            self.statusBarView.snp_makeConstraints({ (make) -> Void in
				make.top.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(statusBarHeight)
			})
		}

		// *****************************
		// Configure Top Bar View
		// *****************************

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: self.view.bounds.width, height: topBarHeight))
			self.topBarView.backgroundColor = appDelegate.theme.topBarBackgroundColor
			self.view.addSubview(topBarView)
			
			// Text label
			self.topBarLabelText = UILabel(frame: CGRect(x: 0, y: 0, width: self.topBarView.bounds.width/2.0 - self.roundButtonRadius - self.roundButtonMargin, height: topBarHeight))
			self.topBarLabelText.textAlignment = .center
			self.topBarLabelText.tintColor = appDelegate.theme.topBarLabelTextColor
			self.topBarLabelText.attributedText = NSAttributedString(string: LocalizedStrings.Label.topBarTextLabel, attributes:
				[NSFontAttributeName: UIFont.boldSystemFont(ofSize: 23),
					NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
			self.topBarView.addSubview(self.topBarLabelText)

			// Morse label
			self.topBarLabelMorse = UILabel(frame: CGRect(x: self.topBarView.bounds.width/2.0 + self.roundButtonRadius + self.roundButtonMargin, y: 0, width: self.topBarView.bounds.width/2.0 - self.roundButtonRadius - self.roundButtonMargin, height: topBarHeight))
			self.topBarLabelMorse.textAlignment = .center
			self.topBarLabelMorse.tintColor = appDelegate.theme.topBarLabelTextColor
			self.topBarLabelMorse.attributedText = NSAttributedString(string: LocalizedStrings.Label.topBarMorseLabel, attributes:
				[NSFontAttributeName: UIFont.boldSystemFont(ofSize: 23),
					NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
			self.topBarView.addSubview(self.topBarLabelMorse)

			// Add round button
			self.roundButtonView = RoundButtonView(origin: CGPoint(x: self.topBarView.bounds.width/2.0 - self.roundButtonRadius, y: self.roundButtonMargin), radius: self.roundButtonRadius)
			let tapGR = UITapGestureRecognizer(target: self, action: #selector(roundButtonTapped(_:)))
			self.roundButtonView.addGestureRecognizer(tapGR)
			self.topBarView.addSubview(self.roundButtonView)

			// Add cancel button
			self.backButton = BackButton(origin: CGPoint(x: 0, y: 0), width: self.backButtonWidth)
			self.backButton.addTarget(self, action: #selector(inputCancelled(_:)), for: .touchUpInside)
			self.topBarView.addSubview(self.backButton)

            self.backButton.snp_makeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.width.equalTo(topBarHeight)
				make.height.equalTo(self.backButton.snp_width)
			})

			self.backButton.disappearWithDuration(0)

			// Configure constraints
            self.topBarView.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.statusBarView.snp_bottom)
				make.leading.equalTo(self.view).offset(0)
				make.trailing.equalTo(self.view).offset(0)
				make.height.equalTo(topBarHeight)
			})

            self.topBarLabelText.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

            self.topBarLabelMorse.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

            self.roundButtonView.snp_makeConstraints({ (make) -> Void in
				make.centerX.equalTo(self.topBarView)
				make.centerY.equalTo(self.topBarView)
				make.height.equalTo(self.roundButtonRadius * 2)
				make.width.equalTo(self.roundButtonView.snp_height)
			})
		}

		// *******************************
		// Configure Text Background View
		// *******************************

		if self.textBackgroundView == nil {
			self.textBackgroundView = UIView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: textBackgroundViewHeight))
			self.textBackgroundView.backgroundColor = appDelegate.theme.textViewBackgroundColor
			self.textBackgroundView.layer.borderColor = UIColor.clear.cgColor
			self.textBackgroundView.layer.borderWidth = 0
			self.view.addSubview(self.textBackgroundView)

			self.textBackgroundView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.trailing.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.bottom.equalTo(self.view)
			}
		}

		// *****************************
		// Configure Input Text View
		// *****************************

		if self.inputTextView == nil {
			self.inputTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.textBackgroundView.bounds.width, height: textBackgroundViewHeight/2.0))
			self.inputTextView.backgroundColor = UIColor.clear
			self.inputTextView.isOpaque = false
			self.inputTextView.keyboardType = .asciiCapable
			self.inputTextView.returnKeyType = .done
			self.inputTextView.attributedText = self.attributedHintTextInput
			self.inputTextView.delegate = self
			self.inputTextView.layer.borderColor = UIColor.clear.cgColor
			self.inputTextView.layer.borderWidth = 0
			self.inputTextView.autocorrectionType = .default
			self.inputTextView.keyboardAppearance = theme.keyboardAppearance
			self.inputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
			self.textBackgroundView.addSubview(self.inputTextView)

			self.inputTextView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.height.equalTo(textBackgroundViewHeight/2.0)
			}
		}

		// *****************************
		// Configure Output Text View
		// *****************************

		if self.outputTextView == nil {
			self.outputTextView = UITextView(frame: CGRect(x: 0, y: textBackgroundViewHeight/2.0, width: self.view.bounds.width, height: textBackgroundViewHeight/2.0))
			self.outputTextView.backgroundColor = UIColor.clear
			self.outputTextView.isOpaque = false
			self.outputTextView.isEditable = false
			self.outputTextView.attributedText = self.attributedHintTextOutput
			self.outputTextView.layer.borderColor = UIColor.clear.cgColor
			self.outputTextView.layer.borderWidth = 0
			// This gestureRecognizer is here to fix a bug where double tapping on outputTextView would resign inputTextView as first responder.
			let disableDoubleTapGR = UITapGestureRecognizer()
			disableDoubleTapGR.numberOfTapsRequired = 2
			self.outputTextView.addGestureRecognizer(disableDoubleTapGR)
			self.outputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
			self.textBackgroundView.addSubview(self.outputTextView)

			self.outputTextView.snp_makeConstraints { (make) -> Void in
				make.trailing.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.height.equalTo(textBackgroundViewHeight/2.0)
			}
		}

		// *****************************
		// Configure Line Break View
		// *****************************

		if self.breakLineView == nil {
			self.breakLineView = UIView(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height, width: self.textBackgroundView.bounds.width, height: 1.0))
			self.breakLineView.backgroundColor = theme.textViewBreakLineColor
			self.breakLineView.isHidden = true
			self.textBackgroundView.addSubview(self.breakLineView)

            self.breakLineView.snp_remakeConstraints({ (make) -> Void in
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.textBackgroundView)
				make.height.equalTo(1.0)
			})
		}

		// *********************************
		// Configure Text Tap Feedback View
		// *********************************

		if self.textBoxTapFeedBackView == nil {
			self.textBoxTapFeedBackView = UIView(frame: CGRect(x: 0, y: 0, width: self.textBackgroundView.bounds.width, height: self.textBackgroundView.bounds.height))
			self.textBoxTapFeedBackView.backgroundColor = UIColor.clear
			self.textBoxTapFeedBackView.layer.borderColor = UIColor.clear.cgColor
			self.textBoxTapFeedBackView.layer.borderWidth = 0
			self.textBoxTapFeedBackView.isOpaque = false
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeTopSectionViewController.textViewTapped(_:)))
			tapGestureRecognizer.cancelsTouchesInView = true
			self.textBoxTapFeedBackView.addGestureRecognizer(tapGestureRecognizer)
			self.textBackgroundView.addSubview(self.textBoxTapFeedBackView)

            self.textBoxTapFeedBackView.snp_makeConstraints({ (make) -> Void in
				make.edges.equalTo(self.textBackgroundView)
			})
		}

		// *********************************
		// Configure Keyboard Button View
		// *********************************

		if self.keyboardButton == nil {
			self.keyboardButton = UIButton(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height - self.keyboardButtonViewHeight, width: self.textBackgroundView.bounds.width, height: self.keyboardButtonViewHeight))
			self.keyboardButton.backgroundColor = appDelegate.theme.keyboardButtonBackgroundColor
			self.keyboardButton.isOpaque = false
			self.keyboardButton.alpha = 0
			let image = UIImage(named: theme.keyboardIconImageName)!.withRenderingMode(.alwaysTemplate)
			self.keyboardButton.setImage(image, for: UIControlState())
			self.keyboardButton.tintColor = theme.keyboardButtonTintColor
			self.keyboardButton.addTarget(self, action: #selector(keyboardButtonTapped), for: .touchUpInside)
			let tapGR = UITapGestureRecognizer(target: self, action: #selector(micOrKeyboardButtonTapped(_:)))
			tapGR.cancelsTouchesInView = false
			self.keyboardButton.addGestureRecognizer(tapGR)
			self.view.addSubview(self.keyboardButton)

            self.keyboardButton.snp_makeConstraints({ (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})
		}

		// *********************************
		// Configure Morse Microphone Button View
		// *********************************
		if self.microphoneButton == nil {
			self.microphoneButton = UIButton(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height - self.keyboardButtonViewHeight, width: self.textBackgroundView.bounds.width, height: self.keyboardButtonViewHeight))
			self.microphoneButton.backgroundColor = appDelegate.theme.keyboardButtonBackgroundColor
			self.microphoneButton.isOpaque = false
			self.microphoneButton.alpha = 0
			let image = UIImage(named: theme.microphoneIconImageName)!.withRenderingMode(.alwaysTemplate)
			self.microphoneButton.setImage(image, for: UIControlState())
			self.microphoneButton.tintColor = theme.keyboardButtonTintColor
			self.microphoneButton.contentMode = .scaleAspectFit
			self.microphoneButton.addTarget(self.homeViewController, action: #selector(HomeTopSectionViewController.microphoneButtonTapped), for: .touchUpInside)
			let tapGR = UITapGestureRecognizer(target: self, action: #selector(HomeTopSectionViewController.micOrKeyboardButtonTapped(_:)))
			tapGR.cancelsTouchesInView = false
			self.microphoneButton.addGestureRecognizer(tapGR)
			self.view.addSubview(self.microphoneButton)
            self.microphoneButton.snp_makeConstraints({ (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})
		}

        NotificationCenter.default.addObserver(self, selector: #selector(HomeTopSectionViewController.updateColorWithAnimation), name: NSNotification.Name(rawValue: themeDidChangeNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(HomeTopSectionViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }

	func keyboardWasShown(_ notification:Notification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
		self._keyboardHeight = min(keyboardSize.height, keyboardSize.width)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	// *****************************
	// MARK: User Interaction Handler
	// *****************************

	func textViewTapped(_ gestureRecognizer:UITapGestureRecognizer) {
		let tracker = GAI.sharedInstance().defaultTracker
		tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
			action: "button_press",
			label: "Text View Tapped",
			value: nil).build() as! [AnyHashable: Any])
		if self.isDirectionEncode {
			tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "transmitter_action",
				action: "encode",
				label: "Encoding Text",
				value: nil).build() as! [AnyHashable: Any])
		} else {
			tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "transmitter_action",
				action: "encode",
				label: "Decoding Morse",
				value: nil).build() as! [AnyHashable: Any])
		}
		// Play sound effect
		if !appDelegate.interactionSoundDisabled {
			// TODO: Not working.
			if let path = Bundle.main.path(forResource: "Tock", ofType: "caf") {
				let tockURL = URL(fileURLWithPath: path)
				do {
					let audioPlayer = try AVAudioPlayer(contentsOf: tockURL)
					audioPlayer.play()
				} catch {
					NSLog("Tap feedback sound on text view play failed.")
				}
			} else {
				NSLog("Can't find \"Tock.caf\" file.")
			}
		}

		self.textBoxTapFeedBackView.isHidden = true
		if !self.isDuringInput {
			self.inputTextView.becomeFirstResponder()
			self.animateAndLayoutUIForInputStart()
			self.textBackgroundView.triggerTapFeedBack(atLocation: gestureRecognizer.location(in: self.textBackgroundView), withColor: appDelegate.theme.textViewTapFeedbackColor, duration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar)
		}
		self.homeViewController.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.homeViewController.scrollView.bounds.width, height: 1), animated: true)
	}

	func roundButtonTapped(_ gestureRecognizer:UITapGestureRecognizer?) {
		// Switch Direction
		switch self.roundButtonView.buttonAction {
		case .switch:
			self.isDirectionEncode = !self.isDirectionEncode
		}

		// If there is a gesture recognizer, animate round button
		if gestureRecognizer != nil {
			let tracker = GAI.sharedInstance().defaultTracker
			tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
				action: "button_press",
				label: "Round Button Tapped",
				value: nil).build() as! [AnyHashable: Any])
			let tapLocation = gestureRecognizer!.location(in: self.roundButtonView)
			if self.roundButtonView.bounds.contains(tapLocation) {
				let originalTransform = self.roundButtonView.transform

				// Animations for button
				self.roundButtonView.triggerTapFeedBack(atLocation: tapLocation, withColor: appDelegate.theme.roundButtonTapFeedbackColor, duration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar)
				self.roundButtonView.rotateBackgroundImageWithDuration(TAP_FEED_BACK_DURATION/2.0)
				UIView.animate(withDuration: TAP_FEED_BACK_DURATION/5.0 * appDelegate.animationDurationScalar,
					delay: 0.0,
					options: .curveEaseIn,
					animations: {
						self.roundButtonView.transform = self.roundButtonView.transform.scaledBy(x: 1.15, y: 1.15)
						self.roundButtonView.addMDShadow(withDepth: theme.roundButtonMDShadowLevelTapped)
					}) { succeed in
						UIView.animate(withDuration: TAP_FEED_BACK_DURATION/5.0 * appDelegate.animationDurationScalar,
							delay: 0.0,
							options: .curveEaseOut,
							animations: {
								self.roundButtonView.transform = originalTransform
								self.roundButtonView.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
							}, completion: nil)
				}
				
		}

		// Switch text and morse label
		if self.isDirectionEncode {
			self.topBarLabelText.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

			self.keyboardButton.snp_remakeConstraints({ (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})

			self.microphoneButton.snp_remakeConstraints({ (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})

//			self.keyboardButton.snp_updateConstraints(closure: { (make) -> Void in
//				make.leading.equalTo(self.textBackgroundView)
//			})
//
//			self.morseMicrophoneButton.snp_updateConstraints(closure: { (make) -> Void in
//				make.trailing.equalTo(self.textBackgroundView)
//			})
		} else {
			self.topBarLabelText.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

			self.keyboardButton.snp_remakeConstraints({ (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView.snp_centerX)
				make.trailing.equalTo(self.textBackgroundView)
			})

			self.microphoneButton.snp_remakeConstraints({ (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})
		}

		UIView.animate(withDuration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
			delay: 0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 0.8,
			options: UIViewAnimationOptions(),
			animations: {
				self.topBarView.layoutIfNeeded()
				self.keyboardButton.alpha = 0
				if self.isDirectionEncode {
					self.microphoneButton.alpha = 0
				} else {
					self.microphoneButton.alpha = 1
				}
			}, completion: nil)
		}
	}

	// Microphone button or keyboard button feedback
	func micOrKeyboardButtonTapped(_ gestureRecognizer:UITapGestureRecognizer) {
		let view = gestureRecognizer.view
		if view != nil {
			let location = gestureRecognizer.location(in: view!)
			view!.triggerTapFeedBack(atLocation: location, withColor: theme.textViewTapFeedbackColor)
		}
	}

	func keyboardButtonTapped() {
		let tracker = GAI.sharedInstance().defaultTracker
		tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
			action: "button_press",
			label: "Keyboard Button Tapped",
			value: nil).build() as! [AnyHashable: Any])
		self.inputTextView.becomeFirstResponder()
		self.animateAndLayoutUIForInputStart()
	}

	func microphoneButtonTapped() {
		let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
			action: "button_press",
			label: "Microphone Button Tapped",
            value: nil).build() as! [AnyHashable: Any])
		self.animateAndLayoutUIForInputStart()
		self.inputTextView.isUserInteractionEnabled = false
	}

	func audioPlotTapped(_ gestureRecognizer:UITapGestureRecognizer) {
		let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
			action: "button_press",
			label: "Text View Tapped",
            value: nil).build() as! [AnyHashable: Any])
		let text = self.outputTextView.text
		let morse = self.inputTextView.text
		if self.inputTextView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" && self.outputTextView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
            self.homeViewController.addCardViewWithText(text!, morse: morse!, textOnTop: self.isDirectionEncode, animateWithDuration: 0.3)
			let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "transmitter_action",
				action: "card_added",
				label: "Card Added",
                value: nil).build() as! [AnyHashable: Any])
		}
		self.animateAndLayoutUIForInputEnd()
	}

	// *****************************
	// MARK: Text View Delegate
	// *****************************

	func textViewDidChange(_ textView: UITextView) {
		var outputText:String?
		let setupOutputTextAttribute = {
			self.outputTextView.attributedText = getAttributedStringFrom(outputText, withFontSize: textViewOutputFontSize, color: theme.textViewOutputTextColor)
			if outputText != nil {
				self.outputTextView.scrollRangeToVisible(NSMakeRange(outputText!.characters.distance(from: outputText!.startIndex, to: outputText!.endIndex), 0))
			}
		}
		if self.isDirectionEncode {
			self.transmitter.text = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
			self.transmitter.getFutureMorse {
				outputText = $0
				setupOutputTextAttribute()
			}
		} else {
			self.transmitter.morse = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
			self.transmitter.getFutureText {
				outputText = $0
				setupOutputTextAttribute()
			}
		}


		// Change textview height
//		let topTextHeight = max(textView.attributedText.size().height, textBackgroundViewHeight/2.0)
//		let bottomTextHeight = max(self.outputTextView.attributedText.size().height, textBackgroundViewHeight/2.0)
//		let totalHeight = max(textBackgroundViewHeight, min(self.homeViewController.view.bounds.height - self._keyboardHeight - self.topBarView.bounds.height - self.statusBarView.bounds.height, topTextHeight + bottomTextHeight)) + self.statusBarView.bounds.height + self.topBarView.bounds.height
//		self.inputTextView.snp_remakeConstraints { (make) -> Void in
//			make.top.equalTo(self.textBackgroundView)
//			make.trailing.equalTo(self.textBackgroundView)
//			make.leading.equalTo(self.textBackgroundView)
//			make.height.equalTo(textBackgroundViewHeight).multipliedBy(0.5)
//		}
//		self.outputTextView.snp_makeConstraints { (make) -> Void in
//			make.trailing.equalTo(self.textBackgroundView)
//			make.bottom.equalTo(self.textBackgroundView)
//			make.leading.equalTo(self.textBackgroundView)
//			make.height.equalTo(bottomTextHeight)
//		}
//		self.homeViewController.topSectionContainerView.snp_remakeConstraints { (make) -> Void in
//			make.top.equalTo(self.homeViewController.view)
//			make.trailing.equalTo(self.homeViewController.view)
//			make.leading.equalTo(self.homeViewController.view)
//			make.height.equalTo(totalHeight)
//		}
//		print("\(topTextHeight) \(bottomTextHeight) \(totalHeight)")
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			let text = self.isDirectionEncode ? self.inputTextView.text : self.outputTextView.text
			let morse = self.isDirectionEncode ? self.outputTextView.text : self.inputTextView.text
			if self.inputTextView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" && self.outputTextView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                self.homeViewController.addCardViewWithText(text!, morse: morse!, textOnTop: self.isDirectionEncode, animateWithDuration: 0.3)
			}
			textView.resignFirstResponder()
			self.animateAndLayoutUIForInputEnd()

			return false
		}
		return true
	}

	// *****************************
	// MARK: Transmitter Delegate
	// *****************************

	func transmitterContentDidChange(_ text: String, morse: String) {
		// Set text.
		DispatchQueue.main.async {
			self.inputTextView.attributedText = getAttributedStringFrom(morse.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), withFontSize: textViewInputFontSize, color: theme.textViewInputTextColor)
			self.outputTextView.attributedText = getAttributedStringFrom(text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), withFontSize: textViewOutputFontSize, color: theme.textViewOutputTextColor)
			self.inputTextView.scrollRangeToVisible(NSMakeRange(morse.characters.distance(from: morse.startIndex, to: morse.endIndex), 0))
			self.outputTextView.scrollRangeToVisible(NSMakeRange(text.characters.distance(from: text.startIndex, to: text.endIndex), 0))
		}
	}

	// *****************************
	// MARK: Other Methods
	// *****************************

	func inputCancelled(_ sender:AnyObject) {
		let tracker = GAI.sharedInstance().defaultTracker
		if sender === self.backButton {
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
				action: "button_press",
				label: "Cancel Button Tapped",
                value: nil).build() as! [AnyHashable: Any])
		} else if sender === self.homeViewController.scrollViewOverlay {
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
				action: "button_press",
				label: "Scrollview Overlay Tapped",
                value: nil).build() as! [AnyHashable: Any])
		}
		if self.inputTextView.isFirstResponder {
			self.inputTextView.resignFirstResponder()
		}
		self.animateAndLayoutUIForInputEnd()
	}

	fileprivate func animateAndLayoutUIForInputStart() {
//		var delayTime:NSTimeInterval = 0
//		if self.homeViewController.scrollView.contentOffset > 0 {
//
//		}
		self.homeViewController.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.homeViewController.scrollView.bounds.width, height: 1), animated: true)

		let animationDuration = defaultAnimationDuration/3.0

		// Text view stuff
		self.inputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: textViewInputFontSize, color: theme.textViewInputTextColor)
		self.outputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: textViewOutputFontSize, color: theme.textViewOutputTextColor)
		self.textBoxTapFeedBackView.isHidden = true
		self.textBoxTapFeedBackView.isUserInteractionEnabled = false

		// Hide round button
		UIView.animate(withDuration: animationDuration * appDelegate.animationDurationScalar,
			delay: 0,
			options: .curveEaseOut,
			animations: {
				self.microphoneButton.alpha = 0
				self.keyboardButton.alpha = 0
			}, completion: nil)
		self.roundButtonView.disappearWithAnimationType([.scale, .fade], duration: animationDuration) {
			// Move text and morse label
			let labelWidth = self.topBarLabelText.bounds.width
			if self.isDirectionEncode {
                self.topBarLabelText.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.centerX.equalTo(self.topBarView)
				})
                self.topBarLabelMorse.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.leading.equalTo(self.topBarView.snp_trailing)
				})
			} else {
                self.topBarLabelText.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.leading.equalTo(self.topBarView.snp_trailing)
				})
                self.topBarLabelMorse.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.centerX.equalTo(self.topBarView)
				})
			}

			self.breakLineView.isHidden = false
            self.breakLineView.snp_remakeConstraints({ (make) -> Void in
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.inputTextView)
				make.height.equalTo(1.0)
			})
			// Set scrollViewOverlay's background color based on the type of input.
			self.homeViewController.scrollViewOverlay.backgroundColor = self.homeViewController.micInputSectionContainerView == nil ? theme.scrollViewOverlayColor : UIColor.clear

			UIView.animate(withDuration: animationDuration * appDelegate.animationDurationScalar,
				delay: animationDuration,
				//			usingSpringWithDamping: 0.5,
				//			initialSpringVelocity: 0.8,
				options: .curveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.homeViewController.scrollViewOverlay.alpha = 1
					self.homeViewController.micInputSectionContainerView?.alpha = 1
					self.homeViewController.scrollViewSnapshotImageView?.alpha = 1
					self.homeViewController.topSectionContainerView.addMDShadow(withDepth: 3)
				}) { succeed in
					// Show cancel button
					self.backButton.appearWithDuration(animationDuration)
					// If the top section is hidden, and the microphone button is tapped, blured screenshot will  not beupdated correctly.
					// The following code updates blured image if that happens.
					self.homeViewController.updateScrollViewBlurImage()
			}
		}
		// Collapse expanded card view if there is one
		self.homeViewController.collapseCurrentExpandedCard()
		self.homeViewController.restoreCurrentFlippedCard()
	}

	fileprivate func animateAndLayoutUIForInputEnd() {
		let animationDuration = TAP_FEED_BACK_DURATION/3.0
		// Hide cancel button
		self.backButton.disappearWithDuration(animationDuration) {
			// Move text and morse label
			if self.isDirectionEncode {
                self.topBarLabelText.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
				})

                self.topBarLabelMorse.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.trailing.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
				})
			} else {
                self.topBarLabelText.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.trailing.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
				})

                self.topBarLabelMorse.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
				})
			}

			// Text view stuff
			self.textBoxTapFeedBackView.isHidden = false
			self.textBoxTapFeedBackView.isUserInteractionEnabled = true
			self.inputTextView.isUserInteractionEnabled = true
			self.outputTextView.text = nil
			self.inputTextView.attributedText = self.attributedHintTextInput
			self.outputTextView.attributedText = self.attributedHintTextOutput
            self.breakLineView.snp_remakeConstraints({ (make) -> Void in
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.textBackgroundView)
				make.height.equalTo(1.0)
			})

			UIView.animate(withDuration: animationDuration * appDelegate.animationDurationScalar,
				delay: 0,
				//			usingSpringWithDamping: 0.5,
				//			initialSpringVelocity: 0.8,
				options: .curveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.homeViewController.scrollViewOverlay.alpha = 0
					self.homeViewController.micInputSectionContainerView?.alpha = 0
					self.homeViewController.scrollViewSnapshotImageView?.alpha = 0
					self.homeViewController.topSectionContainerView.addMDShadow(withDepth: 2)
				}) { succeed in
					self.breakLineView.isHidden = true
					// If the input frequency is set to be detected automatically, restore the min frequency.
					self.homeViewController.micInputSectionViewController?.microphone.stopFetchingAudio()
					self.homeViewController.micInputSectionContainerView?.removeFromSuperview()
					self.homeViewController.scrollViewSnapshotImageView?.removeFromSuperview()
					self.homeViewController.micInputSectionContainerView = nil
					self.homeViewController.micInputSectionViewController = nil
					self.homeViewController.scrollViewSnapshotImageView = nil
					self.inputTextView.attributedText = self.attributedHintTextInput
					self.outputTextView.attributedText = self.attributedHintTextOutput
					// Show round button
					self.roundButtonView.appearWithAnimationType([.scale, .fade], duration: animationDuration)
					UIView.animate(withDuration: animationDuration * appDelegate.animationDurationScalar,
						delay: animationDuration,
						options: .curveEaseOut,
						animations: {
							if !self.isDirectionEncode {
								self.microphoneButton.alpha = 1
								self.keyboardButton.alpha = 0
							}
						}, completion: nil)
			}
		}
	}

	/**
	Responsible for updating the UI when user changes the theme.
	- Parameters:
		- animated: A boolean determines if the theme change should be animated.
	*/
	func updateColor(animated:Bool = true) {
		self.inputTextView.keyboardAppearance = theme.keyboardAppearance
		self.roundButtonView.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animate(withDuration: duration,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				self.inputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.outputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.statusBarView.backgroundColor = theme.statusBarBackgroundColor
				self.topBarView.backgroundColor = theme.topBarBackgroundColor
				self.roundButtonView.backgroundColor = theme.roundButtonBackgroundColor
				self.roundButtonView.backgroundImageView.tintColor = theme.buttonWithAccentBackgroundTintColor
				self.roundButtonView.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
				self.topBarLabelText.textColor = theme.topBarLabelTextColor
				self.topBarLabelMorse.textColor = theme.topBarLabelTextColor
				self.textBackgroundView.backgroundColor = theme.textViewBackgroundColor
				self.breakLineView.backgroundColor = theme.textViewBreakLineColor
				self.keyboardButton.backgroundColor = theme.keyboardButtonBackgroundColor
				self.keyboardButton.tintColor = theme.keyboardButtonTintColor
				self.microphoneButton.backgroundColor = theme.keyboardButtonBackgroundColor
				self.microphoneButton.tintColor = theme.keyboardButtonTintColor
				if self.isDuringInput {
					self.inputTextView.textColor = theme.textViewInputTextColor
					self.outputTextView.textColor = theme.textViewOutputTextColor
				} else {
					self.inputTextView.textColor = theme.textViewHintTextColor
				}
			}, completion: nil)
	}

	// This method is for using selector
	func updateColorWithAnimation() {
		self.updateColor(animated: true)
	}

	// This method is for using selector
	func updateColorWithoutAnimation() {
		self.updateColor()
	}
}
