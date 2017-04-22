//
//  BackButton.swift
//  Morse
//
//  Created by Shuyang Sun on 12/4/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class BackButton: UIButton {

	fileprivate var _animationOffset:CGFloat {
		return layoutDirection == .leftToRight ? backButtonAnimationOffset : -backButtonAnimationOffset
	}

	convenience init(origin:CGPoint, width:CGFloat) {
		let frame = CGRect(origin: origin, size: CGSize(width: width, height: width))
		self.init(frame:frame)
		self.isOpaque = false
		let image = UIImage(named: theme.backButtonImageName)
		self.setImage(image, for: UIControlState())
	}

	func disappearWithDuration(_ duration:TimeInterval, completion:((Void)->Void)? = nil) {
		self.transform = CGAffineTransform.identity
		UIView.animate(withDuration: duration * appDelegate.animationDurationScalar,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				self.transform = CGAffineTransform(translationX: -self._animationOffset, y: 0)
				self.alpha = 0
			}) { succeed in
				self.isHidden = true
				self.isUserInteractionEnabled = false
				completion?()
		}
		self.setNeedsDisplay()
	}

	func appearWithDuration(_ duration:TimeInterval, completion:((Void)->Void)? = nil) {
		self.isHidden = false
		self.transform = CGAffineTransform(translationX: self._animationOffset, y: 0)
		UIView.animate(withDuration: duration * appDelegate.animationDurationScalar,
			delay: 0.0,
			options: UIViewAnimationOptions(),
			animations: {
				self.transform = CGAffineTransform.identity
				self.alpha = 1.0
			}) { succeed in
				self.isUserInteractionEnabled = true
				completion?()
		}
		self.setNeedsDisplay()
	}
}
