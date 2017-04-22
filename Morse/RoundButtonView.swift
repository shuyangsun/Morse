//
//  RoundButtonView.swift
//  Morse
//
//  Created by Shuyang Sun on 12/1/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

enum ButtonActionType {
	case `switch`
}

class RoundButtonView: UIView {
	var buttonAction:ButtonActionType = .switch
	var backgroundImageView:UIImageView!

	fileprivate var animationDurationScalar:Double {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		return delegate.animationDurationScalar
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	convenience init(origin:CGPoint, radius:CGFloat) {
		self.init(frame:CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2)))
		let backgroundImage = UIImage(named: "Round Button")!.withRenderingMode(.alwaysTemplate)
		self.backgroundImageView = UIImageView(frame: self.bounds)
		self.backgroundImageView.image = backgroundImage
		self.backgroundImageView.tintColor = theme.buttonWithAccentBackgroundTintColor

		self.addSubview(self.backgroundImageView)
		self.isOpaque = false
		self.backgroundColor = appDelegate.theme.roundButtonBackgroundColor
		self.layer.cornerRadius = radius
		self.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}

	func disappearWithAnimationType(_ animationTypes:Set<AnimationType>, duration:TimeInterval, completion:((Void)->Void)? = nil) {
		// Define animation here according to animation types, call it later
		let animationClosure = {
			if animationTypes.contains(.scale) {
				self.transform = self.transform.scaledBy(x: 0.01, y: 0.01)
			}
			if animationTypes.contains(.fade) {
				self.alpha = 0.0
			}
			self.addMDShadow(withDepth: 0)
		}
		UIView.animate(withDuration: duration * self.animationDurationScalar,
			delay: 0.0,
			options: UIViewAnimationOptions(),
			animations: animationClosure) { succeed in
				self.isHidden = true
				self.isUserInteractionEnabled = false
				completion?()
		}
	}

	func appearWithAnimationType(_ animationTypes:Set<AnimationType>, duration:TimeInterval) {
		// Unhide view first.
		self.isHidden = false
		// Define animation here according to animation types, call it later
		let animationClosure = {
			if animationTypes.contains(.scale) {
				self.transform = CGAffineTransform.identity
			}
			if animationTypes.contains(.fade) {
				self.alpha = 1
				self.isUserInteractionEnabled = true
			}
			self.addMDShadow(withDepth: theme.roundButtonMDShadowLevelDefault)
		}
		UIView.animate(withDuration: duration * self.animationDurationScalar,
			delay: 0.0,
			options: UIViewAnimationOptions(),
			animations: animationClosure, completion: nil)
	}

	func rotateBackgroundImageWithDuration(_ duration:TimeInterval) {
		UIView.animate(withDuration: duration / 2.0 * self.animationDurationScalar,
			delay: 0.0,
			options: .curveLinear,
			animations: {
				self.backgroundImageView.transform = self.backgroundImageView.transform.rotated(by: CGFloat(M_PI_2))
			}) { succeed in
				UIView.animate(withDuration: duration / 2.0 * self.animationDurationScalar,
					delay: 0.0,
					options: .curveLinear,
					animations: {
						self.backgroundImageView.transform = self.backgroundImageView.transform.rotated(by: CGFloat(M_PI_2))
				}, completion: nil)
		}
	}

}

enum AnimationType {
	case scale
	case fade
}

