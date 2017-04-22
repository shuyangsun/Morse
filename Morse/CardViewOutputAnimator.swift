//
//  CardViewOutputAnimator.swift
//  Morse
//
//  Created by Shuyang Sun on 12/19/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class CardViewOutputAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	var reverse = false

	@objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return defaultAnimationDuration * animationDurationScalar
	}

	@objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if transitionContext.isAnimated {
			if !self.reverse {
				// Transitioning to outputVC
				if let containerView = transitionContext.containerView {
					let outputVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! OutputViewController
					let tabBarVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! TabBarController
					let homeVC = tabBarVC.homeVC
					let cardView = tabBarVC.homeVC.currentFlippedCard!
					let cardFrame = homeVC.scrollView.convert(cardView.frame, to: homeVC.view)

					// Animation magic happens here
					// Add a background view first
					let snapshotTabBar = tabBarVC.view.snapshotView(afterScreenUpdates: false)
					snapshotTabBar.frame = tabBarVC.view.frame
					containerView.addSubview(snapshotTabBar)

					// Add a view to fake the back of cardView that's transitioning from
					let backgroundView = UIView(frame: homeVC.scrollView.convert(cardView.frame, to: homeVC.view))
					backgroundView.layer.cornerRadius = theme.cardViewCornerRadius
					backgroundView.backgroundColor = theme.cardBackViewBackgroundColor
					containerView.addSubview(backgroundView)

					// Add fake output and share buttons
					let outputButton = UIButton(frame: cardView.outputButton.frame)
					let outputImage = UIImage(named: theme.outputImageName)!.withRenderingMode(.alwaysTemplate)
					outputButton.setImage(outputImage, for: UIControlState())
					outputButton.backgroundColor = cardView.outputButton.backgroundColor
					outputButton.tintColor = theme.buttonWithAccentBackgroundTintColor
					outputButton.setTitleColor(cardView.outputButton.titleColor(for: UIControlState())!, for: UIControlState())
					outputButton.setTitleColor(cardView.outputButton.titleColor(for: .highlighted), for: .highlighted)
					outputButton.setBackgroundImage(cardView.outputButton.backgroundImage(for: UIControlState()), for: UIControlState())
					outputButton.setBackgroundImage(cardView.outputButton.backgroundImage(for: .highlighted), for: .highlighted)
					outputButton.setTitle(cardView.outputButton.titleLabel?.text, for: UIControlState())
					backgroundView.addSubview(outputButton)

					let shareButton = UIButton(frame: cardView.shareButton.frame)
					let shareImage = UIImage(named: theme.shareImageName)!.withRenderingMode(.alwaysTemplate)
					shareButton.setImage(shareImage, for: UIControlState())
					shareButton.backgroundColor = cardView.shareButton.backgroundColor
					shareButton.tintColor = theme.buttonWithAccentBackgroundTintColor
					shareButton.setTitleColor(cardView.shareButton.titleColor(for: UIControlState())!, for: UIControlState())
					shareButton.setTitleColor(cardView.shareButton.titleColor(for: .highlighted), for: .highlighted)
					shareButton.setBackgroundImage(cardView.shareButton.backgroundImage(for: UIControlState()), for: UIControlState())
					shareButton.setBackgroundImage(cardView.shareButton.backgroundImage(for: .highlighted), for: .highlighted)
					shareButton.setTitle(cardView.shareButton.titleLabel?.text, for: UIControlState())
					backgroundView.addSubview(shareButton)

					// Add outputView
					let scaleX = cardFrame.width/outputVC.view.bounds.width
					let scaleY = cardFrame.height/outputVC.view.bounds.height
					outputVC.view.layer.anchorPoint = CGPoint(x: 0, y: 0)
					outputVC.view.transform = outputVC.view.transform.scaledBy(x: scaleX, y: scaleY)
					outputVC.view.frame = cardFrame
					containerView.insertSubview(outputVC.view, belowSubview: backgroundView)

					UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
						delay: 0,
						options: UIViewAnimationOptions(),
						animations: {
							outputButton.alpha = 0
							shareButton.alpha = 0
							outputVC.view.alpha = 1
							outputVC.view.transform = CGAffineTransform.identity
							outputVC.view.frame = tabBarVC.view.frame
							backgroundView.frame = outputVC.view.frame
							backgroundView.alpha = 0
						}) { succeed in
							snapshotTabBar.removeFromSuperview()
							backgroundView.removeFromSuperview()
							transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
					}
				}
			} else {
				// Transitioning back to homeVC
				if let containerView = transitionContext.containerView {
					let outputVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! OutputViewController
					let tabBarVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! TabBarController
					let homeVC = tabBarVC.homeVC
					let cardView = tabBarVC.homeVC.currentFlippedCard!
					let cardFrame = homeVC.scrollView.convert(cardView.frame, to: homeVC.view)

					// Animation magic happens here

					// Add a snapshot for tabBar view as background
					let snapshotTabBar = tabBarVC.view.snapshotView(afterScreenUpdates: false)
					snapshotTabBar.frame = tabBarVC.view.frame
					containerView.addSubview(snapshotTabBar)

					// A fake back side of card
					let backgroundView = UIView(frame: containerView.frame)
					backgroundView.backgroundColor = theme.cardBackViewBackgroundColor
					backgroundView.layer.cornerRadius = theme.cardViewCornerRadius
					backgroundView.clipsToBounds = true
					containerView.addSubview(backgroundView)

					// Add fake output and share buttons
					let outputButton = UIButton(frame: CGRect(x: outputVC.flashToggleButton.frame.origin.x, y: outputVC.flashToggleButton.frame.origin.y, width: topBarHeight, height: topBarHeight))
					outputButton.backgroundColor = cardView.outputButton.backgroundColor
					outputButton.tintColor = theme.buttonWithAccentBackgroundTintColor
					let outputImage = UIImage(named: theme.outputImageName)?.withRenderingMode(.alwaysTemplate)
					outputButton.setImage(outputImage!, for: UIControlState())
					outputButton.setTitle(cardView.outputButton.titleLabel?.text, for: UIControlState())
					outputButton.alpha = 0
					backgroundView.addSubview(outputButton)

					let shareButton = UIButton(frame: CGRect(x: outputVC.soundToggleButton.frame.origin.x, y: outputVC.soundToggleButton.frame.origin.y, width: topBarHeight, height: topBarHeight))
					shareButton.backgroundColor = cardView.shareButton.backgroundColor
					shareButton.tintColor = theme.buttonWithAccentBackgroundTintColor
					let shareImage = UIImage(named: theme.shareImageName)!.withRenderingMode(.alwaysTemplate)
					shareButton.setImage(shareImage, for: UIControlState())
					shareButton.setTitle(cardView.shareButton.titleLabel?.text, for: UIControlState())
					shareButton.alpha = 0
					backgroundView.addSubview(shareButton)

					// Output view that will shrink back
					let snapshotOutput = outputVC.view.snapshotView(afterScreenUpdates: false)
					snapshotOutput.frame = outputVC.view.frame
					snapshotOutput.layer.cornerRadius = theme.cardViewCornerRadius
					backgroundView.addSubview(snapshotOutput)
					UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
						delay: 0,
						usingSpringWithDamping: 1,
						initialSpringVelocity: 0.5,
						options: .curveEaseIn,
						animations: {
							outputButton.alpha = 1
							outputButton.frame = cardView.outputButton.frame
							shareButton.alpha = 1
							shareButton.frame = cardView.shareButton.frame
							backgroundView.frame = cardFrame
							snapshotOutput.alpha = 0
							snapshotOutput.frame = CGRect(x: 0, y: 0, width: cardFrame.width, height: snapshotOutput.bounds.height)
							tabBarVC.view.alpha = 1
						}) { succeed in
							// FIXME: Not called if interaction time is less than animation time.
							containerView.removeFromSuperview()
							transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
							if !transitionContext.transitionWasCancelled {
								homeVC.restoreCurrentFlippedCard()
							}
					}
				}
			}
		}
	}
}
