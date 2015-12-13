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

class HomeTopSectionViewController: UIViewController, UITextViewDelegate {

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

	var lineBreakView:UIView!

	// Button
	var roundButtonView: RoundButtonView!
	var cancelButton: CancelButton!
	var keyboardButtonView: UIView!

	// *****************************
	// MARK: UI Related Variables
	// *****************************

	var statusBarHeight:CGFloat {
		return UIApplication.sharedApplication().statusBarFrame.size.height
	}

	let topBarHeight:CGFloat = 56

	let textBackgroundViewHeight:CGFloat = 140

	var keyboardButtonViewHeight:CGFloat {
		return self.topBarHeight
	}

	private var roundButtonMargin:CGFloat {
		return 8
	}

	private var roundButtonRadius:CGFloat {
		return self.topBarHeight/2.0 - self.roundButtonMargin
	}

	private var cancelButtonWidth:CGFloat {
		return self.topBarHeight
	}

	// *****************************
	// MARK: Data Related Variables
	// *****************************

	private let transmitter = MorseTansmitter()

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
			[NSFontAttributeName: UIFont.systemFontOfSize(16),
				NSForegroundColorAttributeName: UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)])
	}

	private var attributedHintTextOutput:NSMutableAttributedString {
		return NSMutableAttributedString(string: self.hintTextOutput, attributes:
			[NSFontAttributeName: UIFont.systemFontOfSize(16),
				NSForegroundColorAttributeName: UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)])
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
			self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.statusBarHeight))
			self.statusBarView.backgroundColor = appDelegate.theme.statusBarBackgroundColor
			self.view.addSubview(self.statusBarView)
			self.statusBarView.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(self.statusBarHeight)
			})
		}

		// *****************************
		// Configure Top Bar View
		// *****************************

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: self.statusBarHeight, width: self.view.bounds.width, height: self.topBarHeight))
			self.topBarView.backgroundColor = appDelegate.theme.topBarBackgroundColor
			self.view.addSubview(topBarView)

			// Text label
			self.topBarLabelText = UILabel(frame: CGRect(x: 0, y: 0, width: self.topBarView.bounds.width/2.0 - self.roundButtonRadius - self.roundButtonMargin, height: self.topBarHeight))
			self.topBarLabelText.textAlignment = .Center
			self.topBarLabelText.tintColor = appDelegate.theme.topBarLabelTextColor
			self.topBarLabelText.attributedText = NSAttributedString(string: LocalizedStrings.Label.topBarTextLabel, attributes:
				[NSFontAttributeName: UIFont.boldSystemFontOfSize(23),
					NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
			self.topBarView.addSubview(self.topBarLabelText)

			// Morse label
			self.topBarLabelMorse = UILabel(frame: CGRect(x: self.topBarView.bounds.width/2.0 + self.roundButtonRadius + self.roundButtonMargin, y: 0, width: self.topBarView.bounds.width/2.0 - self.roundButtonRadius - self.roundButtonMargin, height: self.topBarHeight))
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
			self.cancelButton.addTarget(self, action: "dismissInputTextKeyboard", forControlEvents: .TouchUpInside)
			self.topBarView.addSubview(self.cancelButton)

			self.cancelButton.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.leading.equalTo(self.topBarView)
				make.width.equalTo(self.topBarHeight)
				make.height.equalTo(self.cancelButton.snp_width)
			})

			self.cancelButton.disappearWithDuration(0)

			// Configure constraints
			self.topBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.statusBarView.snp_bottom)
				make.leading.equalTo(self.view).offset(0)
				make.trailing.equalTo(self.view).offset(0)
				make.height.equalTo(self.topBarHeight)
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
			self.textBackgroundView = UIView(frame: CGRect(x: 0, y: self.statusBarHeight + self.topBarHeight, width: self.view.bounds.width, height: self.textBackgroundViewHeight))
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

		if self.lineBreakView == nil {
			self.lineBreakView = UIView(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height, width: self.textBackgroundView.bounds.width, height: 1.0))
			self.lineBreakView.backgroundColor = UIColor(hex: 0x000, alpha: 0.1)
			self.lineBreakView.hidden = true
			self.textBackgroundView.addSubview(self.lineBreakView)

			self.lineBreakView.snp_remakeConstraints(closure: { (make) -> Void in
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

		if self.keyboardButtonView == nil {
			self.keyboardButtonView = UIView(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height - self.keyboardButtonViewHeight, width: self.textBackgroundView.bounds.width, height: self.keyboardButtonViewHeight))
			self.keyboardButtonView.backgroundColor = appDelegate.theme.keyboardButtonViewBackgroundColor
			self.keyboardButtonView.opaque = false
			self.keyboardButtonView.alpha = 0
			self.keyboardButtonView.hidden = true
			self.view.addSubview(self.keyboardButtonView)

			self.keyboardButtonView.snp_makeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.keyboardButtonViewHeight)
				make.leading.equalTo(self.textBackgroundView)
				make.trailing.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.textBackgroundView)
			})
		}
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Layout views based on the new constraints
		self.view.layoutIfNeeded()
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
		if !self.inputTextView.isFirstResponder() {
			self.inputTextView.becomeFirstResponder()
			self.animateAndLayoutUIForInputStart()
		}
		self.textBackgroundView.triggerTapFeedBack(atLocation: gestureRecognizer.locationInView(self.textBackgroundView), withColor: appDelegate.theme.textViewTapFeedbackColor, duration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar)
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
						self.roundButtonView.addMDShadow(withDepth: 4)
					}) { succeed in
						if succeed {
							UIView.animateWithDuration(TAP_FEED_BACK_DURATION/5.0 * appDelegate.animationDurationScalar,
								delay: 0.0,
								options: .CurveEaseOut,
								animations: {
									self.roundButtonView.transform = originalTransform
									self.roundButtonView.addMDShadow(withDepth: 3)
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

		UIView.animateWithDuration(TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
			delay: 0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 0.8,
			options: .CurveEaseInOut,
			animations: {
				self.topBarView.layoutIfNeeded()
			}, completion: nil)
		}
	}

	// *****************************
	// MARK: Text View Delegate
	// *****************************

	func textViewDidBeginEditing(textView: UITextView) {

		self.inputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: 16, color: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha))
		self.outputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: 16, color: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha))
		self.textBoxTapFeedBackView.hidden = true
		self.textBoxTapFeedBackView.userInteractionEnabled = false

		self.lineBreakView.hidden = false
		self.lineBreakView.snp_remakeConstraints(closure: { (make) -> Void in
			make.leading.equalTo(self.textBackgroundView)
			make.trailing.equalTo(self.textBackgroundView)
			make.bottom.equalTo(self.inputTextView)
			make.height.equalTo(1.0)
		})

		UIView.animateWithDuration(0.15 * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: .CurveLinear,
			animations: { () -> Void in
				self.view.layoutIfNeeded()
				self.homeViewController.scrollViewOverlay.hidden = false
				self.homeViewController.topSectionContainerView.addMDShadow(withDepth: 3)
			}, completion: nil)
	}

	func textViewDidChange(textView: UITextView) {
		var outputText:String?
		if self.isDirectionEncode {
			self.transmitter.text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			outputText = self.transmitter.morse
		} else {
			self.transmitter.morse = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			outputText = self.transmitter.text
		}
		self.outputTextView.attributedText = getAttributedStringFrom(outputText, withFontSize: 16, color: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha))
		if outputText != nil {
			self.outputTextView.scrollRangeToVisible(NSMakeRange(outputText!.startIndex.distanceTo(outputText!.endIndex), 0))
		}
	}

	func textViewDidEndEditing(textView: UITextView) {
		self.textBoxTapFeedBackView.hidden = false
		self.textBoxTapFeedBackView.userInteractionEnabled = true
		self.outputTextView.text = nil
		textView.attributedText = self.attributedHintTextInput
		self.outputTextView.attributedText = self.attributedHintTextOutput
		self.lineBreakView.snp_remakeConstraints(closure: { (make) -> Void in
			make.leading.equalTo(self.textBackgroundView)
			make.trailing.equalTo(self.textBackgroundView)
			make.bottom.equalTo(self.textBackgroundView)
			make.height.equalTo(1.0)
		})
		UIView.animateWithDuration(0.15 * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: .CurveLinear,
			animations: { () -> Void in
				self.view.layoutIfNeeded()
				self.homeViewController.scrollViewOverlay.hidden = true
				self.homeViewController.topSectionContainerView.addMDShadow(withDepth: 2)
			}) { (succeed) -> Void in
				if succeed {
					self.lineBreakView.hidden = true
				}
		}

		self.animateAndLayoutUIForInputEnd()
	}

	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			let text = self.isDirectionEncode ? self.inputTextView.text : self.outputTextView.text
			let morse = self.isDirectionEncode ? self.outputTextView.text : self.inputTextView.text
			if self.inputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" && self.outputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
				self.homeViewController.addCardViewWithText(text, morse: morse, textOnTop: self.isDirectionEncode, animateWithDuration: 0.3)
			}
			textView.resignFirstResponder()
		}
		return true
	}

	// *****************************
	// MARK: Other Methods
	// *****************************

	func dismissInputTextKeyboard() {
		if self.inputTextView.isFirstResponder() {
			self.inputTextView.resignFirstResponder()
		}
	}

	private func animateAndLayoutUIForInputStart() {
		let animationDuration = TAP_FEED_BACK_DURATION/3.0
		// Show cancel button
		self.cancelButton.appearWithDuration(animationDuration)
		// Hide round button
		self.roundButtonView.disappearWithAnimationType([.Scale, .Fade], duration: animationDuration)
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
		UIView.animateWithDuration(animationDuration,
			delay: animationDuration,
//			usingSpringWithDamping: 0.5,
//			initialSpringVelocity: 0.8,
			options: .CurveEaseOut,
			animations: {
				self.topBarView.layoutIfNeeded()
			}, completion: nil)
		// Collapse expanded card view if there is one
		self.homeViewController.collapseCurrentExpandedView()
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
		UIView.animateWithDuration(animationDuration,
			delay: 0,
//			usingSpringWithDamping: 0.5,
//			initialSpringVelocity: 0.8,
			options: .CurveEaseOut,
			animations: {
				self.topBarView.layoutIfNeeded()
			}) { succeed in
				if succeed {
					// Show round button
					self.roundButtonView.appearWithAnimationType([.Scale, .Fade], duration: animationDuration)
				}
		}
	}
}
