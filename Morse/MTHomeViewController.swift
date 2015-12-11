//
//  MTHomeViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import CoreData

class MTHomeViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, MTCardViewDelegate {

	// *****************************
	// MARK: Views
	// *****************************

	// Top bar views
	private var statusBarView:UIView!
	private var topBarView:UIView!
	private var topBarLabelText:UILabel!
	private var topBarLabelMorse:UILabel!

	// Text views
	private var hiddenLineView:UIView!
	private var textBackgroundView:UIView!
	private var inputTextView:UITextView!
	private var lineBreakView:UIView!
	private var outputTextView:UITextView!
	private var textBoxTapFeedBackView:UIView!

	// Button
	private var roundButtonView:MTRoundButtonView!
	private var cancelButton:MTCancelButton!
	private var keyboardButtonView:UIView!

	// Scroll views
	private var scrollViewOverlay:UIButton!
	private var scrollView:UIScrollView!
	private var cardViews:[MTCardView] = []
	private var currentExpandedView:MTCardView?

	// *****************************
	// MARK: Private variables
	// *****************************

	private var isDirectionEncode:Bool = true {
		didSet {
			self.inputTextView.attributedText = self.attributedHintTextInput
			self.outputTextView.attributedText = self.attributedHintTextOutput
		}
	}
	private let transmitter = MorseTansmitter()

	private var interactionSoundEnabled:Bool {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.interactionSoundEnabled
	}

	private var inputAreaHidden = false

	// *****************************
	// MARK: UI Related Variables
	// *****************************
	private var viewWidth:CGFloat {
		return self.view.bounds.width
	}

	private var viewHeight:CGFloat {
		return self.view.bounds.height - self.tabBarHeight
	}

	private var cameraAndMicButtonViewHeight:CGFloat {
		return self.topBarHeight
	}

	private var tabBarHeight:CGFloat {
		if let tabBarController = self.tabBarController {
			return tabBarController.tabBar.bounds.height
		} else {
			return 0
		}
	}

	private var statusBarHeight:CGFloat {
		return UIApplication.sharedApplication().statusBarFrame.size.height
	}

	private let topBarHeight:CGFloat = 56

	private var animationDurationScalar:Double {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.animationDurationScalar
	}

	private var roundButtonMargin:CGFloat {
		return 8
	}

	private var roundButtonRadius:CGFloat {
		return self.topBarHeight/2.0 - self.roundButtonMargin
	}

	private var theme:Theme {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.theme
	}

	private var hintTextInput:String {
//		if self.isDirectionEncode {
//			return "Touch to type"
//		} else {
//			return "___ ___   ___ ___ ___   . ___ .   . . .   ."
//		}
		return "Touch to type"
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

	private var cancelButtonWidth:CGFloat {
		return self.topBarHeight
	}

	private var cardViewLeftMargin:CGFloat {
		if self.traitCollection.horizontalSizeClass == .Compact {
			return 16
		} else if self.traitCollection.horizontalSizeClass == .Regular {
			return 32
		}
		return 16
	}

	private var cardViewRightMargin:CGFloat {
		return self.cardViewLeftMargin
	}

	private var cardViewTopMargin:CGFloat {
		return cardViewLeftMargin
	}

	private var cardViewBottomMargin:CGFloat {
		return self.cardViewLeftMargin
	}

	private var cardViewGapY:CGFloat {
		if self.traitCollection.verticalSizeClass == .Regular &&
			self.traitCollection.horizontalSizeClass == .Regular {
			return 16
		} else {
			return 8
		}
	}

	private var cardViewHeight:CGFloat {
//		return 74
		return 86
	}

	private var textBackgroundViewHeight:CGFloat {
		return 140
	}

	// *****************************
	// MARK: MVC Life Cycle
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()
		// TODO: Custom tab bar item
		self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 0)
    }

	// Views are created and constraints are added in this callback
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if self.statusBarView == nil {
			self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.statusBarHeight))
			self.statusBarView.backgroundColor = self.theme.statusBarBackgroundColor
			self.view.addSubview(self.statusBarView)
			self.statusBarView.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.left.equalTo(self.view)
				make.right.equalTo(self.view)
				make.height.equalTo(self.statusBarHeight)
			})
		}

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: self.statusBarHeight, width: self.view.bounds.width, height: self.topBarHeight))
			self.topBarView.backgroundColor = self.theme.topBarBackgroundColor
			self.view.addSubview(topBarView)

			// Add Text label
			if self.topBarLabelText == nil {
				self.topBarLabelText = UILabel(frame: CGRect(x: 0, y: 0, width: self.topBarView.bounds.width/2.0 - self.roundButtonRadius - self.roundButtonMargin, height: self.topBarHeight))
				self.topBarLabelText.textAlignment = .Center
				self.topBarLabelText.tintColor = self.theme.topBarLabelTextColor
				self.topBarLabelText.attributedText = NSAttributedString(string: "Text", attributes:
					[NSFontAttributeName: UIFont.boldSystemFontOfSize(23),
						NSForegroundColorAttributeName: self.theme.topBarLabelTextColor])
				self.topBarView.addSubview(self.topBarLabelText)
			}

			// Add Morse label
			if self.topBarLabelMorse == nil {
				self.topBarLabelMorse = UILabel(frame: CGRect(x: self.topBarView.bounds.width/2.0 + self.roundButtonRadius + self.roundButtonMargin, y: 0, width: self.topBarView.bounds.width/2.0 - self.roundButtonRadius - self.roundButtonMargin, height: self.topBarHeight))
				self.topBarLabelMorse.textAlignment = .Center
				self.topBarLabelMorse.tintColor = self.theme.topBarLabelTextColor
				self.topBarLabelMorse.attributedText = NSAttributedString(string: "Morse", attributes:
					[NSFontAttributeName: UIFont.boldSystemFontOfSize(23),
						NSForegroundColorAttributeName: self.theme.topBarLabelTextColor])
				self.topBarView.addSubview(self.topBarLabelMorse)
			}

			// Add round button
			if self.roundButtonView == nil {
				self.roundButtonView = MTRoundButtonView(origin: CGPoint(x: self.topBarView.bounds.width/2.0 - self.roundButtonRadius, y: self.roundButtonMargin), radius: self.roundButtonRadius)
				let tapGR = UITapGestureRecognizer(target: self, action: "roundButtonTapped:")
				self.roundButtonView.addGestureRecognizer(tapGR)
				self.topBarView.addSubview(self.roundButtonView)
			}

			self.topBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.statusBarView.snp_bottom)
				make.left.equalTo(self.view).offset(0)
				make.right.equalTo(self.view).offset(0)
				make.height.equalTo(self.topBarHeight)
			})

			self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.left.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.right.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
			})

			self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.right.equalTo(self.topBarView)
				make.bottom.equalTo(self.topBarView)
				make.left.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
			})

			self.roundButtonView.snp_makeConstraints(closure: { (make) -> Void in
				make.centerX.equalTo(self.topBarView)
				make.centerY.equalTo(self.topBarView)
				make.height.equalTo(self.roundButtonRadius * 2)
				make.width.equalTo(self.roundButtonView.snp_height)
			})
		}

		if self.textBackgroundView == nil {
			self.textBackgroundView = UIView(frame: CGRect(x: 0, y: self.topBarHeight + self.statusBarHeight, width: self.viewWidth, height: self.textBackgroundViewHeight))
			self.textBackgroundView.backgroundColor = UIColor.whiteColor()
			self.textBackgroundView.layer.borderColor = UIColor.clearColor().CGColor
			self.textBackgroundView.layer.borderWidth = 0
			self.view.addSubview(self.textBackgroundView)

			// Configure contraints
			self.textBackgroundView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.right.equalTo(self.view)
				make.left.equalTo(self.view)
				make.height.equalTo(self.textBackgroundViewHeight)
			}
		}

		if self.inputTextView == nil {
			self.inputTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.textBackgroundView.bounds.width, height: self.textBackgroundViewHeight/2.0))
			self.inputTextView.backgroundColor = UIColor.clearColor()
			self.inputTextView.opaque = false
			self.inputTextView.keyboardType = .ASCIICapable
			self.inputTextView.returnKeyType = .Done
			self.inputTextView.attributedText = self.attributedHintTextInput
			self.inputTextView.delegate = self
			self.inputTextView.userInteractionEnabled = true
			self.inputTextView.selectable = true
			self.inputTextView.layer.borderColor = UIColor.clearColor().CGColor
			self.inputTextView.layer.borderWidth = 0
			self.textBackgroundView.addSubview(self.inputTextView)

			// Configure contraints
			self.inputTextView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.textBackgroundView)
				make.right.equalTo(self.textBackgroundView)
				make.left.equalTo(self.textBackgroundView)
				make.height.equalTo(self.textBackgroundView.snp_height).multipliedBy(0.5)
			}
		}

		// Change shadow level of background text view according to inputTextView status
		if self.inputTextView.isFirstResponder() {
			self.textBackgroundView.addMDShadow(withDepth: 3)
		} else {
			self.textBackgroundView.addMDShadow(withDepth: 2)
		}

		// Hidden line view is used to hide the gap between input and output text view
		if self.hiddenLineView == nil {
			self.hiddenLineView = UIView(frame: CGRect(x: 0, y: self.textBackgroundViewHeight/2.0 + self.statusBarHeight + self.topBarHeight - self.textBackgroundViewHeight, width: self.inputTextView.bounds.width, height: 1.0))
			if let color = self.inputTextView.backgroundColor {
				self.hiddenLineView.backgroundColor = color
			}
			self.textBackgroundView.addSubview(self.hiddenLineView)

			self.hiddenLineView.snp_remakeConstraints(closure: { (make) -> Void in
				make.left.equalTo(self.inputTextView)
				make.right.equalTo(self.inputTextView)
				make.bottom.equalTo(self.inputTextView)
				make.height.equalTo(self.textBackgroundViewHeight)
			})
		}

		if self.outputTextView == nil {
			self.outputTextView = UITextView(frame: CGRect(x: 0, y: self.textBackgroundViewHeight/2.0, width: self.viewWidth, height: self.textBackgroundViewHeight/2.0))
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
			self.textBackgroundView.insertSubview(self.outputTextView, belowSubview: self.hiddenLineView)

			// Configure contraints
			self.outputTextView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.inputTextView.snp_bottom)
				make.right.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.textBackgroundView)
				make.left.equalTo(self.textBackgroundView)
			}
		}

		self.outputTextView.bounds = CGRect(x: 0, y: 0, width: self.outputTextView.frame.width, height: self.outputTextView.frame.height)

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

		if self.cancelButton == nil {
			self.cancelButton = MTCancelButton(origin: CGPoint(x: 0, y: 0), width: self.cancelButtonWidth)
			self.cancelButton.addTarget(self, action: "dismissInputTextKeyboard", forControlEvents: .TouchUpInside)
			self.topBarView.addSubview(self.cancelButton)

			self.cancelButton.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView)
				make.left.equalTo(self.topBarView)
				make.width.equalTo(self.topBarHeight)
				make.height.equalTo(self.cancelButton.snp_width)
			})

			self.cancelButton.disappearWithDuration(0)
		}

		if self.keyboardButtonView == nil {
			self.keyboardButtonView = UIView(frame: CGRect(x: 0, y: self.textBackgroundView.bounds.height - self.cameraAndMicButtonViewHeight, width: self.textBackgroundView.bounds.width, height: self.cameraAndMicButtonViewHeight))
			self.keyboardButtonView.backgroundColor = self.theme.keyboardButtonViewBackgroundColor
			self.keyboardButtonView.opaque = false
			self.keyboardButtonView.alpha = 0
			self.keyboardButtonView.hidden = true
			self.textBackgroundView.addSubview(self.keyboardButtonView)

			self.keyboardButtonView.snp_makeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.cameraAndMicButtonViewHeight)
				make.left.equalTo(self.textBackgroundView)
				make.right.equalTo(self.textBackgroundView)
				make.bottom.equalTo(self.textBackgroundView)
			})
		}

		if self.scrollView == nil {
			self.scrollView = UIScrollView(frame: CGRect(x: 0, y: self.statusBarHeight + self.topBarHeight + self.textBackgroundViewHeight, width: self.viewWidth, height: self.viewHeight - self.textBackgroundViewHeight))
			self.scrollView.backgroundColor = UIColor.whiteColor()
			self.scrollView.userInteractionEnabled = true
			self.scrollView.bounces = true
			self.scrollView.showsHorizontalScrollIndicator = false
			self.scrollView.showsVerticalScrollIndicator = true
			self.scrollView.delegate = self
			self.view.insertSubview(self.scrollView, atIndex: 0)

			self.scrollView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.textBackgroundView.snp_bottom)
				make.right.equalTo(self.view)
				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
				make.left.equalTo(self.view)
			}
		}

		if self.scrollViewOverlay == nil {
			self.scrollViewOverlay = UIButton(frame: CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: self.scrollView.bounds.height))
			self.scrollViewOverlay.addTarget(self, action: "dismissInputTextKeyboard", forControlEvents: .TouchUpInside)
			self.scrollViewOverlay.backgroundColor = UIColor(hex: 0x000, alpha: 0.35)
			self.scrollViewOverlay.opaque = false
			self.scrollViewOverlay.layer.borderColor = UIColor.clearColor().CGColor
			self.scrollViewOverlay.layer.borderWidth = 0
			self.scrollViewOverlay.hidden = true
			self.view.insertSubview(self.scrollViewOverlay, aboveSubview: self.scrollView)

			self.scrollViewOverlay.snp_makeConstraints(closure: { (make) -> Void in
				make.edges.equalTo(self.scrollView)
			})
		}

		self.updateCardViewsConstraints()
		self.view.layoutIfNeeded()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if self.scrollView.subviews.isEmpty {
			self.fetchCardsAndUpdateCardViews()
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// *****************************
	// MARK: Text View Delegate
	// *****************************

	func textViewDidBeginEditing(textView: UITextView) {

		self.inputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: 16, color: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha))
		self.outputTextView.attributedText = getAttributedStringFrom(" ", withFontSize: 16, color: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha))
		self.textBoxTapFeedBackView.hidden = true
		self.textBoxTapFeedBackView.userInteractionEnabled = false

		if self.lineBreakView == nil {
			self.lineBreakView = UIView(frame: CGRect(x: 0, y: self.textBackgroundViewHeight, width: self.textBackgroundView.bounds.width, height: 1.0))
			self.lineBreakView.backgroundColor = UIColor(hex: 0x000, alpha: 0.1)
			self.textBackgroundView.addSubview(self.lineBreakView)
		}

		self.lineBreakView.hidden = false
		self.lineBreakView.snp_remakeConstraints(closure: { (make) -> Void in
			make.left.equalTo(self.textBackgroundView)
			make.right.equalTo(self.textBackgroundView)
			make.bottom.equalTo(self.inputTextView)
			make.height.equalTo(1.0)
		})

		UIView.animateWithDuration(0.15 * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveLinear,
			animations: { () -> Void in
				self.view.layoutIfNeeded()
				self.scrollViewOverlay.hidden = false
		}, completion: nil)

		let buttonAnimationDuration = TAP_FEED_BACK_DURATION/3.0
		self.cancelButton.appearWithDuration(buttonAnimationDuration)
		self.roundButtonView.disappearWithAnimationType([.Scale, .Fade], duration: buttonAnimationDuration)
		self.collapseCurrentExpandedView()
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
			make.left.equalTo(self.textBackgroundView)
			make.right.equalTo(self.textBackgroundView)
			make.bottom.equalTo(self.textBackgroundView)
			make.height.equalTo(1.0)
		})
		UIView.animateWithDuration(0.15 * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveLinear,
			animations: { () -> Void in
				self.view.layoutIfNeeded()
				self.scrollViewOverlay.hidden = true
				self.textBackgroundView.addMDShadow(withDepth: 2)
			}) { (succeed) -> Void in
				if succeed {
					self.lineBreakView.hidden = true
				}
		}

		let buttonAnimationDuration = TAP_FEED_BACK_DURATION/3.0
		self.cancelButton.disappearWithDuration(buttonAnimationDuration)
		self.roundButtonView.appearWithAnimationType([.Scale, .Fade], duration: buttonAnimationDuration)
	}

	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			let text = self.isDirectionEncode ? self.inputTextView.text : self.outputTextView.text
			let morse = self.isDirectionEncode ? self.outputTextView.text : self.inputTextView.text
			if self.inputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" && self.outputTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
				self.addCardViewWithText(text, morse: morse, textOnTop: self.isDirectionEncode, animateWithDuration: 0.3)
			}
			textView.resignFirstResponder()
		}
		return true
	}

	// *****************************
	// MARK: Scroll View Delegate
	// *****************************

	func scrollViewDidScroll(scrollView: UIScrollView) {
		let topSectionHeight = self.topBarHeight + self.textBackgroundViewHeight - self.cameraAndMicButtonViewHeight
		let animationDuration = 0.25 * self.animationDurationScalar
		if scrollView.contentOffset.y <= self.roundButtonView.bounds.height && self.inputAreaHidden {
			// Show input area
			self.inputAreaHidden = false

			self.statusBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.left.equalTo(self.view)
				make.right.equalTo(self.view)
				make.height.equalTo(self.statusBarHeight)
			})


			UIView.animateWithDuration(animationDuration
				, delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.inputTextView.alpha = 1
					self.outputTextView.alpha = 1
				}) { succeed in
					if succeed {
						if !self.inputTextView.isFirstResponder() {
							self.roundButtonView.appearWithAnimationType([.Scale, .Fade], duration: animationDuration)
						}
					}
			}

		} else if scrollView.contentOffset.y >= topSectionHeight && scrollView.contentSize.height > self.view.bounds.height && !self.inputAreaHidden {
			// Only hide input view if the content for scroll view is large enough to be displayed on a full size scroll view.
			// Hide input area
			self.inputAreaHidden = true

			self.statusBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view).offset(-topSectionHeight)
				make.left.equalTo(self.view)
				make.right.equalTo(self.view)
				make.height.equalTo(self.statusBarHeight)
			})

			if !self.inputTextView.isFirstResponder() {
				self.roundButtonView.disappearWithAnimationType([.Scale, .Fade], duration: animationDuration)
			}
			UIView.animateWithDuration(animationDuration
				, delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.inputTextView.alpha = 0
					self.outputTextView.alpha = 0
			}, completion: nil)
		}
	}

	// *****************************
	// MARK: Card View Delegate
	// *****************************

	func cardViewTapped(cardView: MTCardView) {
		// Expand card view.
		if self.currentExpandedView == cardView {
			// If the current expanded view is the tapped card view, collapse it and done.
			self.collapseCurrentExpandedView()
		} else {
			// If the current expanded view is not the tapped card view, collapse the expanded view and expand card view.
			self.collapseCurrentExpandedView()
			cardView.expanded = true
			self.currentExpandedView = cardView
			self.updateCardViewsConstraints()
			UIView.animateWithDuration(TAP_FEED_BACK_DURATION/3.0 * self.animationDurationScalar,
				delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.scrollView.layoutIfNeeded()
					cardView.backgroundColor = self.theme.cardViewExpandedBackgroudColor
				}) { succeed in
					if succeed {
						cardView.addMDShadow(withDepth: 1)
					}
			}
		}
	}

	// *****************************
	// MARK: User Interaction Handler
	// *****************************

	// Gesture call backs.
	func textViewTapped(gestureRecognizer:UITapGestureRecognizer) {
		if self.interactionSoundEnabled {
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
		}
		self.textBackgroundView.triggerTapFeedBack(atLocation: gestureRecognizer.locationInView(self.textBackgroundView), withColor: self.theme.textViewTapFeedbackColor, duration: TAP_FEED_BACK_DURATION * self.animationDurationScalar)
		self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
	}

	func roundButtonTapped(gestureRecognizer:UITapGestureRecognizer) {
		// Switch Direction
		switch self.roundButtonView.buttonAction {
		case .Switch:
			self.isDirectionEncode = !self.isDirectionEncode
		}

		let tapLocation = gestureRecognizer.locationInView(self.roundButtonView)
		if self.roundButtonView.bounds.contains(tapLocation) {
			let originalTransform = self.roundButtonView.transform

			// Animations for button
			self.roundButtonView.triggerTapFeedBack(atLocation: tapLocation, withColor: self.theme.roundButtonTapFeedbackColor, duration: TAP_FEED_BACK_DURATION * self.animationDurationScalar)
			self.roundButtonView.rotateBackgroundImageWithDuration(TAP_FEED_BACK_DURATION/2.0)
			UIView.animateWithDuration(TAP_FEED_BACK_DURATION/5.0 * self.animationDurationScalar,
				delay: 0.0,
				options: .CurveEaseIn,
				animations: {
					self.roundButtonView.transform = CGAffineTransformScale(self.roundButtonView.transform, 1.05, 1.05)
					self.roundButtonView.addMDShadow(withDepth: 4)
				}) { succeed in
					if succeed {
						UIView.animateWithDuration(TAP_FEED_BACK_DURATION/5.0 * self.animationDurationScalar,
							delay: 0.0,
							options: .CurveEaseOut,
							animations: {
								self.roundButtonView.transform = originalTransform
								self.roundButtonView.addMDShadow(withDepth: 3)
							}, completion: nil)
					}
			}

			// Switch text and morse label
			if self.isDirectionEncode {
				self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.left.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.right.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
				})

				self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.right.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.left.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
				})
			} else {
				self.topBarLabelText.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.right.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.left.equalTo(self.topBarView.snp_centerX).offset(self.roundButtonRadius)
				})

				self.topBarLabelMorse.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.left.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.right.equalTo(self.topBarView.snp_centerX).offset(-self.roundButtonRadius)
				})
			}

			UIView.animateWithDuration(TAP_FEED_BACK_DURATION * self.animationDurationScalar,
				delay: 0,
				usingSpringWithDamping: 0.5,
				initialSpringVelocity: 0.8,
				options: .CurveEaseInOut,
				animations: {
					self.topBarView.layoutIfNeeded()
				}, completion: nil)
		}
	}


	func dismissInputTextKeyboard() {
		if self.inputTextView.isFirstResponder() {
			self.inputTextView.resignFirstResponder()
		}
	}

	// *****************************
	// MARK: Card View Manipulation
	// *****************************

	private func addCardViewWithText(text:String, morse:String, textOnTop:Bool = true, animateWithDuration duration:NSTimeInterval = 0.0) {
		let cardView = MTCardView(frame: CGRect(x: self.cardViewLeftMargin, y: self.cardViewTopMargin, width: self.scrollView.bounds.width - self.cardViewLeftMargin - self.cardViewRightMargin, height: self.cardViewHeight), text: text, morse: morse, textOnTop: textOnTop)
		cardView.delegate = self

		// TODO: Animation
		cardView.opaque = false
		cardView.alpha = 0.0
		self.scrollView.addSubview(cardView)
		self.cardViews.append(cardView)
		self.updateCardViewsConstraints()
		self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
		UIView.animateWithDuration(duration / 3.0,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: { () -> Void in
				self.scrollView.layoutIfNeeded()
			}) { succeed in
				if succeed {
					UIView.animateWithDuration(duration * 2.0 / 3.0,
						delay: 0.0,
						options: .CurveEaseInOut,
						animations: { () -> Void in
							cardView.alpha = 1.0
						}) { succeed in
							if succeed {
								cardView.opaque = true
								self.saveCard(text, morse: morse, index: self.cardViews.count - 1, textOnTop: self.isDirectionEncode, favorite: false, deletable: true)
							}
					}
				}
		}
	}

	private func updateCardViewsConstraints() {
		let views = self.cardViews
		var contentHeight = self.cardViewTopMargin
		for var i = views.count - 1; i >= 0; i-- {
			let cardView = views[i]
			if i >= views.count - 1 {
				cardView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.cardViewTopMargin)
					make.left.equalTo(self.cardViewLeftMargin)
					make.width.equalTo(self.view.bounds.width - self.cardViewLeftMargin - self.cardViewRightMargin)
				})
			} else {
				cardView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(views[i + 1].snp_bottom).offset(self.cardViewGapY)
					make.left.equalTo(self.cardViewLeftMargin)
					make.width.equalTo(self.view.bounds.width - self.cardViewLeftMargin - self.cardViewRightMargin)
				})
			}

			// Update view height depends on if it's expanded.
			if cardView.expanded {

				cardView.topLabel.lineBreakMode = .ByWordWrapping
				cardView.topLabel.numberOfLines = 0
				cardView.bottomLabel.lineBreakMode = .ByWordWrapping
				cardView.bottomLabel.numberOfLines = 0

				let labelWidth = cardView.topLabel.frame.width

				let topTextSize = cardView.topLabel.attributedText?.size()
				let topLabelHeight = ceil(topTextSize!.width/labelWidth) * topTextSize!.height
				cardView.topLabel.snp_updateConstraints(closure: { (make) -> Void in
					make.height.equalTo(topLabelHeight)
				})

				let bottomTextSize = cardView.bottomLabel.attributedText?.size()
				let bottomLabelHeight = ceil(bottomTextSize!.width/labelWidth) * bottomTextSize!.height

				cardView.snp_updateConstraints { (make) -> Void in
					make.height.equalTo(cardView.paddingTop + topLabelHeight + cardView.gapY + bottomLabelHeight + cardView.paddingBottom)
				}
			} else { // TODO Constraints BUG
				cardView.topLabel.snp_remakeConstraints { (make) -> Void in
					make.top.equalTo(cardView).offset(cardView.paddingTop)
					make.right.equalTo(cardView).offset(-cardView.paddingRight)
					make.left.equalTo(cardView).offset(cardView.paddingLeft)
					make.height.equalTo((cardView.bounds.height - cardView.paddingTop - cardView.paddingBottom - cardView.gapY)/2.0)
				}
				cardView.snp_updateConstraints(closure: { (make) -> Void in
					make.height.equalTo(self.cardViewHeight)
				})
			}
			cardView.addMDShadow(withDepth: 1)
			contentHeight += (cardView.frame.height + self.cardViewGapY)
		}

		contentHeight += self.cardViewBottomMargin
		if !self.cardViews.isEmpty {
			contentHeight -= self.cardViewGapY
		} else {
			contentHeight = 0
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
	}

	// *****************************
	// MARK: Core Data
	// *****************************

	private func saveCard(text: String, morse:String, index:Int, textOnTop:Bool = true, favorite:Bool = false, deletable:Bool = true) {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext
		let entity = NSEntityDescription.entityForName("Card", inManagedObjectContext:managedContext)
		let card = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
		card.setValue(text, forKey: "text")
		card.setValue(morse, forKey: "morse")
		card.setValue(index, forKey: "index")
		card.setValue(textOnTop, forKey: "textOnTop")
		card.setValue(favorite, forKey: "favorite")
		card.setValue(deletable, forKey: "deletable")
		card.setValue(NSDate(), forKey: "dateCreated")
		card.setValue("Text Morse", forKey: "transmitterType")

		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Could not save \(error), \(error.userInfo)")
		}
	}

	private func fetchCardsAndUpdateCardViews() {
		// If there is no card on the board, fetch some cards
		if self.cardViews.isEmpty {
			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
			let managedContext = appDelegate.managedObjectContext

			let fetchRequest = NSFetchRequest(entityName: "Card")
			let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
			fetchRequest.sortDescriptors = [sortDescriptor]

			do {
				let results = try managedContext.executeFetchRequest(fetchRequest)
				let cards = results as! [NSManagedObject]
				for card in cards {
					let cardView = MTCardView(frame: CGRect(x: self.cardViewLeftMargin, y: self.cardViewTopMargin, width: self.scrollView.bounds.width - self.cardViewLeftMargin - self.cardViewRightMargin, height: self.cardViewHeight), text: card.valueForKey("text") as? String, morse: card.valueForKey("morse") as? String, textOnTop: card.valueForKey("textOnTop") as! Bool)
					cardView.delegate = self
					self.scrollView.addSubview(cardView)
					self.cardViews.append(cardView)
					self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
					self.updateCardViewsConstraints()
					self.view.layoutIfNeeded()
				}
			} catch let error as NSError {
				print("Could not fetch \(error), \(error.userInfo)")
			}
		}
	}

	private func collapseCurrentExpandedView() {
		let cardView = self.currentExpandedView
		self.currentExpandedView = nil
		cardView?.expanded = false
		self.updateCardViewsConstraints()
		UIView.animateWithDuration(TAP_FEED_BACK_DURATION/3.0 * self.animationDurationScalar,
			delay: 0,
			options: .CurveEaseOut,
			animations: {
				cardView?.backgroundColor = self.theme.cardViewBackgroudColor
				self.scrollView.layoutIfNeeded()
			}) { succeed in
				if succeed {
					cardView?.addMDShadow(withDepth: 1)
				}
		}
	}
}
