//
//  RoundButtonView.swift
//  Morse
//
//  Created by Shuyang Sun on 12/1/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

enum ButtonActionType {
	case Switch
}

class RoundButtonView: UIView {
	var buttonAction:ButtonActionType = .Switch
	var backgroundImageView:UIImageView!

	private var animationDurationScalar:Double {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.animationDurationScalar
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	convenience init(origin:CGPoint, radius:CGFloat) {
		self.init(frame:CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2)))
		let backgroundImage = UIImage(named: "Round Button")
		self.backgroundImageView = UIImageView(frame: self.bounds)
		self.backgroundImageView.image = backgroundImage

		self.addSubview(self.backgroundImageView)
		self.opaque = false
		self.backgroundColor = appDelegate.theme.roundButtonBackgroundColor
		self.layer.cornerRadius = radius
		self.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}

	func disappearWithAnimationType(animationTypes:Set<AnimationType>, duration:NSTimeInterval, completion:((Void)->Void)? = nil) {
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
					self.userInteractionEnabled = false
					completion?()
				}
		}
	}

	func appearWithAnimationType(animationTypes:Set<AnimationType>, duration:NSTimeInterval) {
		// Unhide view first.
		self.hidden = false
		// Define animation here according to animation types, call it later
		let animationClosure = {
			if animationTypes.contains(.Scale) {
				self.transform = CGAffineTransformIdentity
			}
			if animationTypes.contains(.Fade) {
				self.alpha = 1
				self.userInteractionEnabled = true
			}
			self.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
		}
		UIView.animateWithDuration(duration * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: animationClosure, completion: nil)
	}

	func rotateBackgroundImageWithDuration(duration:NSTimeInterval) {
		UIView.animateWithDuration(duration / 2.0 * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveLinear,
			animations: {
				self.backgroundImageView.transform = CGAffineTransformRotate(self.backgroundImageView.transform, CGFloat(M_PI_2))
			}) { succeed in
				if succeed {
					UIView.animateWithDuration(duration / 2.0 * self.animationDurationScalar,
						delay: 0.0,
						options: .CurveLinear,
						animations: {
							self.backgroundImageView.transform = CGAffineTransformRotate(self.backgroundImageView.transform, CGFloat(M_PI_2))
					}, completion: nil)
				}
		}
	}

}

enum AnimationType {
	case Scale
	case Fade
}

