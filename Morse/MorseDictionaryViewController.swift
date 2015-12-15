//
//  MorseDictionaryViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MorseDictionaryViewController: UIViewController, CardViewDelegate {

	// *****************************
	// MARK: Views
	// *****************************

	// Top bar views
	var statusBarView: UIView!
	var topBarView: UIView!
	var topBarLabel: UILabel!
	var scrollView:UIScrollView!

	private var cardViews:[CardView] = []

	private var currentExpandedView:CardView?
	private var transmitter = MorseTransmitter()

	// *****************************
	// MARK: View Related Variables
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

	// *****************************
	// MARK: MVC LifeCycle
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()

		if self.statusBarView == nil {
			self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: statusBarHeight))
			self.statusBarView.backgroundColor = appDelegate.theme.statusBarBackgroundColor
			self.view.addSubview(self.statusBarView)
			self.statusBarView.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(statusBarHeight)
			})
		}

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: self.view.bounds.width, height: topBarHeight))
			self.topBarView.backgroundColor = appDelegate.theme.topBarBackgroundColor
			self.view.addSubview(topBarView)

			self.topBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.statusBarView.snp_bottom)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(topBarHeight)
			})

			if self.topBarLabel == nil {
				self.topBarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.topBarView.bounds.width, height: topBarHeight))
				self.topBarLabel.textAlignment = .Center
				self.topBarLabel.tintColor = appDelegate.theme.topBarLabelTextColor
				self.topBarLabel.attributedText = NSAttributedString(string: LocalizedStrings.Label.topBarMorseDictionary, attributes:
					[NSFontAttributeName: UIFont.boldSystemFontOfSize(23),
						NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
				self.topBarView.addSubview(self.topBarLabel)

				self.topBarLabel.snp_remakeConstraints(closure: { (make) -> Void in
					make.edges.equalTo(self.topBarView).inset(UIEdgeInsetsMake(0, 0, 0, 0))
				})
			}
		}

		if self.scrollView == nil {
			self.scrollView = UIScrollView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - statusBarHeight - topBarHeight - self.tabBarHeight))
			self.scrollView.backgroundColor = appDelegate.theme.scrollViewBackgroundColor
			self.scrollView.userInteractionEnabled = true
			self.scrollView.bounces = true
			self.scrollView.showsHorizontalScrollIndicator = false
			self.scrollView.showsVerticalScrollIndicator = true
			self.view.insertSubview(self.scrollView, atIndex: 0)

			self.scrollView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.trailing.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
			}
		}

		self.addCards()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	private func addCardViewWithText(text:String, morse:String) {
		let cardView = CardView(frame: CGRect(x: self.cardViewLeadingMargin, y: self.cardViewTopMargin, width: self.scrollView.bounds.width - self.cardViewLeadingMargin - self.cardViewTrailingMargin, height: self.cardViewHeight), text: text, morse: morse, textOnTop: true)
		cardView.delegate = self

		if self.cardViews.isEmpty {
			self.scrollView.addSubview(cardView)
		} else {
			self.scrollView.insertSubview(cardView, belowSubview: self.cardViews.last!)
		}
		self.cardViews.append(cardView)
		self.scrollView.addSubview(cardView)
	}

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
					self.updateConstraintsForCardView(cardView)
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

	func cardViewTouchesBegan(cardView: CardView, touches: Set<UITouch>, withEvent event: UIEvent?) {
		let ind = self.cardViews.indexOf(cardView)!
		if ind < self.cardViews.count - 1 {
			self.scrollView.insertSubview(cardView, atIndex: 0)
		}
	}

	func cardViewTouchesEnded(cardView: CardView, touches: Set<UITouch>, withEvent event: UIEvent?, deleteCard:Bool) {
		self.scrollView.scrollEnabled = true
	}

	func cardViewTouchesCancelled(cardView: CardView, touches: Set<UITouch>?, withEvent event: UIEvent?) {
		self.scrollView.scrollEnabled = true
	}

	// This function is called by top section VC too, so keep it public.
	func collapseCurrentExpandedView() {
		let cardView = self.currentExpandedView
		self.currentExpandedView = nil
		if cardView != nil {
			cardView!.expanded = false
			self.updateConstraintsForCardView(cardView!)
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

	private func addCards() {
		if self.cardViews.isEmpty {
			let keys = MorseTransmitter.keys
			var lastCardView:CardView? = nil
			for var i = keys.count - 1; i >= 0; i-- {
				let text = keys[i]
				let morse = MorseTransmitter.encodeTextToMorseStringDictionary[text]!
				let cardView = CardView(frame: CGRect(x: self.cardViewLeadingMargin, y: self.cardViewTopMargin, width: self.scrollView.bounds.width - self.cardViewLeadingMargin - self.cardViewTrailingMargin, height: self.cardViewHeight), text: text.uppercaseString, morse: morse, textOnTop: true, deletable: false)
				cardView.delegate = self
				if lastCardView == nil {
					self.scrollView.addSubview(cardView)
				} else {
					self.scrollView.insertSubview(cardView, belowSubview: lastCardView!)
				}

				lastCardView = cardView
				self.cardViews.append(cardView)
			}
			
			self.initializeCardViewsConstraints()
			self.view.layoutIfNeeded()
		}
	}

	private func updateConstraintsForCardView(cardView:CardView, indexInCardViewsArray index:Int? = nil) {
		let ind = index == nil ? self.cardViews.indexOf(cardView)! : index!
		var heightChange:CGFloat = 0
		cardView.snp_remakeConstraints(closure: { (make) -> Void in
			make.left.equalTo(self.scrollView.snp_left).offset(self.cardViewLeadingMargin)
			make.width.equalTo(self.scrollView).offset(-(self.cardViewLeadingMargin + self.cardViewTrailingMargin))
		})
		if ind == self.cardViews.count - 1 {
			cardView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.scrollView).offset(self.cardViewTopMargin)
			})
		} else {
			cardView.snp_updateConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.cardViews[ind + 1].snp_bottom).offset(self.cardViewGapY)
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
			// FIX ME: using "+ (self.cardViewHeight - cardView.paddingTop - cardView.gapY - cardView.paddingBottom)/2.0" because of a bug in this calculation.
			let labelWidth = cardView.topLabel.frame.width
			let topLabelHeight = cardView.topLabel.attributedText!.boundingRectWithSize(CGSizeMake(labelWidth, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
				+ (self.cardViewHeight - cardView.paddingTop - cardView.gapY - cardView.paddingBottom)/2.0
			let bottomLabelHeight = cardView.bottomLabel.attributedText!.boundingRectWithSize(CGSizeMake(labelWidth, CGFloat.max), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil).height
			resultHeight = cardView.paddingTop + topLabelHeight + cardView.gapY + bottomLabelHeight + cardView.paddingBottom

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
				make.height.equalTo((cardView.bounds.height - cardView.paddingTop - cardView.paddingBottom - cardView.gapY)/2.0)
			}
			cardView.snp_updateConstraints(closure: { (make) -> Void in
				make.height.equalTo(self.cardViewHeight)
			})

			resultHeight = self.cardViewHeight
		}
		heightChange = resultHeight - originalCardViewHeight
		cardView.addMDShadow(withDepth: 1)
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.scrollView.contentSize.height + heightChange)
	}

	private func initializeCardViewsConstraints() {
		for i in 0..<self.cardViews.count {
			self.updateConstraintsForCardView(self.cardViews[i], indexInCardViewsArray: i)
		}

		var contentHeight:CGFloat = 0
		if !self.cardViews.isEmpty {
			let count = self.cardViews.count
			contentHeight = self.cardViewTopMargin + self.cardViewBottomMargin + CGFloat(count) * self.cardViewHeight + CGFloat(count - 1) * self.cardViewGapY
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
		print(contentHeight)
	}

	func rotationDidChange() {
		// Things to do after the rotation.
		if self.currentExpandedView != nil {
			self.updateConstraintsForCardView(self.currentExpandedView!)
		}
		for i in 0..<self.cardViews.count {
			self.cardViews[i].snp_updateConstraints(closure: { (make) -> Void in
				make.width.equalTo(self.scrollView).offset(-(self.cardViewLeadingMargin + self.cardViewTrailingMargin))
			})
		}
		self.scrollView.layoutIfNeeded()
		for card in self.cardViews {
			card.addMDShadow(withDepth: 1)
		}

		let count = self.cardViews.count
		var contentHeight = self.cardViewTopMargin + self.cardViewBottomMargin + CGFloat(count - 1) * self.cardViewGapY + CGFloat(count - 1) * self.cardViewHeight
		if count == 0 {
			contentHeight = 0
		} else {
			if self.currentExpandedView != nil {
				contentHeight += self.currentExpandedView!.bounds.height
			} else {
				contentHeight += self.cardViewHeight
			}
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
