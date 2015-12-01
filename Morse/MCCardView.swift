//
//  MCCardView.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MCCardView: UIView {

	private let paddingTop:CGFloat = 16
	private let paddingLeft:CGFloat = 15
	private let paddingRight:CGFloat = 15
	private let paddingBottom:CGFloat = 8
	private let gapY:CGFloat = 10

	var text:String?
	var morse:String?
	var textOnTop = true
	var theme:Theme = .Default
	let defaultMDShadowLevel:Int = 1

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.layer.cornerRadius = 0.0
		self.backgroundColor = self.theme.cardViewBackgroudColor
		self.addMDShadow(withDepth: self.defaultMDShadowLevel)
	}

	convenience init(frame:CGRect, theme:Theme = .Default, text:String?, morse:String?, textOnTop:Bool = true) {
		self.init(frame:frame)
		self.text = text
		self.morse = morse
		self.textOnTop = textOnTop
		self.theme = theme

		let topLabel = UILabel(frame: CGRect(x: self.paddingLeft, y: self.paddingTop, width: self.bounds.width - self.paddingLeft - self.paddingRight, height: (self.bounds.width - self.paddingTop - self.paddingBottom - self.gapY)/2.0))
		topLabel.opaque = false
		topLabel.backgroundColor = UIColor.clearColor()
		topLabel.layer.borderWidth = 0
		topLabel.layer.borderColor = UIColor.clearColor().CGColor
		topLabel.userInteractionEnabled = false
		if self.textOnTop {
			topLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: 16, color: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha))
		} else {
			topLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: 12, color: UIColor(hex: 0x000, alpha: MDDarkTextSecondaryAlpha))
			topLabel.lineBreakMode = .ByClipping
		}
		self.addSubview(topLabel)

		topLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(self).offset(self.paddingTop)
			make.right.equalTo(self).offset(-self.paddingRight)
			make.left.equalTo(self).offset(self.paddingLeft)
			make.height.equalTo((self.bounds.height - self.paddingTop - self.paddingBottom - self.gapY)/2.0)
		}

		let bottomLabel = UILabel(frame: CGRect(x: self.paddingLeft, y: self.paddingTop + topLabel.bounds.height + self.gapY, width: self.bounds.width - self.paddingLeft - self.paddingRight, height: (self.bounds.width - self.paddingTop - self.paddingBottom - self.gapY)/2.0))
		bottomLabel.opaque = false
		bottomLabel.backgroundColor = UIColor.clearColor()
		bottomLabel.layer.borderWidth = 0
		bottomLabel.layer.borderColor = UIColor.clearColor().CGColor
		bottomLabel.userInteractionEnabled = false
		if self.textOnTop {
			bottomLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: 12, color: UIColor(hex: 0x000, alpha: MDDarkTextSecondaryAlpha))
			bottomLabel.lineBreakMode = .ByClipping
		} else {
			bottomLabel.attributedText = getAttributedStringFrom(self.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withFontSize: 16, color: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha))
		}
		self.addSubview(bottomLabel)

		bottomLabel.snp_makeConstraints { (make) -> Void in
			make.top.equalTo(topLabel).offset(self.gapY)
			make.right.equalTo(self).offset(-self.paddingRight)
			make.left.equalTo(self).offset(self.paddingLeft)
			make.bottom.equalTo(self).offset(-self.paddingBottom)
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for touch in touches {
			let location = touch.locationInView(self)
			if self.bounds.contains(location) {
				self.triggerTapFeedBack(atLocation: location, withColor: self.theme.cardViewTapfeedbackColor, duration: TAP_FEED_BACK_DURATION)
			}
		}
	}
}
