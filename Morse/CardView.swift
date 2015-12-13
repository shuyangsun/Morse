//
//  CardView.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class CardView: UIView {

	let paddingTop:CGFloat = 16
	let paddingLeading:CGFloat = 15
	let paddingTrailing:CGFloat = 15
	let paddingBottom:CGFloat = 16
	let gapY:CGFloat = 10

	var expanded = false

	// User setting related variables

	var text:String?
	var morse:String?
	var textOnTop = true
	var uniqueID:Int?
	var delegate:CardViewDelegate?
	private let defaultMDShadowLevel:Int = 1

	// Subviews
	var topLabel:UILabel!
	var bottomLabel:UILabel!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.layer.cornerRadius = 2.0
		self.backgroundColor = appDelegate.theme.cardViewBackgroudColor
		self.addMDShadow(withDepth: self.defaultMDShadowLevel)
		let tapGR = UITapGestureRecognizer(target: self, action: "tapped:")
		self.addGestureRecognizer(tapGR)
	}

	convenience init(frame:CGRect, text:String?, morse:String?, textOnTop:Bool = true) {
		self.init(frame:frame)
		self.text = text
		self.morse = morse
		self.textOnTop = textOnTop

		self.topLabel = UILabel(frame: CGRect(x: self.paddingLeading, y: self.paddingTop, width: self.bounds.width - self.paddingLeading - self.paddingTrailing, height: (self.bounds.width - self.paddingTop - self.paddingBottom - self.gapY)/2.0))
		self.topLabel.opaque = false
		self.topLabel.backgroundColor = UIColor.clearColor()
		self.topLabel.layer.borderWidth = 0
		self.topLabel.layer.borderColor = UIColor.clearColor().CGColor
		self.topLabel.userInteractionEnabled = false
		if self.textOnTop {
			self.topLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: 16, color: appDelegate.theme.cardViewTextColor, bold: true)
		} else {
			self.topLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: 14, color: appDelegate.theme.cardViewMorseColor)
			self.topLabel.lineBreakMode = .ByWordWrapping
		}
		self.addSubview(self.topLabel)

		self.topLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self).offset(self.paddingTop)
			make.trailing.equalTo(self).offset(-self.paddingTrailing)
			make.leading.equalTo(self).offset(self.paddingLeading)
			make.height.equalTo((self.bounds.height - self.paddingTop - self.paddingBottom - self.gapY)/2.0)
		}

		self.bottomLabel = UILabel(frame: CGRect(x: self.paddingLeading, y: self.paddingTop + self.topLabel.bounds.height + self.gapY, width: self.bounds.width - self.paddingLeading - self.paddingTrailing, height: (self.bounds.width - self.paddingTop - self.paddingBottom - self.gapY)/2.0))
		self.bottomLabel.opaque = false
		self.bottomLabel.backgroundColor = UIColor.clearColor()
		self.bottomLabel.layer.borderWidth = 0
		self.bottomLabel.layer.borderColor = UIColor.clearColor().CGColor
		self.bottomLabel.userInteractionEnabled = false
		if self.textOnTop {
			self.bottomLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: 14, color: appDelegate.theme.cardViewMorseColor)
			self.bottomLabel.lineBreakMode = .ByWordWrapping
		} else {
			// TODO: Capitalize each word at the beginning of the sentence?
			self.bottomLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: 16, color: appDelegate.theme.cardViewTextColor, bold: true)
		}
		self.addSubview(bottomLabel)

		self.bottomLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self.topLabel.snp_bottom).offset(self.gapY)
			make.trailing.equalTo(self).offset(-self.paddingTrailing)
			make.leading.equalTo(self).offset(self.paddingLeading)
			make.bottom.equalTo(self).offset(-self.paddingBottom)
		}
	}

	required init?(coder aCoder: NSCoder) {
		super.init(coder: aCoder)
	}

	func tapped(gestureRecognizer:UITapGestureRecognizer) {
		let location = gestureRecognizer.locationInView(self)
		if self.bounds.contains(location) {
			self.animateUserInteractionFeedbackAtLocation(location) {
				if let myDelegate = self.delegate {
					myDelegate.cardViewTapped(self)
				}
			}
		}
	}

	private func animateUserInteractionFeedbackAtLocation(location:CGPoint, completion:((Void) -> Void)? = nil) {
		let originalTransform = self.transform
		self.triggerTapFeedBack(atLocation: location, withColor: appDelegate.theme.cardViewTapfeedbackColor, duration: TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar, showSurfaceReaction: true, completion: completion)
		UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseIn,
			animations: {
				self.transform = CGAffineTransformScale(self.transform, 1.02, 1.02)
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
}
