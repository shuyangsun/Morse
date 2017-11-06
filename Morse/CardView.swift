//
//  CardView.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class CardView: UIView {
	var expanded = false {
		didSet {
			self.updateExpandButton()
		}
	}
	var flipped = false
	var isProsignCard = false
	var isProsignEmergencyCard = false

	var canBeExpanded:Bool {
		// Calculate if we need to expand the card.
		let labelWidth = self.topLabel.bounds.width
		// FIX ME: Calculation not right, should use the other way, but it has a BUG.
		return ceil(self.topLabel.attributedText!.size().width/labelWidth) > 1 || ceil(self.bottomLabel.attributedText!.size().width/labelWidth) > 1
	}

	// UI related variables
	fileprivate var _swipping = false
	fileprivate var _touchBeganPosition:CGPoint!
	fileprivate var _distanceToDeleteCard:CGFloat {
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
	var expandButton:UIButton!
	var backView:UIView!
	var outputButton:UIButton!
	var shareButton:UIButton!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.layer.cornerRadius = theme.cardViewCornerRadius
		self.layer.borderWidth = theme.cardViewBorderWidth
		self.layer.borderColor = theme.cardViewBorderColor.cgColor
		self.isOpaque = false
		self.backgroundColor = appDelegate.theme.cardViewBackgroudColor
		self.addMDShadow(withDepth: appDelegate.theme.cardViewMDShadowLevelDefault)
		let holdGR = UILongPressGestureRecognizer(target: self, action: #selector(held(_:)))
		self.addGestureRecognizer(holdGR)

		let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
		self.addGestureRecognizer(tapGR)
	}

	convenience init(frame:CGRect, text:String?, morse:String?, textOnTop:Bool = true, deletable:Bool = true, canBeFlipped:Bool = true, textFontSize:CGFloat = 16, morseFontSize:CGFloat = 14, isProsignCard:Bool = false, isProsignEmergencyCard:Bool = false) {
		self.init(frame:frame)
		self.text = text
		self.morse = morse
		self.textOnTop = textOnTop
		self.deletable = deletable
		self.canBeFlipped = canBeFlipped
		self.isProsignCard = isProsignCard
		self.isProsignEmergencyCard = isProsignEmergencyCard
		if isProsignEmergencyCard {
			self.backgroundColor = theme.cardViewProsignEmergencyBackgroundColor
		} else if isProsignCard {
			self.backgroundColor = theme.cardViewProsignBackgroudColor
		}

		self.topLabel = UILabel(frame: CGRect(x: cardViewLabelPaddingHorizontal, y: cardViewLabelPaddingVerticle, width: self.bounds.width - cardViewLabelPaddingHorizontal * 2, height: (self.bounds.width - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0))
		self.topLabel.isOpaque = false
		self.topLabel.backgroundColor = UIColor.clear
		self.topLabel.layer.borderWidth = 0
		self.topLabel.layer.borderColor = UIColor.clear.cgColor
		self.topLabel.isUserInteractionEnabled = false
		var textColor = theme.cardViewTextColor
		var morseColor = theme.cardViewMorseColor
		if isProsignEmergencyCard {
			textColor = theme.cardViewProsignEmergencyTextColor
			morseColor = theme.cardViewProsignEmergencyMorseColor
		} else if isProsignCard {
			textColor = theme.cardViewProsignTextColor
			morseColor = theme.cardViewProsignMorseColor
		}
		if self.textOnTop {
			self.topLabel.attributedText = getAttributedStringFrom(self.text?.trimmingCharacters(in: CharacterSet.whitespaces), withFontSize: textFontSize, color: textColor, bold: true)
		} else {
			self.topLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: morseFontSize, color: morseColor)
			self.topLabel.lineBreakMode = .byWordWrapping
		}
		self.addSubview(self.topLabel)
		self.topLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self).offset(cardViewLabelPaddingVerticle)
			make.trailing.equalTo(self).offset(-cardViewLabelPaddingHorizontal)
			make.leading.equalTo(self).offset(cardViewLabelPaddingHorizontal)
			make.height.equalTo((self.bounds.height - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0)
		}

		self.bottomLabel = UILabel(frame: CGRect(x: cardViewLabelPaddingHorizontal, y: cardViewLabelPaddingVerticle + self.topLabel.bounds.height + cardViewLabelVerticalGap, width: self.bounds.width - cardViewLabelPaddingHorizontal * 2, height: (self.bounds.width - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0))
		self.bottomLabel.isOpaque = false
		self.bottomLabel.backgroundColor = UIColor.clear
		self.bottomLabel.layer.borderWidth = 0
		self.bottomLabel.layer.borderColor = UIColor.clear.cgColor
		self.bottomLabel.isUserInteractionEnabled = false
		if self.textOnTop {
			self.bottomLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: morseFontSize, color: morseColor)
			self.bottomLabel.lineBreakMode = .byWordWrapping
		} else {
			// TODO: Capitalize each word at the beginning of the sentence?
			self.bottomLabel.attributedText = getAttributedStringFrom(self.text?.trimmingCharacters(in: CharacterSet.whitespaces), withFontSize: textFontSize, color: textColor, bold: true)
		}
		self.addSubview(bottomLabel)
		self.bottomLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self.topLabel.snp_bottom).offset(cardViewLabelVerticalGap)
			make.trailing.equalTo(self).offset(-cardViewLabelPaddingHorizontal)
			make.leading.equalTo(self).offset(cardViewLabelPaddingHorizontal)
			make.bottom.equalTo(self).offset(-cardViewLabelPaddingVerticle)
		}

		if self.expandButton == nil {
			self.expandButton = UIButton()
			let image = UIImage(named: theme.cardViewExpandButtonImageName)!.withRenderingMode(.alwaysTemplate)
			self.expandButton.setImage(image, for: UIControlState())
			self.expandButton.tintColor = theme.cardViewExpandButtonColor
			self.expandButton.alpha = 0
//			self.expandButton.addTarget(self, action: "expandCard", forControlEvents: .TouchUpInside)
			self.addSubview(self.expandButton)
			self.expandButton.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self).offset(cardViewExpandButtonPadding)
				make.trailing.equalTo(self).offset(-cardViewExpandButtonPadding)
			})
		}

		self.updateExpandButton()
	}

	required init?(coder aCoder: NSCoder) {
		super.init(coder: aCoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if self.canBeExpanded {
			// TODO
		}
	}

	// *****************************
	// MARK: Callbacks
	// *****************************

	// This method will be triggered by call back on expand button, or a hold gesture.
	func expandCard() {
		self.delegate?.cardViewHeld?(self)
	}

	func held(_ gestureRecognizer:UILongPressGestureRecognizer) {
		if !self.flipped {
			if gestureRecognizer.state == .began {
				let location = gestureRecognizer.location(in: self)
				if self.bounds.contains(location) {
					self.animateUserInteractionFeedbackAtLocation(location) {
						self.expandCard()
					}
				}
			}
		}
	}

	func tapped(_ gestureRecognizer:UITapGestureRecognizer) {
		// Animate feedback
		let location = gestureRecognizer.location(in: self)
		if self.bounds.contains(location) {
			self.animateUserInteractionFeedbackAtLocation(location) {
				if let myDelegate = self.delegate {
					myDelegate.cardViewTapped?(self)
				}
			}
		}

		// Add back views first
		if !self.expanded && self.canBeFlipped {
			self.updateBackView()
		}
	}

	func backViewButtonTapped(_ button:UIButton) {
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
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.delegate?.cardViewTouchesBegan?(self, touches:touches, withEvent: event)
		if let touch = touches.first {
			self._touchBeganPosition = touch.location(in: self.superview!)
		}
	}

	// Do some animation when the user is swipping the card.
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let swipeDecidingDistance:CGFloat = 10
		let touch = touches.first!
		let dtX = touch.location(in: self.superview!).x - self._touchBeganPosition.x
		let dtY = touch.location(in: self.superview!).y - self._touchBeganPosition.y
		// If the user is swipping left or right
		let scrollView = self.next as? UIScrollView
		if self._swipping && abs(dtX)/abs(dtY) >= 0.1 {
			scrollView?.isScrollEnabled = false
		} else {
			scrollView?.isScrollEnabled = true
		}
		if !touches.isEmpty && self._touchBeganPosition != nil {
			// User is trying to delete the card.
			if abs(dtX) > swipeDecidingDistance {
				self._swipping = true
			}
			if self.deletable && self._swipping {
				let distanceToStartRotation:CGFloat = 15
				// Translate
				self.transform = CGAffineTransform(translationX: dtX, y: 0)
				// Change alpha
				self.alpha = 1.0 - abs(dtX)/self.bounds.width
				// Rotate
				if abs(dtX) > distanceToStartRotation {
					var angle = CGFloat(Double((abs(dtX) - distanceToStartRotation)/(self._distanceToDeleteCard - distanceToStartRotation)) * M_PI_4)/2.0
					if dtX < 0 {
						angle = -angle
					}
					self.transform = self.transform.rotated(by: angle)
				}
			}
		}
	}

	// When user finish swipping the card, do something depends on the direction and distance of swipe.
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self._swipping && self.deletable {
			let touch = touches.first!
			let dtX = touch.location(in: self.superview!).x - self._touchBeganPosition.x
			if abs(dtX) >= self._distanceToDeleteCard {
				// If swipped too far, delete card.
				UIView.animate(withDuration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
					delay: 0,
					options: .curveLinear,
					animations: {
						self.alpha = 0
				}, completion: nil)
				self.delegate?.cardViewTouchesEnded?(self, touches:touches, withEvent: event, deleteCard: true)
			} else {
				// If not far enough, restore cardView transform to identity
				UIView.animate(withDuration: TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
					delay: 0,
					options: .curveEaseOut,
					animations: {
						self.transform = CGAffineTransform.identity
						self.alpha = 1
					}) { succeed in
						self.delegate?.cardViewTouchesEnded?(self, touches:touches, withEvent: event, deleteCard: false)
				}
			}
		}

		self._swipping = false
		let scrollView = self.next as? UIScrollView
		scrollView?.isScrollEnabled = true
	}

	// If the touch is canceled, always restore cardView and don't anything about the model.
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self._swipping && self.deletable {
			UIView.animate(withDuration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
				delay: 0,
				options: .curveEaseOut,
				animations: {
					self.transform = CGAffineTransform.identity
					self.alpha = 1
				}) { succeed in
					self.delegate?.cardViewTouchesCancelled?(self, touches:touches, withEvent: event)
			}
		}
		self._swipping = false
		let scrollView = self.next as? UIScrollView
		scrollView?.isScrollEnabled = true
	}

	// *****************************
	// MARK: Animation Functions
	// *****************************

	// Fliping card
	func flip(_ completion:((Void)->Void)? = nil) {
		if self.flipped {
			// Flip to front
			self.flipped = false // Do NOT move this line to completion block! Will cause bugs.
			UIView.transition(with: self,
				duration: defaultAnimationDuration/2.0 * appDelegate.animationDurationScalar,
				options: .transitionFlipFromBottom,
				animations: {
					self.topLabel.isHidden = false
					self.bottomLabel.isHidden = false
					self.backView.isHidden = true
				}) { succeed in
					completion?()
			}
		} else {
			// Flip to back
			// Add back views first
			if !self.expanded && self.canBeFlipped {
				self.updateBackView()
			}
			self.flipped = true // Do NOT move this line to completion block! Will cause bugs.
			UIView.transition(with: self,
				duration: defaultAnimationDuration/2.0 * appDelegate.animationDurationScalar,
				options: .transitionFlipFromTop,
				animations: {
					self.topLabel.isHidden = true
					self.bottomLabel.isHidden = true
					self.backView.isHidden = false
				}){ succeed in
					completion?()
			}
		}
	}

	fileprivate func animateUserInteractionFeedbackAtLocation(_ location:CGPoint, completion:((Void) -> Void)? = nil) {
		let originalTransform = self.transform
		let animationDuration:TimeInterval = TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar
		self.triggerTapFeedBack(atLocation: location, withColor: appDelegate.theme.cardViewTapfeedbackColor, duration: animationDuration, showSurfaceReaction: true, completion: completion)
		UIView.animate(withDuration: TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: .curveEaseIn,
			animations: {
				self.transform = self.transform.scaledBy(x: 1.04, y: 1.04)
			}) { succeed in
				UIView.animate(withDuration: TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
					delay: 0.0,
					options: .curveEaseOut,
					animations: {
						self.transform = originalTransform
					}, completion: nil)
		}
	}

	fileprivate func updateBackView() {
		if self.backView == nil {
			self.backView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
			self.addSubview(self.backView)
			self.backView.snp_remakeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			self.backView.isHidden = true
		}
		self.backView.backgroundColor = theme.cardBackViewBackgroundColor
		self.backView.layer.cornerRadius = self.layer.cornerRadius

		if self.outputButton == nil {
			self.outputButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.bounds.width/2.0, height: self.bounds.height))
			self.outputButton.backgroundColor = UIColor.clear
			let outputImage = UIImage(named: theme.outputImageName)!.withRenderingMode(.alwaysTemplate)
			self.outputButton.setImage(outputImage, for: UIControlState())
			self.outputButton.addTarget(self, action: #selector(CardView.backViewButtonTapped(_:)), for: .touchUpInside)
			self.backView.addSubview(self.outputButton)
			self.outputButton.snp_remakeConstraints { (make) -> Void in
				make.width .equalTo(cardBackViewButtonWidth)
				make.height.equalTo(cardBackViewButtonHeight)
				make.centerX.equalTo(self).offset(-self.bounds.width/4.0)
				make.centerY.equalTo(self)
			}
		}

		self.outputButton.tintColor = theme.buttonWithAccentBackgroundTintColor

		if self.shareButton == nil {
			self.shareButton = UIButton(frame: CGRect(x: self.bounds.width/2.0, y: 0, width: self.bounds.width/2.0, height: self.bounds.height))
			self.shareButton.backgroundColor = UIColor.clear
			let shareImage = UIImage(named: theme.shareImageName)?.withRenderingMode(.alwaysTemplate)
			self.shareButton.setImage(shareImage!, for: UIControlState())
			self.shareButton.addTarget(self, action: #selector(backViewButtonTapped(_:)), for: .touchUpInside)
			self.backView.addSubview(self.shareButton)
			self.shareButton.snp_remakeConstraints { (make) -> Void in
				make.width .equalTo(cardBackViewButtonWidth)
				make.height.equalTo(cardBackViewButtonHeight)
				make.centerX.equalTo(self).offset(self.bounds.width/4.0)
				make.centerY.equalTo(self)
			}
		}
		self.shareButton.tintColor = theme.buttonWithAccentBackgroundTintColor
	}

	func updateExpandButton() {
		UIView.animateWithScaledDuration(defaultAnimationDuration,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				if self.canBeExpanded && !self.expanded {
					self.expandButton.alpha = 1
				} else {
					self.expandButton.alpha = 0
				}
			}, completion: nil)
	}
}

enum CardManipulationType {
	case delete
	case showActions
}
