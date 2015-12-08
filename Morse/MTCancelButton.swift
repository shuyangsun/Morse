//
//  MTCancelButton.swift
//  Morse
//
//  Created by Shuyang Sun on 12/4/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MTCancelButton: UIButton {

	private var originalTransform:CGAffineTransform!

	private var theme:Theme {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.theme
	}

	private var animationDurationScalar:Double {
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		return delegate.animationDurationScalar
	}

	convenience init(origin:CGPoint, width:CGFloat) {
		let frame = CGRect(origin: origin, size: CGSize(width: width, height: width))
		self.init(frame:frame)
		self.opaque = false
		self.layer.cornerRadius = 5
		self.backgroundColor = UIColor.clearColor()
	}

    override func drawRect(rect: CGRect) {
		let frame = self.frame
		let path = UIBezierPath()
		self.theme.cancelButtonColor.setStroke()
		path.lineWidth = 3.0
		path.moveToPoint(CGPoint(x: frame.width/3.0, y: frame.width/3.0))
		path.addLineToPoint(CGPoint(x: frame.width * (1.0 - 1.0/3.0), y: frame.height * (1.0 - 1.0/3.0)))
		path.moveToPoint(CGPoint(x: frame.width * (1.0 - 1.0/3.0), y: frame.height/3.0))
		path.addLineToPoint(CGPoint(x: frame.width/3.0, y: frame.height * (1.0 - 1.0/3.0)))
		path.stroke()
		path.closePath()
    }

	func disappearWithDuration(duration:NSTimeInterval) {
		self.originalTransform = self.transform
		UIView.animateWithDuration(duration * self.animationDurationScalar,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.transform = CGAffineTransformScale(self.transform, 0, 0)
				self.alpha = 0
			}) { succeed in
				if succeed {
					self.hidden = true
					self.userInteractionEnabled = false
				}
		}
		self.setNeedsDisplay()
	}

	func appearWithDuration(duration:NSTimeInterval) {
		self.hidden = false
		UIView.animateWithDuration(duration * self.animationDurationScalar,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: {
				self.transform = self.originalTransform
				self.alpha = 1.0
			}) { succeed in
				if succeed {
					self.userInteractionEnabled = true
				}
		}
		self.setNeedsDisplay()
	}
}
