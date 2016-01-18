//
//  BackButton.swift
//  Morse
//
//  Created by Shuyang Sun on 12/4/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class BackButton: UIButton {

	private var originalTransform:CGAffineTransform!

	private var theme:Theme {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.theme
	}

	convenience init(origin:CGPoint, width:CGFloat) {
		let frame = CGRect(origin: origin, size: CGSize(width: width, height: width))
		self.init(frame:frame)
		self.opaque = false
		let image = UIImage(named: theme.backButtonImageName)
		self.setImage(image, forState: .Normal)
	}

	func disappearWithDuration(duration:NSTimeInterval, completion:((Void)->Void)? = nil) {
		self.originalTransform = self.transform
		UIView.animateWithDuration(duration * appDelegate.animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.transform = CGAffineTransformScale(self.transform, 0.1, 0.1)
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
		UIView.animateWithDuration(duration * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: {
				self.transform = self.originalTransform
				self.alpha = 1.0
			}) { succeed in
				self.userInteractionEnabled = true
				completion?()
		}
		self.setNeedsDisplay()
	}
}
