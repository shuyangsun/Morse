//
//  CardViewOutputTransitionInteractionController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/19/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class CardViewOutputTransitionInteractionController: UIPercentDrivenInteractiveTransition {
	var transitionInProgress = false
	var transitionStartDate:Date? = nil
	var outputVC:OutputViewController! = nil {
		willSet {
			let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(handleInteractionGR(_:)))
			let panGR = UIPanGestureRecognizer(target: self, action: #selector(handleInteractionGR(_:)))
			
			if newValue.pinchGR == nil {
				newValue.pinchGR = pinchGR
			}
			if newValue.panGR == nil {
				newValue.panGR = panGR
			}
		}
	}

	var tabBarVC:TabBarController! {
		return self.outputVC?.presentingViewController as? TabBarController
	}

	fileprivate var _shouldFinishTransition = false
	fileprivate var _panDistanceToDismiss:CGFloat {
		return self.tabBarVC.view.bounds.height/2.0
	}

	func handleInteractionGR(_ gr:UIGestureRecognizer) {
		if self.outputVC != nil && self.tabBarVC != nil {
			var ratio:CGFloat = 0
			var touchTranslation = CGPoint(x: 0, y: 0)
			if let panGR = gr as? UIPanGestureRecognizer {
				touchTranslation = panGR.translation(in: self.tabBarVC.view)
				ratio = min(1, max(0, touchTranslation.y - slideAndPinchStartDistance)/self._panDistanceToDismiss)
			} else if let pinchGR = gr as? UIPinchGestureRecognizer {
				ratio = max(0, 1 - pinchGR.scale)
			}
			let state = gr.state
			var delayFinishTransitionTime = defaultAnimationDuration/2.0 * animationDurationScalar
			if let startDate = self.transitionStartDate {
				delayFinishTransitionTime -= Date().timeIntervalSince(startDate)
			}
			delayFinishTransitionTime += 0.2
			delayFinishTransitionTime = max(0, delayFinishTransitionTime)
			if state == .began {
				self.transitionStartDate = Date()
				self.tabBarVC.dismiss(animated: true, completion: nil)
				self.transitionInProgress = true
			} else if state == .changed && self.transitionInProgress {
				if (gr is UIPanGestureRecognizer) && touchTranslation.y >= slideAndPinchStartDistance || gr is UIPinchGestureRecognizer {
					self._shouldFinishTransition = ratio >= slideAndPinchRatioToDismiss
					if self.percentComplete != ratio {
						if ratio >= 1 {
							if self._shouldFinishTransition {
								if delayFinishTransitionTime > 0 {
									self.update(1)
									self.finish()
								} else {
									self.finish()
								}
							}
						} else {
							self.update(ratio)
						}
					}
				} else {
					// Commenting out this line because of a bug. cancelInteractiveTransition() not working
//					self._shouldFinishTransition = false
					self._shouldFinishTransition = true
				}
			} else if state == .ended || state == .cancelled && self.transitionInProgress {
//				if !self._shouldFinishTransition
////					|| state == .Cancelled // Commenting out this line because of a bug. cancelInteractiveTransition() not working
//				{
//					// FIX ME: cancel is not working, there is a bug. The work around using now is to set dismissRatio to 0.
//					cancelInteractiveTransition()
//				} else {
//					if delayFinishTransitionTime > 0 {
//						self.updateInteractiveTransition(1)
//						NSTimer.scheduledTimerWithTimeInterval(delayFinishTransitionTime, target: self, selector: "finishInteractiveTransition", userInfo: nil, repeats: false)
//					} else {
//						self.finishInteractiveTransition()
//					}
//				}
				if delayFinishTransitionTime > 0 {
					self.update(1)
					self.finish()
				} else {
					self.finish()
				}
				self.transitionInProgress = false
			}
		}
	}
}

