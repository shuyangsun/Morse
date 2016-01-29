//
//  BackButton.swift
//  Morse
//
//  Created by Shuyang Sun on 12/4/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class BackButton: UIButton {

	private var _animationOffset:CGFloat {
		return layoutDirection == .LeftToRight ? backButtonAnimationOffset : -backButtonAnimationOffset
	}

	convenience init(origin:CGPoint, width:CGFloat) {
		let frame = CGRect(origin: origin, size: CGSize(width: width, height: width))
		self.init(frame:frame)
		self.opaque = false
		let image = UIImage(named: theme.backButtonImageName)
		self.setImage(image, forState: .Normal)
	}

	func disappearWithDuration(duration:NSTimeInterval, completion:((Void)->Void)? = nil) {
		self.transform = CGAffineTransformIdentity
		UIView.animateWithDuration(duration * appDelegate.animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.transform = CGAffineTransformMakeTranslation(-self._animationOffset, 0)
				self.alpha = 0
			}) { succeed in
				self.hidden = true
				self.userInteractionEnabled = false
				completion?()
		}
		self.setNeedsDisplay()
	}

	func appearWithDuration(duration:NSTimeInterval, completion:((Void)->Void)? = nil) {
		self.hidden = false
		self.transform = CGAffineTransformMakeTranslation(self._animationOffset, 0)
		UIView.animateWithDuration(duration * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: {
				self.transform = CGAffineTransformIdentity
				self.alpha = 1.0
			}) { succeed in
				self.userInteractionEnabled = true
				completion?()
		}
		self.setNeedsDisplay()
	}
}
