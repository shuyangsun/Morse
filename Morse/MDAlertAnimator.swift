//
//  MDAlertAnimator.swift
//  Morse
//
//  Created by Shuyang Sun on 1/14/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class MDAlertAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	var reverse = false

	@objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return defaultAnimationDuration * animationDurationScalar
	}

	@objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		if transitionContext.isAnimated() {
			if !self.reverse {
				// Transitioning to MDAlertController
				if let containerView = transitionContext.containerView() {
					let alertVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! MDAlertController
					let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!

					// Animation magic happens here
					// Add a background view first
					let snapshotFromVC = fromVC.view.snapshotViewAfterScreenUpdates(false)
					alertVC.snapshot = snapshotFromVC
					snapshotFromVC.frame = fromVC.view.frame

					alertVC.backgroundView.alpha = 0
					alertVC.alertView.alpha = 0
					alertVC.alertView.transform = CGAffineTransformMakeScale(2, 2)

					containerView.addSubview(alertVC.view)
					UIView.animateWithDuration(self.transitionDuration(transitionContext),
						delay: 0,
						usingSpringWithDamping: 0.5,
						initialSpringVelocity: 0.5,
						options: .CurveEaseInOut,
						animations: {
							alertVC.backgroundView.alpha = 1
							alertVC.alertView.alpha = 1
							alertVC.alertView.transform = CGAffineTransformIdentity
						}) { succeed in
							alertVC.snapshot?.removeFromSuperview()
							alertVC.snapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
							alertVC.snapshot?.frame = fromVC.view.frame
							alertVC.view.insertSubview(alertVC.snapshot!, atIndex: 0)
							transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
					}
				}
			} else {
				// Transitioning back to homeVC
				if let containerView = transitionContext.containerView() {
					let alertVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! MDAlertController
					containerView.addSubview(alertVC.view)

					UIView.animateWithDuration(self.transitionDuration(transitionContext),
						delay: 0,
						usingSpringWithDamping: 1,
						initialSpringVelocity: 0.5,
						options: .CurveEaseIn,
						animations: {
							alertVC.alertView.transform = CGAffineTransformMakeScale(0.1, 0.1)
							containerView.alpha = 0
						}) { succeed in
							// FIXME: Not called if interaction time is less than animation time.
							containerView.removeFromSuperview()
							transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
					}
				}
			}
		}
	}
}
