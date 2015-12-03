//
//  MCRoundButtonView.swift
//  Morse
//
//  Created by Shuyang Sun on 12/1/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MCRoundButtonView: UIView {

	var originalTransform:CGAffineTransform?
	var originalAlpha:CGFloat = 1.0

	private var theme:Theme {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.theme
	}

	private var shadowLevel:Int {
		return 3
	}

	private var animationDurationScalar:Double {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.animationDurationScalar
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	convenience init(origin:CGPoint, radius:CGFloat) {
		self.init(frame:CGRect(x: origin.x, y: origin.y, width: radius * 2, height: radius * 2))
		self.backgroundColor = self.theme.roundButtonBackgroundColor
		self.layer.cornerRadius = radius
		self.addMDShadow(withDepth: self.shadowLevel)
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for touch in touches {
			let location = touch.locationInView(self)
			if self.bounds.contains(location) {
				self.triggerTapFeedBack(atLocation: location, withColor: self.theme.roundButtonTapFeedbackColor, duration: TAP_FEED_BACK_DURATION)
			}
		}
	}

	func disappearWithAnimationType(animationTypes:Set<AnimationType>, duration:NSTimeInterval) {
		self.originalTransform = self.transform
		self.originalAlpha = self.alpha
		// Define animation here according to animation types, call it later
		let animationClosure = {
			if animationTypes.contains(.Scale) {
				self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01)
			}
			if animationTypes.contains(.Fade) {
				self.alpha = 0.0
			}
			self.addMDShadow(withDepth: 0)
		}
		UIView.animateWithDuration(duration * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: animationClosure) { succeed in
				if succeed {
					self.hidden = true
				}
		}
	}

	func appearWithAnimationType(animationTypes:Set<AnimationType>, duration:NSTimeInterval) {
		// Unhide view first.
		self.hidden = false
		// Define animation here according to animation types, call it later
		let animationClosure = {
			if animationTypes.contains(.Scale) {
				if self.originalTransform != nil {
					self.transform = self.originalTransform!
				} else {
					self.transform = CGAffineTransformIdentity
				}
			}
			if animationTypes.contains(.Fade) {
				self.alpha = self.originalAlpha
			}
			self.addMDShadow(withDepth: self.shadowLevel)
		}
		UIView.animateWithDuration(duration * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: animationClosure, completion: nil)
	}
}

enum AnimationType {
	case Scale
	case Fade
}

