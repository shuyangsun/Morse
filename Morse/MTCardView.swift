//
//  MTCardView.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MTCardView: UIView {

	let paddingTop:CGFloat = 16
	let paddingLeft:CGFloat = 15
	let paddingRight:CGFloat = 15
	let paddingBottom:CGFloat = 16
	let gapY:CGFloat = 10

	var expanded = false

	private var theme:Theme {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.theme
	}

	private var animationDurationScalar:Double {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.animationDurationScalar
	}

	var text:String?
	var morse:String?
	var textOnTop = true
	var delegate:MTCardViewDelegate?
	private let defaultMDShadowLevel:Int = 1

	// Subviews
	var topLabel:UILabel!
	var bottomLabel:UILabel!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.layer.cornerRadius = 2.0
		self.backgroundColor = self.theme.cardViewBackgroudColor
		self.addMDShadow(withDepth: self.defaultMDShadowLevel)
		let tapGR = UITapGestureRecognizer(target: self, action: "tapped:")
		self.addGestureRecognizer(tapGR)
	}

	convenience init(frame:CGRect, text:String?, morse:String?, textOnTop:Bool = true) {
		self.init(frame:frame)
		self.text = text
		self.morse = morse
		self.textOnTop = textOnTop

		self.topLabel = UILabel(frame: CGRect(x: self.paddingLeft, y: self.paddingTop, width: self.bounds.width - self.paddingLeft - self.paddingRight, height: (self.bounds.width - self.paddingTop - self.paddingBottom - self.gapY)/2.0))
		self.topLabel.opaque = false
		self.topLabel.backgroundColor = UIColor.clearColor()
		self.topLabel.layer.borderWidth = 0
		self.topLabel.layer.borderColor = UIColor.clearColor().CGColor
		self.topLabel.userInteractionEnabled = false
		if self.textOnTop {
			self.topLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: 18, color: self.theme.cardViewTextColor)
		} else {
			self.topLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: 18, color: self.theme.cardViewMorseColor)
			self.topLabel.lineBreakMode = .ByWordWrapping
		}
		self.addSubview(self.topLabel)

		self.topLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self).offset(self.paddingTop)
			make.right.equalTo(self).offset(-self.paddingRight)
			make.left.equalTo(self).offset(self.paddingLeft)
			make.height.equalTo((self.bounds.height - self.paddingTop - self.paddingBottom - self.gapY)/2.0)
		}

		self.bottomLabel = UILabel(frame: CGRect(x: self.paddingLeft, y: self.paddingTop + self.topLabel.bounds.height + self.gapY, width: self.bounds.width - self.paddingLeft - self.paddingRight, height: (self.bounds.width - self.paddingTop - self.paddingBottom - self.gapY)/2.0))
		self.bottomLabel.opaque = false
		self.bottomLabel.backgroundColor = UIColor.clearColor()
		self.bottomLabel.layer.borderWidth = 0
		self.bottomLabel.layer.borderColor = UIColor.clearColor().CGColor
		self.bottomLabel.userInteractionEnabled = false
		if self.textOnTop {
			self.bottomLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: 18, color: self.theme.cardViewMorseColor)
			self.bottomLabel.lineBreakMode = .ByWordWrapping
		} else {
			// TODO: Capitalize each word at the beginning of the sentence?
			self.bottomLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: 18, color: self.theme.cardViewTextColor)
		}
		self.addSubview(bottomLabel)

		self.bottomLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self.topLabel.snp_bottom).offset(self.gapY)
			make.right.equalTo(self).offset(-self.paddingRight)
			make.left.equalTo(self).offset(self.paddingLeft)
			make.bottom.equalTo(self).offset(-self.paddingBottom)
		}
	}

	required init?(coder aCoder: NSCoder) {
		super.init(coder: aCoder)
	}

	func tapped(gestureRecognizer:UITapGestureRecognizer) {
		let location = gestureRecognizer.locationInView(self)
		if self.bounds.contains(location) {
			self.animateUserInteractionFeedbackAtLocation(location)
			if let myDelegate = self.delegate {
				myDelegate.cardViewTapped(self)
			}
		}
	}

	private func animateUserInteractionFeedbackAtLocation(location:CGPoint, completion:((Void) -> Void)? = nil) {
		let originalTransform = self.transform
		if !self.expanded {
			self.triggerTapFeedBack(atLocation: location, withColor: self.theme.cardViewTapfeedbackColor, duration: TAP_FEED_BACK_DURATION * self.animationDurationScalar)
		}
		UIView.animateWithDuration(TAP_FEED_BACK_DURATION/5.0 * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseIn,
			animations: {
				self.transform = CGAffineTransformScale(self.transform, 1.02, 1.02)
				self.addMDShadow(withDepth: self.defaultMDShadowLevel + 1)
			}) { succeed in
				if succeed {
					UIView.animateWithDuration(TAP_FEED_BACK_DURATION/5.0 * self.animationDurationScalar,
						delay: 0.0,
						options: .CurveEaseOut,
						animations: {
							self.transform = originalTransform
							self.addMDShadow(withDepth: self.defaultMDShadowLevel)
						}) { succeed in
							if succeed {
								if completion != nil {
									completion!()
								}
							}
					}
				}
		}
	}
}
