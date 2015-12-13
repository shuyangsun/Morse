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
	private var currentExpandedView:CardView?

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

	private var cardViewLeadingMargin:CGFloat {
		if self.traitCollection.horizontalSizeClass == .Compact {
			return 16
		} else if self.traitCollection.horizontalSizeClass == .Regular {
			return 32
		}
		return 16
	}

	private var cardViewTrailingMargin:CGFloat {
		return self.cardViewLeadingMargin
	}

	private var cardViewTopMargin:CGFloat {
		return cardViewLeadingMargin
	}

	private var cardViewBottomMargin:CGFloat {
		return self.cardViewLeadingMargin
	}

	private var cardViewGapY:CGFloat {
		if self.traitCollection.verticalSizeClass == .Regular &&
			self.traitCollection.horizontalSizeClass == .Regular {
			return 16
		} else {
			return 8
		}
	}

	private var cardViewHeight:CGFloat {
//		return 74 // This is Google Translate card view's height
		return 86
	}

	private var topSectionContainerViewHeight:CGFloat {
		return self.topSectionViewController.statusBarHeight + self.topSectionViewController.topBarHeight + self.topSectionViewController.textBackgroundViewHeight
	}

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

		// TODO: Custom tab bar item
		self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 0)
    }

	// Views are created and constraints are added in this callback
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if self.topSectionViewController.inputTextView.isFirstResponder() {
			self.topSectionContainerView.addMDShadow(withDepth: 3)
		} else {
			self.topSectionContainerView.addMDShadow(withDepth: 2)
		}
		self.updateCardViewsConstraints()
		self.view.layoutIfNeeded()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if self.scrollView.subviews.isEmpty {
			self.fetchCardsAndUpdateCardViews()
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// *****************************
	// MARK: Scroll View Delegate
	// *****************************

	func scrollViewDidScroll(scrollView: UIScrollView) {
		let hiddingSectionHeight = self.topSectionContainerViewHeight - self.topSectionViewController.keyboardButtonViewHeight - self.topSectionViewController.statusBarHeight
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
	}

	// *****************************
	// MARK: Card View Delegate
	// *****************************

	func cardViewTapped(cardView: CardView) {
		// Expand card view.
		if self.currentExpandedView == cardView {
			// If the current expanded view is the tapped card view, collapse it and done.
			self.collapseCurrentExpandedView()
		} else {
			// If the current expanded view is not the tapped card view, collapse the expanded view and expand card view.
			self.collapseCurrentExpandedView()
			// Calculate if we need to expand the card.
			let labelWidth = cardView.topLabel.bounds.width
			// FIX ME: Calculation not right, should use the other way, but it has a BUG.
			if ceil(cardView.topLabel.attributedText!.size().width/labelWidth) > 1 ||
				ceil(cardView.bottomLabel.attributedText!.size().width/labelWidth) > 1 {
					cardView.expanded = true
					self.currentExpandedView = cardView
					self.updateCardViewsConstraints()
					// Change cardView background color animation.
					UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
						delay: 0,
						options: .CurveEaseOut,
						animations: {
							self.scrollView.layoutIfNeeded()
							cardView.backgroundColor = appDelegate.theme.cardViewExpandedBackgroudColor
							cardView.addMDShadow(withDepth: 1)
					}, completion: nil)
			}
		}
	}

	// *****************************
	// MARK: User Interaction Handler
	// *****************************

	// Gesture call backs.

	// *****************************
	// MARK: Card View Manipulation
	// *****************************

	func addCardViewWithText(text:String, morse:String, textOnTop:Bool = true, animateWithDuration duration:NSTimeInterval = 0.0) {
		let cardView = CardView(frame: CGRect(x: self.cardViewLeadingMargin, y: self.cardViewTopMargin, width: self.scrollView.bounds.width - self.cardViewLeadingMargin - self.cardViewTrailingMargin, height: self.cardViewHeight), text: text, morse: morse, textOnTop: textOnTop)
		cardView.delegate = self

		cardView.opaque = false
		cardView.alpha = 0.0
		if self.cardViews.isEmpty {
			self.scrollView.addSubview(cardView)
		} else {
			self.scrollView.insertSubview(cardView, belowSubview: self.cardViews.last!)
		}
		self.cardViews.append(cardView)
		self.updateCardViewsConstraints()
		self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
		UIView.animateWithDuration(duration / 3.0,
			delay: 0.0,
			options: .CurveEaseInOut,
			animations: { () -> Void in
				self.scrollView.layoutIfNeeded()
			}) { succeed in
				if succeed {
					UIView.animateWithDuration(duration * 2.0 / 3.0,
						delay: 0.0,
						options: .CurveEaseInOut,
						animations: { () -> Void in
							cardView.alpha = 1.0
						}) { succeed in
							if succeed {
								cardView.opaque = true
								self.saveCard(text, morse: morse, index: self.cardViews.count - 1, textOnTop: self.topSectionViewController.isDirectionEncode, favorite: false, deletable: true)
							}
					}
				}
		}
	}

	private func updateCardViewsConstraints() {
		let views = self.cardViews
		var contentHeight = self.cardViewTopMargin
		for var i = views.count - 1; i >= 0; i-- {
			let cardView = views[i]
			if i >= views.count - 1 {
				cardView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.scrollView).offset(self.cardViewTopMargin)
					make.left.equalTo(self.scrollView).offset(self.cardViewLeadingMargin)
					make.width.equalTo(self.scrollView.bounds.width - self.cardViewLeadingMargin - self.cardViewTrailingMargin)
				})
			} else {
				cardView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(views[i + 1].snp_bottom).offset(self.cardViewGapY)
					make.left.equalTo(self.scrollView).offset(self.cardViewLeadingMargin)
					make.width.equalTo(self.view.bounds.width - self.cardViewLeadingMargin - self.cardViewTrailingMargin)
				})
			}

			// Update view height depends on if it's expanded.
			if cardView.expanded {
				cardView.topLabel.lineBreakMode = .ByWordWrapping
				cardView.topLabel.numberOfLines = 0
				cardView.bottomLabel.lineBreakMode = .ByWordWrapping
				cardView.bottomLabel.numberOfLines = 0

				// Calculate the new height for top and bottom label.
				// FIX ME: using "+ (self.cardViewHeight - cardView.paddingTop - cardView.gapY - cardView.paddingBottom)/2.0" because of a bug in this calculation.
				let labelWidth = cardView.topLabel.frame.width
				let topLabelHeight = cardView.topLabel.attributedText!.boundingRectWithSize(CGSizeMake(labelWidth, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
					+ (self.cardViewHeight - cardView.paddingTop - cardView.gapY - cardView.paddingBottom)/2.0
				let bottomLabelHeight = cardView.bottomLabel.attributedText!.boundingRectWithSize(CGSizeMake(labelWidth, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
				let expandedCardViewHeight = cardView.paddingTop + topLabelHeight + cardView.gapY + bottomLabelHeight + cardView.paddingBottom

				cardView.topLabel.snp_updateConstraints(closure: { (make) -> Void in
					make.height.equalTo(topLabelHeight)
				})

				cardView.snp_updateConstraints { (make) -> Void in
					make.height.equalTo(expandedCardViewHeight)
				}
				contentHeight += (expandedCardViewHeight + self.cardViewGapY)
			} else { // FIX ME: Constraints BUG
				cardView.topLabel.snp_remakeConstraints { (make) -> Void in
					make.top.equalTo(cardView).offset(cardView.paddingTop)
					make.trailing.equalTo(cardView).offset(-cardView.paddingTrailing)
					make.leading.equalTo(cardView).offset(cardView.paddingLeading)
					make.height.equalTo((cardView.bounds.height - cardView.paddingTop - cardView.paddingBottom - cardView.gapY)/2.0)
				}
				cardView.snp_updateConstraints(closure: { (make) -> Void in
					make.height.equalTo(self.cardViewHeight)
				})

				cardView.topLabel.snp_updateConstraints(closure: { (make) -> Void in
					make.height.equalTo((self.cardViewHeight - cardView.paddingTop - cardView.gapY - cardView.paddingBottom)/2.0)
				})
				contentHeight += (self.cardViewHeight + self.cardViewGapY)
			}
			cardView.addMDShadow(withDepth: 1)
		}

		contentHeight += self.cardViewBottomMargin
		if !self.cardViews.isEmpty {
			contentHeight -= self.cardViewGapY
		} else {
			contentHeight = 0
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
	}

	// *****************************
	// MARK: Core Data
	// *****************************

	// This method is called after creating a new card on the scrollView, to save it's data into CoreData.
	private func saveCard(text: String, morse:String, index:Int, textOnTop:Bool = true, favorite:Bool = false, deletable:Bool = true) {
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
		card.setValue("\(UIDevice.currentDevice().identifierForVendor)\(date)".hashValue, forKey: "cardUniqueID")
		card.setValue("Text Morse", forKey: "transmitterType")

		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Could not save \(error), \(error.userInfo)")
		}
	}

	private func fetchCardsAndUpdateCardViews() {
		// If there is no card on the board, fetch some cards
		if self.cardViews.isEmpty {
			let managedContext = appDelegate.managedObjectContext

			let fetchRequest = NSFetchRequest(entityName: "Card")
			let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
			fetchRequest.sortDescriptors = [sortDescriptor]

			do {
				let results = try managedContext.executeFetchRequest(fetchRequest)
				let cards = results as! [NSManagedObject]
				var lastCardView:CardView? = nil
				for card in cards {
					let cardView = CardView(frame: CGRect(x: self.cardViewLeadingMargin, y: self.cardViewTopMargin, width: self.scrollView.bounds.width - self.cardViewLeadingMargin - self.cardViewTrailingMargin, height: self.cardViewHeight), text: card.valueForKey("text") as? String, morse: card.valueForKey("morse") as? String, textOnTop: card.valueForKey("textOnTop") as! Bool)
					cardView.delegate = self
					cardView.uniqueID = card.valueForKey("cardUniqueID") as? Int
					if lastCardView == nil {
						self.scrollView.addSubview(cardView)
					} else {
						self.scrollView.insertSubview(cardView, belowSubview: lastCardView!)
					}
					lastCardView = cardView
					self.cardViews.append(cardView)
					self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: 1), animated: true)
					self.updateCardViewsConstraints()
					self.view.layoutIfNeeded()
				}
			} catch let error as NSError {
				print("Could not fetch \(error), \(error.userInfo)")
			}
		}
	}

	func collapseCurrentExpandedView() {
		let cardView = self.currentExpandedView
		self.currentExpandedView = nil
		if cardView != nil {
			cardView!.expanded = false
			self.updateCardViewsConstraints()
			UIView.animateWithDuration(TAP_FEED_BACK_DURATION/2.0 * appDelegate.animationDurationScalar,
				delay: 0,
				options: .CurveEaseOut,
				animations: {
					cardView!.backgroundColor = appDelegate.theme.cardViewBackgroudColor
					cardView!.addMDShadow(withDepth: 1)
					self.scrollView.layoutIfNeeded()
				}) { succeed in
					if succeed {
						cardView!.addMDShadow(withDepth: 1)
					}
			}
		}
	}
}
