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

	@objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return defaultAnimationDuration * animationDurationScalar
	}

	@objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if transitionContext.isAnimated {
			if !self.reverse {
				// Transitioning to MDAlertController
				let containerView = transitionContext.containerView
                let alertVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! MDAlertController
                let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!

                // Animation magic happens here
                // Add a background view first
                let snapshotFromVC = fromVC.view.snapshotView(afterScreenUpdates: false)
                alertVC.snapshot = snapshotFromVC
                snapshotFromVC?.frame = fromVC.view.frame

                alertVC.backgroundView.alpha = 0
                alertVC.alertView.alpha = 0
                alertVC.alertView.transform = CGAffineTransform(scaleX: 2, y: 2)

                containerView.addSubview(alertVC.view)
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.5,
                    options: UIViewAnimationOptions(),
                    animations: {
                        alertVC.backgroundView.alpha = 1
                        alertVC.alertView.alpha = 1
                        alertVC.alertView.transform = CGAffineTransform.identity
                    }) { succeed in
                        alertVC.snapshot?.removeFromSuperview()
                        alertVC.snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
                        alertVC.snapshot?.frame = fromVC.view.frame
                        alertVC.view.insertSubview(alertVC.snapshot!, at: 0)
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
			} else {
				// Transitioning back to homeVC
				let containerView = transitionContext.containerView
                let alertVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! MDAlertController
                containerView.addSubview(alertVC.view)

                UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0.5,
                    options: .curveEaseIn,
                    animations: {
                        alertVC.alertView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        containerView.alpha = 0
                    }) { succeed in
                        // FIXME: Not called if interaction time is less than animation time.
                        containerView.removeFromSuperview()
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
			}
		}
	}
}
