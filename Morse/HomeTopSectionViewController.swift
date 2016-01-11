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
	var cancelButton: CancelButton!
	var keyboardButton: UIButton!
	var microphoneButton:UIButton!

	// *****************************
	// MARK: UI Related Variables
	// *****************************

	let textBackgroundViewHeight:CGFloat = 140

	var keyboardButtonViewHeight:CGFloat {
		return topBarHeight
	}

	private var roundButtonMargin:CGFloat {
		return 8
	}

	private var roundButtonRadius:CGFloat {
		return topBarHeight/2.0 - self.roundButtonMargin
	}

	private var cancelButtonWidth:CGFloat {
		return topBarHeight
	}

	private var isDuringInput:Bool {
		return self.homeViewController.isDuringInput
	}

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

	private var hintTextInput:String {
		//		if self.isDirectionEncode {
		//			return "Touch to type"
		//		} else {
		//			return "___ ___   ___ ___ ___   . ___ .   . . .   ."
		//		}
		return "  " + LocalizedStrings.Hint.textInputHint
	}

	// This is deprecatec code, but may be useful in the future
	private var hintTextOutput:String {
		//		if self.isDirectionEncode {
		//			return "___ ___   ___ ___ ___   . ___ .   . . .   ."
		//		} else {
		//			return "Touch to type"
		//		}
		return ""
	}

	private var attributedHintTextInput:NSMutableAttributedString {
		return NSMutableAttributedString(string: self.hintTextInput, attributes:
			[NSFontAttributeName: UIFont.systemFontOfSize(textViewInputFontSize),
				NSForegroundColorAttributeName: theme.textViewHintTextColor])
	}

	private var attributedHintTextOutput:NSMutableAttributedString {
		return NSMutableAttributedString(string: self.hintTextOutput, attributes:
			[NSFontAttributeName: UIFont.systemFontOfSize(textViewOutputFontSize),
				NSForegroundColorAttributeName: theme.textViewHintTextColor])
	}

	// *****************************
	// MARK: Other Variables
	// *****************************

	// Return the home view controller this one is embedded in
	var homeViewController:HomeViewController! {
		return self.parentViewController as! HomeViewController
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
			self.statusBarView.snp_makeConstraints(closure: { (make) -> Void in
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
			self.topBarLabelText.textAlignment = .Center
			self.topBarLabelText.tintColor = appDelegate.theme.topBarLabelTextColor
			self.topBarLabelText.attributedText = NSAttributedString(string: LocalizedStrings.Label.topBarTextLabel, attributes:
				[NSFontAttributeName: UIFont.boldSystemFontOfSize(23),
					NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
			self.topBarView.addSubview(self.topBarLabelText)

			// Morse label
			self.topBarLabelMorse = UILabel(frame: CGRect(x: self.topBarView.bounds.width/2.0 + self.roundButtonRadius + self.roundButtonMargin, y: 0, width: self.topBarView.bounds.width/2.0 - self.roundButtonRadius - self.roundButtonMargin, height: topBarHeight))
			self.topBarLabelMorse.textAlignment = .Center
			self.topBarLabelMorse.tintColor = appDelegate.theme.topBarLabelTextColor
			self.topBarLabelMorse.attributedText = NSAttributedString(string: LocalizedStrings.Label.topBarMorseLabel, attributes:
				[NSFontAttributeName: UIFont.boldSystemFontOfSize(23),
					NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
			self.topBarView.addSubview(self.topBarLabelMorse)

			// Add round button
			self.roundButtonView = RoundButtonView(origin: CGPoint(x: self.topBarView.bounds.width/2.0 - self.roundButtonRadius, y: self.roundButtonMargin), radius: self.roundButtonRadius)
			let tapGR = UITapGestureRecognizer(target: self, action: "roundButtonTapped:")
			self.roundButtonView.addGestureRecognizer(tapGR)
			self.topBarView.addSubview(self.roundButtonView)

			// Add cancel button
			self.cancelButton = CancelButton(origin: CGPoint(x: 0, y: 0), width: self.cancelButtonWidth)
			self.cancelButton.addTarget(self, action: "inputCancelled", forControlEvents: .TouchUpInside)
			self.topBarView.addSubview(self.cancelButton)

			self.cancelButton.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.width.equalTo(topBarHeight)
				make.height.equalTo(self.cancelButton.snp_width)
			})

			self.cancelButton.disappearWithDuration(0)

			// Configure constraints
			self.topBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.statusBarView.snp_bottom)
				make.leading.equalTo(self.view).offset(0)
				make.trailing.equalTo(self.view).offset(0)
				make.height.equalTo(topBarHeight)
			})

			self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

			self.roundButtonView.snp_makeConstraints(closure: { (make) -> Void in
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
			self.textBackgroundView = UIView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: self.textBackgroundViewHeight))
			self.textBackgroundView.backgroundColor = appDelegate.theme.textViewBackgroundColor
			self.textBackgroundView.layer.borderColor = UIColor.clearColor().CGColor
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
			self.inputTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.textBackgroundView.bounds.width, height: self.textBackgroundViewHeight/2.0))
			self.inputTextView.backgroundColor = UIColor.clearColor()
			self.inputTextView.opaque = false
			self.inputTextView.keyboardType = .ASCIICapable
			self.inputTextView.returnKeyType = .Done
			self.inputTextView.attributedText = self.attributedHintTextInput
			self.inputTextView.delegate = self
			self.inputTextView.layer.borderColor = UIColor.clearColor().CGColor
			self.inputTextView.layer.borderWidth = 0
			self.inputTextView.autocorrectionType = .Default
			self.inputTextView.keyboardAppearance = theme.keyboardAppearance
			self.inputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
			self.textBackgroundView.addSubview(self.inputTextView)

			self.inputTextView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.height.equalTo(self.textBackgroundView.snp_height).multipliedBy(0.5)
			}
		}

		// *****************************
		// Configure Output Text View
		// *****************************

		if self.outputTextView == nil {
			self.outputTextView = UITextView(frame: CGRect(x: 0, y: self.textBackgroundViewHeight/2.0, width: self.view.bounds.width, height: self.textBackgroundViewHeight/2.0))
			self.outputTextView.backgroundColor = UIColor.clearColor()
			self.outputTextView.opaque = false
			self.outputTextView.editable = false
			self.outputTextView.attributedText = self.attributedHintTextOutput
			self.outputTextView.layer.borderColor = UIColor.clearColor().CGColor
			self.outputTextView.layer.borderWidth = 0
			// This gestureRecognizer is here to fix a bug where double tapping on outputTextView would resign inputTextView as first responder.
			let disableDoubleTapGR = UITapGestureRecognizer(target: nil, action: "")
			disableDoubleTapGR.numberOfTapsRequired = 2
			self.outputTextView.addGestureRecognizer(disableDoubleTapGR)
			self.outputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
			self.textBackgroundView.addSubview(self.outputTextView)

			self.outputTextView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.inputTextView.snp_bottom)
				make.trailing.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
			}
		}

		// *****************************
		// Configure Line Break View
		// *****************************

		if self.breakLineView == nil {
			self.breakLineView = UIView(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height, width: self.textBackgroundView.bounds.width, height: 1.0))
			self.breakLineView.backgroundColor = theme.textViewBreakLineColor
			self.breakLineView.hidden = true
			self.textBackgroundView.addSubview(self.breakLineView)

			self.breakLineView.snp_remakeConstraints(closure: { (make) -> Void in
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
			self.textBoxTapFeedBackView.backgroundColor = UIColor.clearColor()
			self.textBoxTapFeedBackView.layer.borderColor = UIColor.clearColor().CGColor
			self.textBoxTapFeedBackView.layer.borderWidth = 0
			self.textBoxTapFeedBackView.opaque = false
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "textViewTapped:")
			tapGestureRecognizer.cancelsTouchesInView = true
			self.textBoxTapFeedBackView.addGestureRecognizer(tapGestureRecognizer)
			self.textBackgroundView.addSubview(self.textBoxTapFeedBackView)

			self.textBoxTapFeedBackView.snp_makeConstraints(closure: { (make) -> Void in
				make.edges.equalTo(self.textBackgroundView)
			})
		}

		// *********************************
		// Configure Keyboard Button View
		// *********************************

		if self.keyboardButton == nil {
			self.keyboardButton = UIButton(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height - self.keyboardButtonViewHeight, width: self.textBackgroundView.bounds.width, height: self.keyboardButtonViewHeight))
			self.keyboardButton.backgroundColor = appDelegate.theme.keyboardButtonBackgroundColor
			self.keyboardButton.opaque = false
			self.keyboardButton.alpha = 0
			self.keyboardButton.setTitleColor(UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha), forState: .Normal)
			self.keyboardButton.setTitle("KB", forState: .Normal) // TODO: Replace with icon
			self.keyboardButton.addTarget(self, action: "keyboardButtonTapped", forControlEvents: .TouchUpInside)
			let tapGR = UITapGestureRecognizer(target: self, action: "micOrKeyboardButtonTapped:")
			tapGR.cancelsTouchesInView = false
			self.keyboardButton.addGestureRecognizer(tapGR)
			self.view.addSubview(self.keyboardButton)

			self.keyboardButton.snp_makeConstraints(closure: { (make) -> Void in
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
			self.microphoneButton.opaque = false
			self.microphoneButton.alpha = 0
			self.microphoneButton.setTitleColor(UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha), forState: .Normal)
			self.microphoneButton.setTitle("MIC", forState: .Normal) // TODO: Replace with icon
			self.microphoneButton.addTarget(self.homeViewController, action: "microphoneButtonTapped", forControlEvents: .TouchUpInside)
			let tapGR = UITapGestureRecognizer(target: self, action: "micOrKeyboardButtonTapped:")
			tapGR.cancelsTouchesInView = false
			self.microphoneButton.addGestureRecognizer(tapGR)
			self.view.addSubview(self.microphoneButton)
			self.microphoneButton.snp_makeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})
		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColorWithAnimation", name: themeDidChangeNotificationName, object: nil)
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

	func textViewTapped(gestureRecognizer:UITapGestureRecognizer) {
		// Play sound effect
		if !appDelegate.interactionSoundDisabled {
			// TODO: Not working.
			if let path = NSBundle.mainBundle().pathForResource("Tock", ofType: "caf") {
				let tockURL = NSURL(fileURLWithPath: path)
				do {
					let audioPlayer = try AVAudioPlayer(contentsOfURL: tockURL)
					audioPlayer.play()
				} catch {
					NSLog("Tap feedback sound on text view play failed.")
				}
			} else {
				NSLog("Can't find \"Tock.caf\" file.")
			}
		}

		self.textBoxTapFeedBackView.hidden = true
		if !self.isDuringInput {
			self.inputTextView.becomeFirstResponder()
			self.animateAndLayoutUIForInputStart()
			self.textBackgroundView.triggerTapFeedBack(atLocation: gestureRecognizer.locationInView(self.textBackgroundView), withColor: appDelegate.theme.textViewTapFeedbackColor, duration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar)
		}
		self.homeViewController.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.homeViewController.scrollView.bounds.width, height: 1), animated: true)
	}

	func roundButtonTapped(gestureRecognizer:UITapGestureRecognizer?) {
		// Switch Direction
		switch self.roundButtonView.buttonAction {
		case .Switch:
			self.isDirectionEncode = !self.isDirectionEncode
		}

		if gestureRecognizer != nil {
			let tapLocation = gestureRecognizer!.locationInView(self.roundButtonView)
			if self.roundButtonView.bounds.contains(tapLocation) {
				let originalTransform = self.roundButtonView.transform

				// Animations for button
				self.roundButtonView.triggerTapFeedBack(atLocation: tapLocation, withColor: appDelegate.theme.roundButtonTapFeedbackColor, duration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar)
				self.roundButtonView.rotateBackgroundImageWithDuration(TAP_FEED_BACK_DURATION/2.0)
				UIView.animateWithDuration(TAP_FEED_BACK_DURATION/5.0 * appDelegate.animationDurationScalar,
					delay: 0.0,
					options: .CurveEaseIn,
					animations: {
						self.roundButtonView.transform = CGAffineTransformScale(self.roundButtonView.transform, 1.15, 1.15)
						self.roundButtonView.addMDShadow(withDepth: theme.roundButtonMDShadowLevelTapped)
					}) { succeed in
						if succeed {
							UIView.animateWithDuration(TAP_FEED_BACK_DURATION/5.0 * appDelegate.animationDurationScalar,
								delay: 0.0,
								options: .CurveEaseOut,
								animations: {
									self.roundButtonView.transform = originalTransform
									self.roundButtonView.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
								}, completion: nil)
						}
				}
				
		}

		// Switch text and morse label
		if self.isDirectionEncode {
			self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

			self.keyboardButton.snp_remakeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})

			self.microphoneButton.snp_remakeConstraints(closure: { (make) -> Void in
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
			self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

			self.keyboardButton.snp_remakeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView.snp_centerX)
				make.trailing.equalTo(self.textBackgroundView)
			})

			self.microphoneButton.snp_remakeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.bottom.equalTo(self.textBackgroundView)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
			})
		}

		UIView.animateWithDuration(TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
			delay: 0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 0.8,
			options: .CurveEaseInOut,
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
	func micOrKeyboardButtonTapped(gestureRecognizer:UITapGestureRecognizer) {
		let view = gestureRecognizer.view
		if view != nil {
			let location = gestureRecognizer.locationInView(view!)
			view!.triggerTapFeedBack(atLocation: location, withColor: theme.textViewTapFeedbackColor)
		}
	}

	func keyboardButtonTapped() {
		self.inputTextView.becomeFirstResponder()
		self.animateAndLayoutUIForInputStart()
	}

	func microphoneButtonTapped() {
		self.animateAndLayoutUIForInputStart()
		self.inputTextView.userInteractionEnabled = false
	}

	func audioPlotTapped(gestureRecognizer:UITapGestureRecognizer) {
		let text = self.outputTextView.text
		let morse = self.inputTextView.text
		if self.inputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" && self.outputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
			self.homeViewController.addCardViewWithText(text, morse: morse, textOnTop: self.isDirectionEncode, animateWithDuration: 0.3)
		}
		self.animateAndLayoutUIForInputEnd()
	}

	// *****************************
	// MARK: Text View Delegate
	// *****************************

	func textViewDidChange(textView: UITextView) {
		var outputText:String?
		if self.isDirectionEncode {
			self.transmitter.text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			outputText = self.transmitter.morse
		} else {
			self.transmitter.morse = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			outputText = self.transmitter.text
		}
		self.outputTextView.attributedText = getAttributedStringFrom(outputText, withFontSize: textViewOutputFontSize, color: theme.textViewOutputTextColor)
		if outputText != nil {
			self.outputTextView.scrollRangeToVisible(NSMakeRange(outputText!.startIndex.distanceTo(outputText!.endIndex), 0))
		}
	}

	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			let text = self.isDirectionEncode ? self.inputTextView.text : self.outputTextView.text
			let morse = self.isDirectionEncode ? self.outputTextView.text : self.inputTextView.text
			if self.inputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" && self.outputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
				self.homeViewController.addCardViewWithText(text, morse: morse, textOnTop: self.isDirectionEncode, animateWithDuration: 0.3)
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

	func transmitterContentDidChange(text: String, morse: String) {
		// Set text.
		self.inputTextView.attributedText = getAttributedStringFrom(morse.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), withFontSize: textViewInputFontSize, color: theme.textViewInputTextColor)
		self.outputTextView.attributedText = getAttributedStringFrom(text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), withFontSize: textViewOutputFontSize, color: theme.textViewOutputTextColor)
		self.inputTextView.scrollRangeToVisible(NSMakeRange(morse.startIndex.distanceTo(morse.endIndex), 0))
		self.outputTextView.scrollRangeToVisible(NSMakeRange(text.startIndex.distanceTo(text.endIndex), 0))
	}

	// *****************************
	// MARK: Other Methods
	// *****************************

	func inputCancelled() {
		if self.inputTextView.isFirstResponder() {
			self.inputTextView.resignFirstResponder()
		}
		self.animateAndLayoutUIForInputEnd()
	}

	private func animateAndLayoutUIForInputStart() {
//		var delayTime:NSTimeInterval = 0
//		if self.homeViewController.scrollView.contentOffset > 0 {
//
//		}
		self.homeViewController.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.homeViewController.scrollView.bounds.width, height: 1), animated: true)

		let animationDuration = defaultAnimationDuration/3.0
		// Show cancel button
		self.cancelButton.appearWithDuration(animationDuration)

		// Text view stuff
		self.inputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: textViewInputFontSize, color: theme.textViewInputTextColor)
		self.outputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: textViewOutputFontSize, color: theme.textViewOutputTextColor)
		self.textBoxTapFeedBackView.hidden = true
		self.textBoxTapFeedBackView.userInteractionEnabled = false

		// Hide round button
		UIView.animateWithDuration(animationDuration * appDelegate.animationDurationScalar,
			delay: 0,
			options: .CurveEaseOut,
			animations: {
				self.microphoneButton.alpha = 0
				self.keyboardButton.alpha = 0
			}, completion: nil)
		self.roundButtonView.disappearWithAnimationType([.Scale, .Fade], duration: animationDuration) {
			// Move text and morse label
			let labelWidth = self.topBarLabelText.bounds.width
			if self.isDirectionEncode {
				self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.centerX.equalTo(self.topBarView)
				})
				self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.leading.equalTo(self.topBarView.snp_trailing)
				})
			} else {
				self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.leading.equalTo(self.topBarView.snp_trailing)
				})
				self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.width.equalTo(labelWidth)
					make.centerX.equalTo(self.topBarView)
				})
			}

			self.breakLineView.hidden = false
			self.breakLineView.snp_remakeConstraints(closure: { (make) -> Void in
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.inputTextView)
				make.height.equalTo(1.0)
			})
			// Set scrollViewOverlay's background color based on the type of input.
			self.homeViewController.scrollViewOverlay.backgroundColor = self.homeViewController.micInputSectionContainerView == nil ? theme.scrollViewOverlayColor : UIColor.clearColor()

			UIView.animateWithDuration(animationDuration * appDelegate.animationDurationScalar,
				delay: animationDuration,
				//			usingSpringWithDamping: 0.5,
				//			initialSpringVelocity: 0.8,
				options: .CurveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.homeViewController.scrollViewOverlay.alpha = 1
					self.homeViewController.micInputSectionContainerView?.alpha = 1
					self.homeViewController.scrollViewSnapshotImageView?.alpha = 1
					self.homeViewController.topSectionContainerView.addMDShadow(withDepth: 3)
				}) { succeed in
					// If the top section is hidden, and the microphone button is tapped, blured screenshot will  not beupdated correctly.
					// The following code updates blured image if that happens.
					self.homeViewController.updateScrollViewBlurImage()
			}
		}
		// Collapse expanded card view if there is one
		self.homeViewController.collapseCurrentExpandedCard()
		self.homeViewController.restoreCurrentFlippedCard()
	}

	private func animateAndLayoutUIForInputEnd() {
		let animationDuration = TAP_FEED_BACK_DURATION/3.0
		// Hide cancel button
		self.cancelButton.disappearWithDuration(animationDuration)
		// Move text and morse label
		if self.isDirectionEncode {
			self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})
		} else {
			self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.trailing.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})
		}

		// Text view stuff
		self.textBoxTapFeedBackView.hidden = false
		self.textBoxTapFeedBackView.userInteractionEnabled = true
		self.inputTextView.userInteractionEnabled = true
		self.outputTextView.text = nil
		self.inputTextView.attributedText = self.attributedHintTextInput
		self.outputTextView.attributedText = self.attributedHintTextOutput
		self.breakLineView.snp_remakeConstraints(closure: { (make) -> Void in
			make.leading.equalTo(self.textBackgroundView)
			make.trailing.equalTo(self.textBackgroundView)
			make.bottom.equalTo(self.textBackgroundView)
			make.height.equalTo(1.0)
		})

		UIView.animateWithDuration(animationDuration * appDelegate.animationDurationScalar,
			delay: 0,
//			usingSpringWithDamping: 0.5,
//			initialSpringVelocity: 0.8,
			options: .CurveEaseOut,
			animations: {
				self.view.layoutIfNeeded()
				self.homeViewController.scrollViewOverlay.alpha = 0
				self.homeViewController.micInputSectionContainerView?.alpha = 0
				self.homeViewController.scrollViewSnapshotImageView?.alpha = 0
				self.homeViewController.topSectionContainerView.addMDShadow(withDepth: 2)
			}) { succeed in
				self.breakLineView.hidden = true
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
				self.roundButtonView.appearWithAnimationType([.Scale, .Fade], duration: animationDuration)
				UIView.animateWithDuration(animationDuration * appDelegate.animationDurationScalar,
					delay: animationDuration,
					options: .CurveEaseOut,
					animations: {
						if !self.isDirectionEncode {
							self.microphoneButton.alpha = 1
							self.keyboardButton.alpha = 0
						}
					}, completion: nil)
		}
	}

	func updateColor(animated animated:Bool = true) {
		self.inputTextView.keyboardAppearance = theme.keyboardAppearance
		self.roundButtonView.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animateWithDuration(duration,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.inputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.outputTextView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.statusBarView.backgroundColor = theme.statusBarBackgroundColor
				self.topBarView.backgroundColor = theme.topBarBackgroundColor
				self.roundButtonView.backgroundColor = theme.roundButtonBackgroundColor
				self.topBarLabelText.textColor = theme.topBarLabelTextColor
				self.topBarLabelMorse.textColor = theme.topBarLabelTextColor
				self.textBackgroundView.backgroundColor = theme.textViewBackgroundColor
				self.breakLineView.backgroundColor = theme.textViewBreakLineColor
				self.keyboardButton.backgroundColor = theme.keyboardButtonBackgroundColor
				self.microphoneButton.backgroundColor = theme.keyboardButtonBackgroundColor
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
