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

class HomeViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, CardViewDelegate {

	// *****************************
	// MARK: Views
	// *****************************

	var topSectionViewController:HomeTopSectionViewController!
	var topSectionContainerView: UIView!
	
	var scrollView: UIScrollView!
	var scrollViewOverlay: UIButton!

	private var cardViews:[CardView] = []
	private var currentExpandedCard:CardView?
	private var currentFlippedCard:CardView?

	// *****************************
	// MARK: Private variables
	// *****************************

	private var topSectionHidden = false

	// *****************************
	// MARK: UI Related Variables
	// *****************************

	private var tabBarHeight:CGFloat {
		if let tabBarController = self.tabBarController {
			return tabBarController.tabBar.bounds.height
		} else {
			return 0
		}
	}

	private var topSectionContainerViewHeight:CGFloat {
		return statusBarHeight + topBarHeight + self.topSectionViewController.textBackgroundViewHeight
	}

	// Animation related variables
//	let gravityBehavior = UIGravityBehavior()
//	lazy var animator:UIDynamicAnimator = {
//		assert(self.scrollView != nil)
//		return UIDynamicAnimator(referenceView: self.scrollView)
//	}()

	// *****************************
	// MARK: MVC Life Cycle
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()

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
			self.scrollView = UIScrollView(frame: CGRect(x: 0, y: self.topSectionContainerViewHeight, width: self.view.bounds.width, height: self.view.bounds.height - self.topSectionContainerViewHeight - self.tabBarHeight))
			self.scrollView.backgroundColor = appDelegate.theme.scrollViewBackgroundColor
			self.scrollView.userInteractionEnabled = true
			self.scrollView.bounces = true
			self.scrollView.showsHorizontalScrollIndicator = false
			self.scrollView.showsVerticalScrollIndicator = true
			self.scrollView.delegate = self
			self.view.insertSubview(self.scrollView, atIndex: 0)

			self.scrollView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.topSectionContainerView.snp_bottom)
				make.trailing.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
			}
		}

		// *****************************
		// Configure Scroll View Overlay
		// *****************************

		if self.scrollViewOverlay == nil {
			self.scrollViewOverlay = UIButton(frame: CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: self.scrollView.bounds.height))
			self.scrollViewOverlay.addTarget(self.topSectionViewController, action: "dismissInputTextKeyboard", forControlEvents: .TouchUpInside)
			self.scrollViewOverlay.backgroundColor = appDelegate.theme.scrollViewOverlayColor
			self.scrollViewOverlay.opaque = false
			self.scrollViewOverlay.layer.borderColor = UIColor.clearColor().CGColor
			self.scrollViewOverlay.layer.borderWidth = 0
			self.scrollViewOverlay.hidden = true
			self.scrollViewOverlay.titleLabel?.text = nil
			self.view.insertSubview(self.scrollViewOverlay, aboveSubview: self.scrollView)

			self.scrollViewOverlay.snp_remakeConstraints(closure: { (make) -> Void in
				make.edges.equalTo(self.scrollView)
			})
		}

		// Configure scrollView animator
//		self.animator.addBehavior(self.gravityBehavior)
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		// If there's no card view on the screen, fetch from core data or add some if first launch
		if self.cardViews.isEmpty {
			self.fetchCardsAndUpdateCardViews()
			self.addCardsIfFirstLaunch()
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
		let animationDuration = 0.25 * appDelegate.animationDurationScalar
		if scrollView.contentOffset.y <= 20 && self.topSectionHidden {
			// Show input area
			self.topSectionHidden = false
			self.topSectionContainerView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
			})

			UIView.animateWithDuration(animationDuration
				, delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.topSectionViewController.inputTextView.alpha = 1
					self.topSectionViewController.outputTextView.alpha = 1
				}) { succeed in
					if succeed {
						if !self.topSectionViewController.inputTextView.isFirstResponder() {
							self.topSectionViewController.roundButtonView.appearWithAnimationType([.Scale, .Fade], duration: animationDuration)
						}
					}
			}

		} else if scrollView.contentOffset.y >= hiddingSectionHeight && scrollView.contentSize.height > self.view.bounds.height && !self.topSectionHidden {
			// Only hide input view if the content for scroll view is large enough to be displayed on a full size scroll view.
			// Hide input area
			self.topSectionHidden = true

			self.topSectionContainerView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view).offset(-hiddingSectionHeight)
			})

			if !self.topSectionViewController.inputTextView.isFirstResponder() {
				self.topSectionViewController.roundButtonView.disappearWithAnimationType([.Scale, .Fade], duration: animationDuration)
			}
			UIView.animateWithDuration(animationDuration
				, delay: 0,
				options: .CurveEaseOut,
				animations: {
					self.view.layoutIfNeeded()
					self.topSectionViewController.inputTextView.alpha = 0
					self.topSectionViewController.outputTextView.alpha = 0
			}, completion: nil)
		}
		self.restoreCurrentFlippedCard()
	}

	// *****************************
	// MARK: Card View Delegate
	// *****************************

	func cardViewTapped(cardView:CardView) {
		let tappingCurrentExpandedView = self.currentExpandedCard === cardView
		self.collapseCurrentExpandedCard()
		if !tappingCurrentExpandedView {
			if cardView !== self.currentFlippedCard {
				cardView.flip()
			}
			self.restoreCurrentFlippedCard()
			if cardView.flipped {
				self.currentFlippedCard = cardView
			}
		}
	}

	func cardViewHeld(cardView: CardView) {
		// Expand card view.
		let heldCurrentExpandedView = self.currentExpandedCard === cardView
		self.collapseCurrentExpandedCard()
		self.restoreCurrentFlippedCard()
		if !heldCurrentExpandedView {
			// Calculate if we need to expand the card.
			let labelWidth = cardView.topLabel.bounds.width
			// FIX ME: Calculation not right, should use the other way, but it has a BUG.
			if ceil(cardView.topLabel.attributedText!.size().width/labelWidth) > 1 ||
				ceil(cardView.bottomLabel.attributedText!.size().width/labelWidth) > 1 {
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
	}

	func cardViewShareButtonTapped(cardView:CardView) {
		if let morse = cardView.morse {
			// TODO: How to use only Morse code when copying.
			let activityVC = UIActivityViewController(activityItems: [morse + "\n" + LocalizedStrings.General.sharePromote + " " + appStoreURLString], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = cardView.shareButton
			self.presentViewController(activityVC, animated: true) {
				self.restoreCurrentFlippedCard()
			}
		}
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
					if succeed {
						// Update scrollView contentSize
						self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height - cardView.bounds.height - theme.cardViewGap)

						// If the content size of scroll view is smaller than scroll view frame, show top section
						if self.scrollView.contentSize.height < self.scrollView.bounds.height {
							self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
						}
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
				assert(cards.count == 1) // There should only be one card with this unique ID
				for card in cards {
					managedContext.deleteObject(card)
				}
				try managedContext.save()
			} catch let error as NSError {
				print("Could not fetch card to delete from Core Data \(error), \(error.userInfo)")
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
	// MARK: User Interaction Handler
	// *****************************

	// Gesture call backs.

	// *****************************
	// MARK: Card View Manipulation
	// *****************************

	func addCardViewWithText(text:String, morse:String, textOnTop:Bool = true, deletable:Bool = true, animateWithDuration duration:NSTimeInterval = 0.0) {
		let cardView = CardView(frame: CGRect(x: theme.cardViewHorizontalMargin, y: theme.cardViewGroupVerticalMargin, width: self.scrollView.bounds.width - theme.cardViewHorizontalMargin - theme.cardViewHorizontalMargin, height: theme.cardViewHeight), text: text, morse: morse, textOnTop: textOnTop)
		cardView.delegate = self
		cardView.cardUniqueID = "\(UIDevice.currentDevice().identifierForVendor)\(NSDate())\(text)\(morse)".hashValue

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
		UIView.animateWithDuration(duration / 3.0,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: { () -> Void in
				self.scrollView.layoutIfNeeded()
			}) { succeed in
				if succeed {
					UIView.animateWithDuration(duration * 2.0 / 3.0 * appDelegate.animationDurationScalar,
						delay: 0.0,
						options: .CurveEaseInOut,
						animations: { () -> Void in
							cardView.alpha = 1.0
						}) { succeed in
							if succeed {
								cardView.opaque = true
								self.saveCard(text, morse: morse, index: self.cardViews.count - 1, textOnTop: self.topSectionViewController.isDirectionEncode, favorite: false, deletable: true, cardUniqueID: cardView.cardUniqueID!)
							}
					}
				}
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
				+ (theme.cardViewHeight - cardView.paddingTop - cardView.labelVerticalGap - cardView.paddingBottom)/2.0
			let bottomLabelHeight = cardView.bottomLabel.attributedText!.boundingRectWithSize(CGSizeMake(labelWidth, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
			resultHeight = cardView.paddingTop + topLabelHeight + cardView.labelVerticalGap + bottomLabelHeight + cardView.paddingBottom

			cardView.topLabel.snp_updateConstraints(closure: { (make) -> Void in
				make.height.equalTo(topLabelHeight)
			})

			cardView.snp_updateConstraints { (make) -> Void in
				make.height.equalTo(resultHeight)
			}
		} else { // FIX ME: Constraints BUG
			cardView.topLabel.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(cardView).offset(cardView.paddingTop)
				make.trailing.equalTo(cardView).offset(-cardView.paddingTrailing)
				make.leading.equalTo(cardView).offset(cardView.paddingLeading)
				make.height.equalTo((theme.cardViewHeight - cardView.paddingTop - cardView.paddingBottom - cardView.labelVerticalGap)/2.0)
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

	private func initializeCardViewsConstraints() {
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
	private func saveCard(text: String, morse:String, index:Int, textOnTop:Bool = true, favorite:Bool = false, deletable:Bool = true, cardUniqueID:Int) {
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
				do {
					let results = try managedContext.executeFetchRequest(fetchRequest)
					cards = results as! [NSManagedObject]
				} catch let error as NSError {
					print("Could not fetch \(error), \(error.userInfo)")
				}
			}

			for card in cards {
				let cardView = CardView(frame: CGRect(x: theme.cardViewHorizontalMargin, y: theme.cardViewGroupVerticalMargin, width: self.scrollView.bounds.width - theme.cardViewHorizontalMargin - theme.cardViewHorizontalMargin, height: theme.cardViewHeight), text: card.valueForKey("text") as? String, morse: card.valueForKey("morse") as? String, textOnTop: card.valueForKey("textOnTop") as! Bool)
				cardView.delegate = self
				cardView.cardUniqueID = card.valueForKey("cardUniqueID") as? Int
				self.cardViews.append(cardView)
				self.scrollView.insertSubview(cardView, atIndex: 0)
			}
			self.initializeCardViewsConstraints()
			self.scrollView.setNeedsUpdateConstraints()
			self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
		}
	}

	// This function is called by top section VC too, so keep it public.
	func collapseCurrentExpandedCard() {
		// Collapse expanded card
		let cardView = self.currentExpandedCard
		self.currentExpandedCard = nil
		if cardView != nil {
			cardView!.expanded = false
			self.updateConstraintsForCardView(cardView!)
			UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
				delay: 0,
				options: .CurveEaseOut,
				animations: {
					cardView!.backgroundColor = appDelegate.theme.cardViewBackgroudColor
					cardView!.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
					self.scrollView.layoutIfNeeded()
				}) { succeed in
					if succeed {
						cardView!.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
					}
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
	private func addCardsIfFirstLaunch() {
		if !appDelegate.notFirstLaunch {
			let localizedTextArrays = [
				(localized:LocalizedStrings.LaunchCard.text1, english: "Welcome to Morse Transmitter!"),
				(localized:LocalizedStrings.LaunchCard.text2, english: "Tap me to expand."),
				(localized:LocalizedStrings.LaunchCard.text3, english: "Swipe to right to delete me."),
				(localized:LocalizedStrings.LaunchCard.text4, english: "Swipe to left to output and share this Morse code."),
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
			appDelegate.userDefaults.setObject(NSLocale.preferredLanguages().first!, forKey: userDefaultsKeyFirstLaunchLanguageCode)
			appDelegate.userDefaults.setValue(true, forKey: userDefaultsKeyNotFirstLaunch)
		}
	}

	func rotationDidChange() {
		if self.currentExpandedCard != nil {
			self.updateConstraintsForCardView(self.currentExpandedCard!)
		}
		for i in 0..<self.cardViews.count {
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
		if self.topSectionViewController.inputTextView.isFirstResponder() {
			self.topSectionContainerView.addMDShadow(withDepth: 3)
		} else {
			self.topSectionContainerView.addMDShadow(withDepth: 2)
		}

		for card in self.cardViews {
			card.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
		}
	}
}
