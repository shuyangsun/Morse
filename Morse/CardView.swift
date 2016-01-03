//
//  CardView.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class CardView: UIView {
	var expanded = false
	var flipped = false

	var canBeExpanded:Bool {
		// Calculate if we need to expand the card.
		let labelWidth = self.topLabel.bounds.width
		// FIX ME: Calculation not right, should use the other way, but it has a BUG.
		return ceil(self.topLabel.attributedText!.size().width/labelWidth) > 1 || ceil(self.bottomLabel.attributedText!.size().width/labelWidth) > 1
	}

	// UI related variables
	private var _swipping = false
	private var _touchBeganPosition:CGPoint!
	private var _distanceToDeleteCard:CGFloat {
		// How far the user needs to swipe to delete the card
		return min(360, self.bounds.width/2.0)
	}

	// User setting related variables

	var text:String?
	var morse:String?
	var textOnTop = true
	var cardUniqueID:Int?
	var delegate:CardViewDelegate?
	var deletable:Bool = true
	var canBeFlipped:Bool = true

	// Subviews
	var topLabel:UILabel!
	var bottomLabel:UILabel!
	var backView:UIView!
	var outputButton:UIButton!
	var shareButton:UIButton!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.layer.cornerRadius = theme.cardViewCornerRadius
		self.layer.borderWidth = theme.cardViewBorderWidth
		self.layer.borderColor = theme.cardViewBorderColor.CGColor
		self.opaque = false
		self.backgroundColor = appDelegate.theme.cardViewBackgroudColor
		self.addMDShadow(withDepth: appDelegate.theme.cardViewMDShadowLevelDefault)
		let holdGR = UILongPressGestureRecognizer(target: self, action: "held:")
		self.addGestureRecognizer(holdGR)

		let tapGR = UITapGestureRecognizer(target: self, action: "tapped:")
		self.addGestureRecognizer(tapGR)
	}

	convenience init(frame:CGRect, text:String?, morse:String?, textOnTop:Bool = true, deletable:Bool = true, canBeFlipped:Bool = true, textFontSize:CGFloat = 16, morseFontSize:CGFloat = 14) {
		self.init(frame:frame)
		self.text = text
		self.morse = morse
		self.textOnTop = textOnTop
		self.deletable = deletable
		self.canBeFlipped = canBeFlipped

		self.topLabel = UILabel(frame: CGRect(x: cardViewLabelPaddingHorizontal, y: cardViewLabelPaddingVerticle, width: self.bounds.width - cardViewLabelPaddingHorizontal * 2, height: (self.bounds.width - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0))
		self.topLabel.opaque = false
		self.topLabel.backgroundColor = UIColor.clearColor()
		self.topLabel.layer.borderWidth = 0
		self.topLabel.layer.borderColor = UIColor.clearColor().CGColor
		self.topLabel.userInteractionEnabled = false
		if self.textOnTop {
			self.topLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: textFontSize, color: appDelegate.theme.cardViewTextColor, bold: true)
		} else {
			self.topLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: morseFontSize, color: appDelegate.theme.cardViewMorseColor)
			self.topLabel.lineBreakMode = .ByWordWrapping
		}
		self.addSubview(self.topLabel)

		self.topLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self).offset(cardViewLabelPaddingVerticle)
			make.trailing.equalTo(self).offset(-cardViewLabelPaddingHorizontal)
			make.leading.equalTo(self).offset(cardViewLabelPaddingHorizontal)
			make.height.equalTo((self.bounds.height - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0)
		}

		self.bottomLabel = UILabel(frame: CGRect(x: cardViewLabelPaddingHorizontal, y: cardViewLabelPaddingVerticle + self.topLabel.bounds.height + cardViewLabelVerticalGap, width: self.bounds.width - cardViewLabelPaddingHorizontal * 2, height: (self.bounds.width - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0))
		self.bottomLabel.opaque = false
		self.bottomLabel.backgroundColor = UIColor.clearColor()
		self.bottomLabel.layer.borderWidth = 0
		self.bottomLabel.layer.borderColor = UIColor.clearColor().CGColor
		self.bottomLabel.userInteractionEnabled = false
		if self.textOnTop {
			self.bottomLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: morseFontSize, color: appDelegate.theme.cardViewMorseColor)
			self.bottomLabel.lineBreakMode = .ByWordWrapping
		} else {
			// TODO: Capitalize each word at the beginning of the sentence?
			self.bottomLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: textFontSize, color: appDelegate.theme.cardViewTextColor, bold: true)
		}
		self.addSubview(bottomLabel)

		self.bottomLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self.topLabel.snp_bottom).offset(cardViewLabelVerticalGap)
			make.trailing.equalTo(self).offset(-cardViewLabelPaddingHorizontal)
			make.leading.equalTo(self).offset(cardViewLabelPaddingHorizontal)
			make.bottom.equalTo(self).offset(-cardViewLabelPaddingVerticle)
		}
	}

	required init?(coder aCoder: NSCoder) {
		super.init(coder: aCoder)
	}

	// *****************************
	// MARK: Callbacks
	// *****************************

	func held(gestureRecognizer:UILongPressGestureRecognizer) {
		if !self.flipped {
			if gestureRecognizer.state == .Began {
				let location = gestureRecognizer.locationInView(self)
				if self.bounds.contains(location) {
					if let myDelegate = self.delegate {
						if myDelegate.cardViewHeld != nil {
							self.animateUserInteractionFeedbackAtLocation(location) {
								myDelegate.cardViewHeld!(self)
							}
						}
					}
				}
			}
		}
	}

	func tapped(gestureRecognizer:UITapGestureRecognizer) {
		// Animate feedback
		let location = gestureRecognizer.locationInView(self)
		if self.bounds.contains(location) {
			self.animateUserInteractionFeedbackAtLocation(location) {
				if let myDelegate = self.delegate {
					myDelegate.cardViewTapped?(self)
				}
			}
		}

		// Add back views first
		if !self.expanded && self.canBeFlipped {
			self.addBackView()
		}
	}

	func backViewButtonTapped(button:UIButton) {
		if button === self.outputButton {
			self.delegate?.cardViewOutputButtonTapped?(self)
		} else if button === self.shareButton {
			self.delegate?.cardViewShareButtonTapped?(self)
		}
	}

	// *****************************
	// MARK: User Interaction Handlers
	// *****************************

	// Do some initial setup when the user start touching this view.
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.delegate?.cardViewTouchesBegan?(self, touches:touches, withEvent: event)
		if let touch = touches.first {
			self._touchBeganPosition = touch.locationInView(self.superview!)
		}
	}

	// Do some animation when the user is swipping the card.
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let swipeDecidingDistance:CGFloat = 10
		let touch = touches.first!
		let dtX = touch.locationInView(self.superview!).x - self._touchBeganPosition.x
		let dtY = touch.locationInView(self.superview!).y - self._touchBeganPosition.y
		// If the user is swipping left or right
		let scrollView = self.nextResponder() as? UIScrollView
		if self._swipping && abs(dtX)/abs(dtY) >= 0.1 {
			scrollView?.scrollEnabled = false
		} else {
			scrollView?.scrollEnabled = true
		}
		if !touches.isEmpty && self._touchBeganPosition != nil {
			// User is trying to delete the card.
			if abs(dtX) > swipeDecidingDistance {
				self._swipping = true
			}
			if self.deletable && self._swipping {
				let distanceToStartRotation:CGFloat = 15
				// Translate
				self.transform = CGAffineTransformMakeTranslation(dtX, 0)
				// Change alpha
				self.alpha = 1.0 - abs(dtX)/self.bounds.width
				// Rotate
				if abs(dtX) > distanceToStartRotation {
					var angle = CGFloat(Double((abs(dtX) - distanceToStartRotation)/(self._distanceToDeleteCard - distanceToStartRotation)) * M_PI_4)/2.0
					if dtX < 0 {
						angle = -angle
					}
					self.transform = CGAffineTransformRotate(self.transform, angle)
				}
			}
		}
	}

	// When user finish swipping the card, do something depends on the direction and distance of swipe.
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if self._swipping && self.deletable {
			let touch = touches.first!
			let dtX = touch.locationInView(self.superview!).x - self._touchBeganPosition.x
			if abs(dtX) >= self._distanceToDeleteCard {
				// If swipped too far, delete card.
				UIView.animateWithDuration(TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
					delay: 0,
					options: .CurveLinear,
					animations: {
						self.alpha = 0
				}, completion: nil)
				self.delegate?.cardViewTouchesEnded?(self, touches:touches, withEvent: event, deleteCard: true)
			} else {
				// If not far enough, restore cardView transform to identity
				UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
					delay: 0,
					options: .CurveEaseOut,
					animations: {
						self.transform = CGAffineTransformIdentity
						self.alpha = 1
					}) { succeed in
						if succeed {
							self.delegate?.cardViewTouchesEnded?(self, touches:touches, withEvent: event, deleteCard: false)
						}
				}
			}
		}

		self._swipping = false
		let scrollView = self.nextResponder() as? UIScrollView
		scrollView?.scrollEnabled = true
	}

	// If the touch is canceled, always restore cardView and don't anything about the model.
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		if self._swipping && self.deletable {
			UIView.animateWithDuration(TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
				delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.transform = CGAffineTransformIdentity
					self.alpha = 1
				}) { succeed in
					if succeed {
						self.delegate?.cardViewTouchesCancelled?(self, touches:touches, withEvent: event)
					}
			}
		}
		self._swipping = false
		let scrollView = self.nextResponder() as? UIScrollView
		scrollView?.scrollEnabled = true
	}

	// *****************************
	// MARK: Animation Functions
	// *****************************

	// Fliping card
	func flip() {
		if self.flipped {
			// Flip to front
			self.flipped = false // Do NOT move this line to completion block! Will cause bugs.
			UIView.transitionWithView(self,
				duration: defaultAnimationDuration/2.0 * appDelegate.animationDurationScalar,
				options: .TransitionFlipFromBottom,
				animations: {
					self.topLabel.hidden = false
					self.bottomLabel.hidden = false
					self.backView.hidden = true
				}, completion: nil)
		} else {
			// Flip to back
			// Add back views first
			if !self.expanded && self.canBeFlipped {
				self.addBackView()
			}
			self.flipped = true // Do NOT move this line to completion block! Will cause bugs.
			UIView.transitionWithView(self,
				duration: defaultAnimationDuration/2.0 * appDelegate.animationDurationScalar,
				options: .TransitionFlipFromTop,
				animations: {
					self.topLabel.hidden = true
					self.bottomLabel.hidden = true
					self.backView.hidden = false
				}, completion: nil)
		}
	}

	private func animateUserInteractionFeedbackAtLocation(location:CGPoint, completion:((Void) -> Void)? = nil) {
		let originalTransform = self.transform
		let animationDuration:NSTimeInterval = TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar
		self.triggerTapFeedBack(atLocation: location, withColor: appDelegate.theme.cardViewTapfeedbackColor, duration: animationDuration, showSurfaceReaction: true, completion: completion)
		UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseIn,
			animations: {
				self.transform = CGAffineTransformScale(self.transform, 1.04, 1.04)
			}) { succeed in
				if succeed {
					UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
						delay: 0.0,
						options: .CurveEaseOut,
						animations: {
							self.transform = originalTransform
						}, completion: nil)
				}
		}
	}

	private func addBackView() {
		if self.backView == nil {
			self.backView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
			self.backView.backgroundColor = appDelegate.theme.cardBackViewBackgroundColor
			self.backView.layer.cornerRadius = self.layer.cornerRadius
			self.addSubview(self.backView)
			self.backView.snp_remakeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			self.backView.hidden = true
		}

		if self.outputButton == nil {
			self.outputButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.bounds.width/2.0, height: self.bounds.height))
			self.outputButton.backgroundColor = UIColor.clearColor()
			self.outputButton.tintColor = appDelegate.theme.cardBackViewButtonTextColor
			self.outputButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
			self.outputButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
			self.outputButton.setTitle(LocalizedStrings.Button.output, forState: .Normal)
			self.outputButton.addTarget(self, action: "backViewButtonTapped:", forControlEvents: .TouchUpInside)
			// Change the size of button to only fit title label
			var strSize = self.outputButton.bounds.size
			if let size = self.outputButton.titleLabel?.attributedText?.size() {
				// Make the button a little bit larger
				strSize = CGSize(width: size.width + cardBackViewButtonPadding * 2, height: size.height + cardBackViewButtonPadding * 2)
			}
			self.outputButton.bounds.size = strSize
			self.backView.addSubview(self.outputButton)
			self.outputButton.snp_remakeConstraints { (make) -> Void in
				make.width .equalTo(strSize.width)
				make.height.equalTo(strSize.height)
				make.centerX.equalTo(self).offset(-self.bounds.width/4.0)
				make.centerY.equalTo(self)
			}
		}

		if self.shareButton == nil {
			self.shareButton = UIButton(frame: CGRect(x: self.bounds.width/2.0, y: 0, width: self.bounds.width/2.0, height: self.bounds.height))
			self.shareButton.backgroundColor = UIColor.clearColor()
			self.shareButton.tintColor = appDelegate.theme.cardBackViewButtonTextColor
			self.shareButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
			self.shareButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
			self.shareButton.setTitle(LocalizedStrings.Button.share, forState: .Normal)
			self.shareButton.addTarget(self, action: "backViewButtonTapped:", forControlEvents: .TouchUpInside)
			// Change the size of button to only fit title label
			var strSize = self.shareButton.bounds.size
			if let size = self.shareButton.titleLabel?.attributedText?.size() {
				// Make the button a little bit larger
				strSize = CGSize(width: size.width + cardBackViewButtonPadding * 2, height: size.height + cardBackViewButtonPadding * 2)
			}
			self.shareButton.bounds.size = strSize
			self.backView.addSubview(self.shareButton)
			self.shareButton.snp_remakeConstraints { (make) -> Void in
				make.width .equalTo(strSize.width)
				make.height.equalTo(strSize.height)
				make.centerX.equalTo(self).offset(self.bounds.width/4.0)
				make.centerY.equalTo(self)
			}
		}
	}
}

enum CardManipulationType {
	case Delete
	case ShowActions
}
