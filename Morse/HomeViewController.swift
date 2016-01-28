//
//  HomeViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import CoreData

class HomeViewController: GAITrackedViewController, UITextViewDelegate, UIScrollViewDelegate, CardViewDelegate {

	// *****************************
	// MARK: Views
	// *****************************

	var topSectionViewController:HomeTopSectionViewController!
	var topSectionContainerView: UIView!
	
	var scrollView: UIScrollView!
	var scrollViewOverlay: UIButton!

	private var cardViews:[CardView] = []
	private var currentExpandedCard:CardView?
	var currentFlippedCard:CardView? // Make it internal so the animator can access it

	var scrollViewSnapshotImageView:UIImageView?
	var micInputSectionViewController:AudioWaveFormViewController?
	var micInputSectionContainerView:UIView?

	// *****************************
	// MARK: UI Related Variables
	// *****************************

	private var topSectionHidden = false

	// Do not need tabBarHeight if using iAd
	private var tabBarHeight:CGFloat {
		if let tabBarController = self.tabBarController {
			return tabBarController.tabBar.bounds.height
		} else {
			return 0
		}
	}

	private var topSectionContainerViewHeight:CGFloat {
		return statusBarHeight + topBarHeight + textBackgroundViewHeight
	}

	var isDuringInput:Bool {
		return self.topSectionViewController.inputTextView.isFirstResponder() || self.micInputSectionContainerView != nil
	}

	// Animation related variables
//	let gravityBehavior = UIGravityBehavior()
//	lazy var animator:UIDynamicAnimator = {
//		assert(self.scrollView != nil)
//		return UIDynamicAnimator(referenceView: self.scrollView)
//	}()

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return theme.style == .Dark ? .LightContent : .Default
	}

	private let _updateCardConstraintsQueue = dispatch_queue_create("Update Card View Constraints On Dictonary VC Queue", nil)

	// *****************************
	// MARK: MVC Life Cycle
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()
//		self.canDisplayBannerAds = !appDelegate.adsRemoved // This line has to be at the beginning of view did load
		self.screenName = homeVCName

		// *****************************
		// Configure Top Section Container View
		// *****************************

		if self.topSectionViewController == nil {
			self.topSectionViewController = HomeTopSectionViewController()
			self.addChildViewController(self.topSectionViewController)
			self.topSectionViewController.didMoveToParentViewController(self)
			self.topSectionViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.topSectionContainerViewHeight)
			self.topSectionContainerView = self.topSectionViewController.view
			self.view.addSubview(self.topSectionContainerView)

			self.topSectionContainerView.clipsToBounds = false
			self.topSectionContainerView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.height.equalTo(self.topSectionContainerViewHeight)
			}
			self.topSectionContainerView.addMDShadow(withDepth: 2)
		}

		// *****************************
		// Configure Scroll View
		// *****************************
		
		if self.scrollView == nil {
			self.scrollView = UIScrollView(frame: CGRect(x: 0, y: self.topSectionContainerViewHeight, width: self.view.bounds.width, height: self.view.bounds.height - self.topSectionContainerViewHeight))
			self.scrollView.backgroundColor = appDelegate.theme.scrollViewBackgroundColor
			self.scrollView.userInteractionEnabled = true
			self.scrollView.bounces = true
			self.scrollView.showsHorizontalScrollIndicator = false
			self.scrollView.showsVerticalScrollIndicator = true
			self.scrollView.delegate = self
			self.scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
			self.view.insertSubview(self.scrollView, atIndex: 0)

			self.scrollView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.topSectionContainerView.snp_bottom)
				make.trailing.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
//				if self.canDisplayBannerAds {
//					make.bottom.equalTo(self.view)
//				} else {
//					make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
//				}
			}
		}

		// *****************************
		// Configure Scroll View Overlay
		// *****************************

		if self.scrollViewOverlay == nil {
			self.scrollViewOverlay = UIButton(frame: CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: self.scrollView.bounds.height))
			self.scrollViewOverlay.addTarget(self.topSectionViewController, action: "inputCancelled:", forControlEvents: .TouchUpInside)
			self.scrollViewOverlay.backgroundColor = appDelegate.theme.scrollViewOverlayColor
			self.scrollViewOverlay.opaque = false
			self.scrollViewOverlay.layer.borderColor = UIColor.clearColor().CGColor
			self.scrollViewOverlay.layer.borderWidth = 0
			self.scrollViewOverlay.opaque = false
			self.scrollViewOverlay.alpha = 0
			self.scrollViewOverlay.titleLabel?.text = nil
			self.view.insertSubview(self.scrollViewOverlay, aboveSubview: self.scrollView)

			self.scrollViewOverlay.snp_remakeConstraints(closure: { (make) -> Void in
				make.edges.equalTo(self.scrollView)
			})
		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColorWithAnimation", name: themeDidChangeNotificationName, object: nil)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAdsStatus", name: adsShouldDisplayDidChangeNotificationName, object: nil)

		// Configure scrollView animator
//		self.animator.addBehavior(self.gravityBehavior)
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		// If there's no card view on the screen, fetch from core data or add some if first launch
		if self.cardViews.isEmpty {
			self.fetchCardsAndUpdateCardViews()
			self.addTutorialCards()
		}
		self.updateScrollViewContentSize()
		self.updateMDShadows()
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		self.restoreCurrentFlippedCard()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// *****************************
	// MARK: Scroll View Delegate
	// *****************************

	func scrollViewDidScroll(scrollView: UIScrollView) {
		let hiddingSectionHeight = self.topSectionContainerViewHeight - self.topSectionViewController.keyboardButtonViewHeight - statusBarHeight
		let animationDuration = 0.25 * animationDurationScalar
		if scrollView.contentOffset.y <= 20 && self.topSectionHidden {
			// Show input area
			self.topSectionHidden = false
			self.topSectionContainerView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
			})

			// Update constraints for buttons on text view
			self.topSectionViewController.keyboardButton.snp_remakeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.topSectionViewController.keyboardButtonViewHeight)
				make.bottom.equalTo(self.topSectionViewController.textBackgroundView)
				if self.topSectionViewController.isDirectionEncode {
					make.leading.equalTo(self.topSectionViewController.textBackgroundView)
				} else {
					make.leading.equalTo(self.topSectionViewController.textBackgroundView.snp_centerX)
				}
				make.trailing.equalTo(self.topSectionViewController.textBackgroundView)
			})

			self.topSectionViewController.microphoneButton.snp_remakeConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.topSectionViewController.keyboardButtonViewHeight)
				make.bottom.equalTo(self.topSectionViewController.textBackgroundView)
				make.leading.equalTo(self.topSectionViewController.textBackgroundView)
				make.trailing.equalTo(self.topSectionViewController.textBackgroundView)
			})

			UIView.animateWithDuration(animationDuration
				, delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.topSectionViewController.inputTextView.alpha = 1
					self.topSectionViewController.outputTextView.alpha = 1
					self.topSectionViewController.keyboardButton.alpha = 0
					if self.topSectionViewController.isDirectionEncode {
						self.topSectionViewController.microphoneButton.alpha = 0
					} else if !self.isDuringInput {
						self.topSectionViewController.microphoneButton.alpha = 1
					}
				}) { succeed in
					if !self.isDuringInput {
						self.topSectionViewController.roundButtonView.appearWithAnimationType([.Scale, .Fade], duration: animationDuration)
					}
			}

		} else if scrollView.contentOffset.y >= hiddingSectionHeight && scrollView.contentSize.height > self.view.bounds.height && !self.topSectionHidden {
			// Only hide input view if the content for scroll view is large enough to be displayed on a full size scroll view.
			// Hide input area
			self.topSectionHidden = true

			self.topSectionContainerView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view).offset(-hiddingSectionHeight)
			})

			if !self.isDuringInput {
				self.topSectionViewController.roundButtonView.disappearWithAnimationType([.Scale, .Fade], duration: animationDuration)
			}

			// Update constraints for buttons on text view
			if !self.topSectionViewController.isDirectionEncode {
				self.topSectionViewController.keyboardButton.snp_remakeConstraints(closure: { (make) -> Void in
					make.height.equalTo(self.topSectionViewController.keyboardButtonViewHeight)
					make.bottom.equalTo(self.topSectionViewController.textBackgroundView)
					make.leading.equalTo(self.topSectionViewController.textBackgroundView.snp_centerX)
					make.trailing.equalTo(self.topSectionViewController.textBackgroundView)
				})

				self.topSectionViewController.microphoneButton.snp_remakeConstraints(closure: { (make) -> Void in
					make.height.equalTo(self.topSectionViewController.keyboardButtonViewHeight)
					make.bottom.equalTo(self.topSectionViewController.textBackgroundView)
					make.leading.equalTo(self.topSectionViewController.textBackgroundView)
					make.trailing.equalTo(self.topSectionViewController.textBackgroundView.snp_centerX)
				})
			}
			UIView.animateWithDuration(animationDuration
				, delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.topSectionViewController.inputTextView.alpha = 0
					self.topSectionViewController.outputTextView.alpha = 0
					self.topSectionViewController.keyboardButton.alpha = 1
					if self.topSectionViewController.isDirectionEncode {
						self.topSectionViewController.microphoneButton.alpha = 0
					} else {
						self.topSectionViewController.microphoneButton.alpha = 1
					}
				}) { succeed in
					UIView.animateWithDuration(animationDuration
						, delay: 0,
						options: .CurveEaseOut,
						animations: {
							self.topSectionViewController.keyboardButton.alpha = 1
							if self.topSectionViewController.isDirectionEncode {
								self.topSectionViewController.microphoneButton.alpha = 0
							} else {
								self.topSectionViewController.microphoneButton.alpha = 1
							}
						}, completion: nil)
			}
		}
		self.restoreCurrentFlippedCard()
	}

	// *****************************
	// MARK: Microphone Related
	// *****************************

	func microphoneButtonTapped() {
		if self.scrollViewSnapshotImageView == nil {
			self.scrollViewSnapshotImageView = UIImageView(frame: self.scrollView.frame)
			self.scrollViewSnapshotImageView?.contentMode = .ScaleAspectFill
			self.scrollViewSnapshotImageView?.opaque = false
			self.scrollViewSnapshotImageView?.alpha = 0
			self.view.insertSubview(self.scrollViewSnapshotImageView!, belowSubview: self.scrollViewOverlay)
			self.scrollViewSnapshotImageView?.snp_makeConstraints(closure: { (make) -> Void in
				make.edges.equalTo(self.scrollView)
			})

			self.updateScrollViewBlurImage()
		}

		if self.micInputSectionContainerView == nil {
			self.micInputSectionViewController = AudioWaveFormViewController()
			self.addChildViewController(self.micInputSectionViewController!)
			self.micInputSectionViewController!.transmitter = self.topSectionViewController.transmitter
			self.micInputSectionViewController!.transmitter.delegate = self.topSectionViewController
			self.micInputSectionViewController!.didMoveToParentViewController(self)
			self.micInputSectionViewController!.view.frame = CGRect(origin: CGPointZero, size: self.scrollView.bounds.size)
			self.micInputSectionContainerView = self.micInputSectionViewController!.view
			self.micInputSectionContainerView!.opaque = false
			self.micInputSectionContainerView!.alpha = 0
			let tapGR = UITapGestureRecognizer(target: self.topSectionViewController, action: "audioPlotTapped:")
			self.micInputSectionViewController!.view.addGestureRecognizer(tapGR)
			self.view.insertSubview(self.micInputSectionContainerView!, aboveSubview: self.scrollViewOverlay)

			self.micInputSectionContainerView!.snp_remakeConstraints(closure: { (make) -> Void in
				make.edges.equalTo(self.scrollViewOverlay)
			})
		}
		
		self.topSectionViewController.microphoneButtonTapped()
	}

	// *****************************
	// MARK: Card View Delegate
	// *****************************

	func cardViewTapped(cardView:CardView) {
		let tappingCurrentExpandedView = self.currentExpandedCard === cardView
		if !tappingCurrentExpandedView {
			self.collapseCurrentExpandedCard()
			if cardView !== self.currentFlippedCard {
				cardView.flip()
			}
			self.restoreCurrentFlippedCard() // This line has to be after flipping the current card!
			if cardView.flipped {
				self.currentFlippedCard = cardView
			}
		} else {
			self.collapseCurrentExpandedCard() {
				cardView.flip()
				if cardView.flipped {
					self.currentFlippedCard = cardView
				}
			}
		}
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
			action: "button_press",
			label: "Card View Tapped",
			value: nil).build() as [NSObject : AnyObject])
	}

	func cardViewHeld(cardView: CardView) {
		// Expand card view.
		let heldCurrentExpandedView = self.currentExpandedCard === cardView
		self.collapseCurrentExpandedCard()
		self.restoreCurrentFlippedCard()
		if !heldCurrentExpandedView {
			if cardView.canBeExpanded {
				cardView.expanded = true
				self.currentExpandedCard = cardView
				self.updateConstraintsForCardView(cardView)
				// Change cardView background color animation.
				UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
					delay: 0,
					options: .CurveEaseOut,
					animations: {
						self.scrollView.layoutIfNeeded()
						cardView.backgroundColor = appDelegate.theme.cardViewExpandedBackgroudColor
						cardView.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
				}, completion: nil)
			}
		}

		let tracker = GAI.sharedInstance().defaultTracker
		tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
			action: "hold_gesture_used",
			label: "Card Held",
			value: nil).build() as [NSObject : AnyObject])
	}

	// What happens when the user taps share button
	func cardViewShareButtonTapped(cardView:CardView) {
		if let morse = cardView.morse {
			var shareStr = morse
			if appDelegate.addExtraTextWhenShare {
				shareStr += "\n" + LocalizedStrings.General.sharePromote + " " + appStoreLink
			}
			let activityVC = UIActivityViewController(activityItems: [shareStr], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = cardView.shareButton
			self.presentViewController(activityVC, animated: true, completion: nil)
		}

		let tracker = GAI.sharedInstance().defaultTracker
		tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
			action: "button_press",
			label: "Shared Button Tapped",
			value: nil).build() as [NSObject : AnyObject])
	}

	// What happens when the user taps output button
	func cardViewOutputButtonTapped(cardView:CardView) {
		let outputVC = OutputViewController()
		if let morse = cardView.morse {
			outputVC.morse = morse
		}
		outputVC.transitioningDelegate = self.parentViewController as! TabBarController
		outputVC.modalPresentationStyle = .Custom
		(self.tabBarController as! TabBarController).cardViewOutputTransitionInteractionController.outputVC = outputVC
		self.presentViewController(outputVC, animated: true, completion: nil)

		let tracker = GAI.sharedInstance().defaultTracker
		tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
			action: "button_press",
			label: "Singal Output Tapped",
			value: nil).build() as [NSObject : AnyObject])
	}

	func cardViewTouchesBegan(cardView: CardView, touches: Set<UITouch>, withEvent event: UIEvent?) {
		let ind = self.cardViews.indexOf(cardView)!
		if ind < self.cardViews.count - 1 {
			self.scrollView.insertSubview(cardView, atIndex: 0)
		}
	}

	func cardViewTouchesEnded(cardView: CardView, touches: Set<UITouch>, withEvent event: UIEvent?, deleteCard:Bool) {
		self.scrollView.scrollEnabled = true
		let ind = self.cardViews.indexOf(cardView)!
		if deleteCard {
			let tracker = GAI.sharedInstance().defaultTracker
			tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "swipe_gesture_used",
				label: "Card Deleted",
				value: nil).build() as [NSObject : AnyObject])
			// Remove in UI
			cardView.removeFromSuperview()
			self.cardViews.removeAtIndex(ind)
			if ind > 0 {
				// If there is one card below the deleting card, update it's constraint.
				self.updateConstraintsForCardView(self.cardViews[ind - 1])
			}
			if ind < self.cardViews.count {
				// If there is one card above the deleting card, update it's constraint. Using "ind" instead of "ind - 1" because this card is already removed, from array.
				self.updateConstraintsForCardView(self.cardViews[ind])
			}
			if self.currentExpandedCard === cardView {
				self.currentExpandedCard = nil
			}

			// Animations
//			self.gravityBehavior.addItem(cardView)
			UIView.animateWithDuration(TAP_FEED_BACK_DURATION / 2.0,
				delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.scrollView.layoutIfNeeded()
				}) { succeed in
					// Update scrollView contentSize
					self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height - cardView.bounds.height - theme.cardViewGap)

					// If the content size of scroll view is smaller than scroll view frame, show top section
					if self.scrollView.contentSize.height < self.scrollView.bounds.height {
						self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
					}
			}

			// Remove in Core Data
			let managedContext = appDelegate.managedObjectContext
			let fetchRequest = NSFetchRequest(entityName: "Card")
			let filter = NSPredicate(format: "cardUniqueID == \(cardView.cardUniqueID!)")
			fetchRequest.predicate = filter
			do {
				let results = try managedContext.executeFetchRequest(fetchRequest)
				let cards = results as! [NSManagedObject]
				print(cards.count)
				assert(cards.count == 1) // There should only be one card with this unique ID
				for card in cards {
					managedContext.deleteObject(card)
				}
				try managedContext.save()
			} catch let error as NSError {
				print("Could not fetch card to delete from Core Data \(error), \(error.userInfo)")
			} catch {

			}
		} else {
			// If the card won't be deleted
			// If there is a card above it:
			if ind < self.cardViews.count - 1 {
				let cardAbove:CardView = self.cardViews[ind + 1]
				self.scrollView.insertSubview(cardView, aboveSubview: cardAbove)
			}
		}
	}

	func deleteAllCards() {
		for cardView in self.cardViews {
			cardView.removeFromSuperview()
			// Remove in Core Data
			let managedContext = appDelegate.managedObjectContext
			let fetchRequest = NSFetchRequest(entityName: "Card")
			let filter = NSPredicate(format: "cardUniqueID == \(cardView.cardUniqueID!)")
			fetchRequest.predicate = filter
			do {
				let results = try managedContext.executeFetchRequest(fetchRequest)
				let cards = results as! [NSManagedObject]
				print(cards.count)
				assert(cards.count == 1) // There should only be one card with this unique ID
				for card in cards {
					managedContext.deleteObject(card)
				}
				try managedContext.save()
			} catch let error as NSError {
				print("Could not fetch card to delete from Core Data \(error), \(error.userInfo)")
			} catch {

			}
		}
		self.currentExpandedCard = nil
		self.currentFlippedCard = nil
		self.cardViews = []
		self.updateScrollViewContentSize()
		self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
	}

	func cardViewTouchesCancelled(cardView: CardView, touches: Set<UITouch>?, withEvent event: UIEvent?) {
		self.scrollView.scrollEnabled = true
		let ind = self.cardViews.indexOf(cardView)!
		// If there is a card above it:
		if ind < self.cardViews.count - 1 {
			let cardAbove:CardView = self.cardViews[ind + 1]
			self.scrollView.insertSubview(cardView, aboveSubview: cardAbove)
		}
	}

	// *****************************
	// MARK: Card View Manipulation
	// *****************************

	func addCardViewWithText(var text:String, var morse:String, textOnTop:Bool = true, deletable:Bool = true, animateWithDuration duration:NSTimeInterval = 0.0) {
		text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		morse = morse.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		let cardView = CardView(frame: CGRect(x: theme.cardViewHorizontalMargin, y: theme.cardViewGroupVerticalMargin, width: self.scrollView.bounds.width - theme.cardViewHorizontalMargin - theme.cardViewHorizontalMargin, height: theme.cardViewHeight), text: text, morse: morse, textOnTop: textOnTop)
		cardView.delegate = self
		cardView.cardUniqueID = NSProcessInfo.processInfo().globallyUniqueString.hashValue // Generate a UUID for the card

		cardView.opaque = false
		cardView.alpha = 0.0

		if self.cardViews.isEmpty {
			self.scrollView.addSubview(cardView)
		} else {
			self.scrollView.insertSubview(cardView, belowSubview: self.cardViews.last!)
		}
		self.cardViews.append(cardView)
		self.updateConstraintsForCardView(cardView)
		if self.cardViews.count > 1 {
			self.updateConstraintsForCardView(self.cardViews[self.cardViews.count - 2])
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + theme.cardViewHeight + theme.cardViewGap)
		self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
		if duration > 0 {
			UIView.animateWithDuration(duration / 3.0,
				delay: 0.0,
				options: .CurveEaseInOut,
				animations: { () -> Void in
					self.scrollView.layoutIfNeeded()
				}) { succeed in
					UIView.animateWithDuration(duration * 2.0 / 3.0 * appDelegate.animationDurationScalar,
						delay: 0.0,
						options: .CurveEaseInOut,
						animations: { () -> Void in
							cardView.alpha = 1.0
						}) { succeed in
							cardView.opaque = true
							self.saveCard(text, morse: morse, index: self.cardViews.count - 1, textOnTop: self.topSectionViewController.isDirectionEncode, favorite: false, deletable: true, cardUniqueID: cardView.cardUniqueID!)
					}
			}
		} else {
			self.scrollView.layoutIfNeeded()
			cardView.alpha = 1.0
			cardView.opaque = true
			self.saveCard(text, morse: morse, index: self.cardViews.count - 1, textOnTop: self.topSectionViewController.isDirectionEncode, favorite: false, deletable: true, cardUniqueID: cardView.cardUniqueID!)
		}
	}

	// This method update the constraint for a cardView, and returns it's height when done.
	private func updateConstraintsForCardView(cardView:CardView, indexInCardViewsArray index:Int? = nil) {
		let ind = index == nil ? self.cardViews.indexOf(cardView)! : index!
		var heightChange:CGFloat = 0
		cardView.snp_remakeConstraints(closure: { (make) -> Void in
			make.left.equalTo(self.scrollView.snp_left).offset(theme.cardViewHorizontalMargin)
			make.width.equalTo(self.scrollView).offset(-(theme.cardViewHorizontalMargin + theme.cardViewHorizontalMargin))
		})
		if ind == self.cardViews.count - 1 {
			cardView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.scrollView).offset(theme.cardViewGroupVerticalMargin)
			})
		} else {
			cardView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.cardViews[ind + 1].snp_bottom).offset(theme.cardViewGap)
			})
		}

		let originalCardViewHeight = cardView.bounds.height
		var resultHeight:CGFloat = 0
		// Update view height depends on if it's expanded.
		if cardView.expanded {
			cardView.topLabel.lineBreakMode = .ByWordWrapping
			cardView.topLabel.numberOfLines = 0
			cardView.bottomLabel.lineBreakMode = .ByWordWrapping
			cardView.bottomLabel.numberOfLines = 0

			// Calculate the new height for top and bottom label.
			// FIX ME: using "+ (theme.cardViewHeight - cardView.paddingTop - cardView.labelVerticalGap - cardView.paddingBottom)/2.0" because of a bug in this calculation.
			let labelWidth = cardView.topLabel.frame.width
			let topLabelHeight = cardView.topLabel.attributedText!.boundingRectWithSize(CGSizeMake(labelWidth, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
				+ (theme.cardViewHeight - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0
			let bottomLabelHeight = cardView.bottomLabel.attributedText!.boundingRectWithSize(CGSizeMake(labelWidth, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
			resultHeight = cardViewLabelPaddingVerticle * 2 + topLabelHeight + cardViewLabelVerticalGap + bottomLabelHeight

			cardView.topLabel.snp_updateConstraints(closure: { (make) -> Void in
				make.height.equalTo(topLabelHeight)
			})

			cardView.snp_updateConstraints { (make) -> Void in
				make.height.equalTo(resultHeight)
			}
		} else { // FIX ME: Constraints BUG
			cardView.topLabel.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(cardView).offset(cardViewLabelPaddingVerticle)
				make.trailing.equalTo(cardView).offset(-cardViewLabelPaddingHorizontal)
				make.leading.equalTo(cardView).offset(cardViewLabelPaddingHorizontal)
				make.height.equalTo((theme.cardViewHeight - cardViewLabelPaddingVerticle * 2 - cardViewLabelVerticalGap)/2.0)
			}
			cardView.snp_updateConstraints(closure: { (make) -> Void in
				make.height.equalTo(theme.cardViewHeight)
			})

			resultHeight = theme.cardViewHeight
		}
		heightChange = resultHeight - originalCardViewHeight
		cardView.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.scrollView.contentSize.height + heightChange)
	}

	private func updateCardViewsConstraints() {
		for i in 0..<self.cardViews.count {
			self.updateConstraintsForCardView(self.cardViews[i], indexInCardViewsArray: i)
		}

		var contentHeight:CGFloat = 0
		if !self.cardViews.isEmpty {
			let count = self.cardViews.count
			contentHeight = theme.cardViewGroupVerticalMargin + theme.cardViewGroupVerticalMargin + CGFloat(count) * theme.cardViewHeight + CGFloat(count - 1) * theme.cardViewGap
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
	}

	// *****************************
	// MARK: Core Data
	// *****************************

	// This method is called after creating a new card on the scrollView, to save it's data into CoreData.
	private func saveCard(var text: String, var morse:String, index:Int, textOnTop:Bool = true, favorite:Bool = false, deletable:Bool = true, cardUniqueID:Int) {
		text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		morse = morse.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		let managedContext = appDelegate.managedObjectContext
		let entity = NSEntityDescription.entityForName("Card", inManagedObjectContext:managedContext)
		let card = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
		let date = NSDate()
		card.setValue(text, forKey: "text")
		card.setValue(morse, forKey: "morse")
		card.setValue(index, forKey: "index")
		card.setValue(textOnTop, forKey: "textOnTop")
		card.setValue(favorite, forKey: "favorite")
		card.setValue(deletable, forKey: "deletable")
		card.setValue(date, forKey: "dateCreated")
		card.setValue(cardUniqueID, forKey: "cardUniqueID")
		card.setValue("Text Morse", forKey: "transmitterType")
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Could not save \(error), \(error.userInfo)")
		} catch {

		}
	}

	// Fetch existing cards from core data, and add them onto the scroll view, then layout them.
	private func fetchCardsAndUpdateCardViews() {
		// If there is no card on the board, fetch some cards
		if self.cardViews.isEmpty {
			let managedContext = appDelegate.managedObjectContext

			let fetchRequest = NSFetchRequest(entityName: "Card")
			let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
			fetchRequest.sortDescriptors = [sortDescriptor]

			var cards:[NSManagedObject] = []
			dispatch_sync(dispatch_queue_create("Fetch Card Views On Home VC Queue", nil)) {
				let results = try! managedContext.executeFetchRequest(fetchRequest)
				cards = results as! [NSManagedObject]
			}

			for card in cards {
				let cardView = CardView(frame: CGRect(x: theme.cardViewHorizontalMargin, y: theme.cardViewGroupVerticalMargin, width: self.scrollView.bounds.width - theme.cardViewHorizontalMargin - theme.cardViewHorizontalMargin, height: theme.cardViewHeight), text: card.valueForKey("text") as? String, morse: card.valueForKey("morse") as? String, textOnTop: card.valueForKey("textOnTop") as! Bool)
				cardView.delegate = self
				cardView.cardUniqueID = card.valueForKey("cardUniqueID") as? Int
				self.cardViews.append(cardView)
				self.scrollView.insertSubview(cardView, atIndex: 0)
			}
			self.updateCardViewsConstraints()
			self.scrollView.setNeedsUpdateConstraints()
			self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
		}
	}

	// This function is called by top section VC too, so keep it public.
	func collapseCurrentExpandedCard(completion: ((Void)->Void)? = nil) {
		// Collapse expanded card
		let card = self.currentExpandedCard
		self.currentExpandedCard = nil
		if card != nil {
			card!.expanded = false
			self.updateConstraintsForCardView(card!)
			UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
				delay: 0,
				options: .CurveEaseOut,
				animations: {
					card!.backgroundColor = appDelegate.theme.cardViewBackgroudColor
					card!.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
					self.scrollView.layoutIfNeeded()
				}) { succeed in
					card!.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
					completion?()
			}
		}
	}

	func restoreCurrentFlippedCard() {
		// Flip back flipped card
		if self.currentFlippedCard != nil && self.currentFlippedCard!.flipped {
			self.currentFlippedCard?.flip()
		}
		self.currentFlippedCard = nil
	}

	// On the first launch of the game, there are tutorial cards on the home screen, this function adds them.
	func addTutorialCards(checkFirstLaunch:Bool = true) {
		if checkFirstLaunch && !appDelegate.notFirstLaunch && self.cardViews.isEmpty || !checkFirstLaunch {
			let localizedTextArrays = [
				(localized:LocalizedStrings.LaunchCard.text1, english: "Welcome to Morse Transmitter!"),
				(localized:LocalizedStrings.LaunchCard.text2, english: "Tap me to output or share."),
				(localized:LocalizedStrings.LaunchCard.text3, english: "Hold me to expand."),
				(localized:LocalizedStrings.LaunchCard.text4, english: "Swipe to delete me.")
			]
			let transmitter = MorseTransmitter()
			for var i = localizedTextArrays.count - 1; i >= 0; i-- {
				var text = localizedTextArrays[i].localized
				// If morse is empty after trimming punchtuations, add english.
				transmitter.text = text.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
				var morse = transmitter.morse
				if morse == nil || morse!.isEmpty {
					text += "\n\(localizedTextArrays[i].english)"
				}
				transmitter.text = text
				morse = transmitter.morse
				self.addCardViewWithText(text, morse: morse!)
			}
			appDelegate.userDefaults.setValue(true, forKey: userDefaultsKeyNotFirstLaunch)
		}
	}

	func rotationDidChange() {
		if self.currentExpandedCard != nil {
			self.updateConstraintsForCardView(self.currentExpandedCard!)
		}
		for i in 0..<self.cardViews.count {
			cardViews[i].updateExpandButton()
			self.cardViews[i].snp_updateConstraints(closure: { (make) -> Void in
				make.width.equalTo(self.scrollView).offset(-(theme.cardViewHorizontalMargin + theme.cardViewHorizontalMargin))
			})
		}
		self.scrollView.setNeedsUpdateConstraints()
		for card in self.cardViews {
			card.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
		}

		self.updateScrollViewContentSize()
		self.updateMDShadows()
		self.updateScrollViewBlurImage()
	}

	func updateScrollViewContentSize() {
		let count = self.cardViews.count
		var contentHeight = theme.cardViewGroupVerticalMargin + theme.cardViewGroupVerticalMargin + CGFloat(count - 1) * theme.cardViewGap + CGFloat(count - 1) * theme.cardViewHeight
		if count == 0 {
			contentHeight = 0
		} else {
			if self.currentExpandedCard != nil {
				contentHeight += self.currentExpandedCard!.bounds.height
			} else {
				contentHeight += theme.cardViewHeight
			}
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
	}

	private func updateMDShadows() {
		if self.isDuringInput {
			self.topSectionContainerView.addMDShadow(withDepth: 3)
		} else {
			self.topSectionContainerView.addMDShadow(withDepth: 2)
		}

		for card in self.cardViews {
			card.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
		}
	}

	func updateScrollViewBlurImage(afterScreenUpdates:Bool = false) {
		let image = self.snapshot(self.scrollView, afterScreenUpdates: afterScreenUpdates)
		let blurredImage = UIImageEffects.imageByApplyingBlurToImage(image, withRadius: theme.scrollViewBlurRadius, tintColor: theme.scrollViewBlurTintColor, saturationDeltaFactor: 0, maskImage: nil)
		self.scrollViewSnapshotImageView?.image = blurredImage
	}

	private func snapshot(view:UIView, afterScreenUpdates:Bool = false) -> UIImage {
		UIGraphicsBeginImageContext(view.bounds.size)
		view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: afterScreenUpdates)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}

	func updateColor(animated animated:Bool = true) {
		dispatch_sync(self._updateCardConstraintsQueue) {
			self.updateCardViewsConstraints()
		}
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animateWithDuration(duration,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.scrollView.backgroundColor = theme.scrollViewBackgroundColor
				if self.micInputSectionContainerView != nil {
					self.micInputSectionViewController?.view.backgroundColor = theme.audioPlotBackgroundColor
					self.micInputSectionViewController?.audioPlot.color = theme.audioPlotColor
					self.micInputSectionViewController?.audioPlotPitchFiltered.color = theme.audioPlotPitchFilteredColor
					self.micInputSectionViewController?.wpmLabel.textColor = theme.waveformVCLabelTextColorEmphasized
					self.micInputSectionViewController?.pitchLabel.textColor = theme.waveformVCLabelTextColorEmphasized
					self.micInputSectionViewController?.tutorial1Label.textColor = theme.waveformVCLabelTextColorNormal
					self.micInputSectionViewController?.tapToFinishLabel.textColor = theme.waveformVCLabelTextColorNormal
				}
				for cardView in self.cardViews {
					cardView.layer.cornerRadius = theme.cardViewCornerRadius
					cardView.layer.borderWidth = theme.cardViewBorderWidth
					cardView.layer.borderColor = theme.cardViewBorderColor.CGColor
					cardView.expandButton.tintColor = theme.cardViewExpandButtonColor
					cardView.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
					if cardView.flipped {
						cardView.backView.backgroundColor = theme.cardBackViewBackgroundColor
						cardView.outputButton.tintColor = theme.buttonWithAccentBackgroundTintColor
						cardView.shareButton.tintColor = theme.buttonWithAccentBackgroundTintColor
					}
					if cardView.isProsignEmergencyCard {
						cardView.backgroundColor = theme.cardViewProsignEmergencyBackgroundColor
					} else if cardView.isProsignCard {
						cardView.backgroundColor = theme.cardViewProsignBackgroudColor
					} else {
						if cardView.expanded {
							cardView.backgroundColor = appDelegate.theme.cardViewExpandedBackgroudColor
						} else {
							cardView.backgroundColor = appDelegate.theme.cardViewBackgroudColor
						}
					}
					cardView.addMDShadow(withDepth: appDelegate.theme.cardViewMDShadowLevelDefault)
					if cardView.textOnTop {
						if cardView.isProsignEmergencyCard {
							cardView.topLabel.textColor = theme.cardViewProsignEmergencyTextColor
							cardView.bottomLabel.textColor = theme.cardViewProsignEmergencyMorseColor
						} else if cardView.isProsignCard {
							cardView.topLabel.textColor = theme.cardViewProsignTextColor
							cardView.bottomLabel.textColor = theme.cardViewProsignMorseColor
						} else {
							cardView.topLabel.textColor = theme.cardViewTextColor
							cardView.bottomLabel.textColor = theme.cardViewMorseColor
						}
					} else {
						if cardView.isProsignEmergencyCard {
							cardView.topLabel.textColor = theme.cardViewProsignEmergencyMorseColor
							cardView.bottomLabel.textColor = theme.cardViewProsignEmergencyTextColor
						} else if cardView.isProsignCard {
							cardView.topLabel.textColor = theme.cardViewProsignMorseColor
							cardView.bottomLabel.textColor = theme.cardViewProsignTextColor
						} else {
							cardView.topLabel.textColor = theme.cardViewMorseColor
							cardView.bottomLabel.textColor = theme.cardViewTextColor
						}
					}
				}
				self.view.layoutIfNeeded()
			}, completion: nil)
	}

	// This method is for using selector
	func updateColorWithAnimation() {
		self.updateColor(animated: true)
	}

	// This method is for using selector
	func updateColorWithoutAnimation() {
		self.updateColor()
	}

//	func updateAdsStatus() {
//		self.canDisplayBannerAds = !appDelegate.adsRemoved
//		self.scrollView.snp_remakeConstraints { (make) -> Void in
//			make.top.equalTo(self.topSectionContainerView.snp_bottom)
//			make.trailing.equalTo(self.view)
//			make.leading.equalTo(self.view)
//			if self.canDisplayBannerAds {
//				make.bottom.equalTo(self.view)
//			} else {
//				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
//			}
//		}
//	}
}
