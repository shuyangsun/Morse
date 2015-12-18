//
//  MorseDictionaryViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MorseDictionaryViewController: UIViewController, CardViewDelegate, UIScrollViewDelegate {

	// *****************************
	// MARK: Views
	// *****************************

	// Top bar views
	var statusBarView: UIView!
	var topBarView: UIView!
	var topBarLabel: UILabel!
	var scrollView:UIScrollView!
	private var currentFlippedCard:CardView?

	private var cardViews:[CardView] = []
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

	private let cardViewMinWidth:CGFloat = 150

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
			self.topBarView.addMDShadow(withDepth: 2)
		}

		if self.scrollView == nil {
			self.scrollView = UIScrollView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - statusBarHeight - topBarHeight - self.tabBarHeight))
			self.scrollView.backgroundColor = appDelegate.theme.scrollViewBackgroundColor
			self.scrollView.userInteractionEnabled = true
			self.scrollView.bounces = true
			self.scrollView.showsHorizontalScrollIndicator = false
			self.scrollView.showsVerticalScrollIndicator = true
			self.scrollView.delegate = self
			self.view.insertSubview(self.scrollView, atIndex: 0)

			self.scrollView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.trailing.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
			}
		}
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.addCards()
		dispatch_sync(dispatch_queue_create("Update Card View Constraints On Dictonary VC Queue", nil)) {
			self.initializeCardViewsConstraints()
		}
		self.view.setNeedsUpdateConstraints()
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
		self.restoreCurrentFlippedCard()
	}

	// *****************************
	// MARK: Card Stuff
	// *****************************

	private func addCardViewWithText(text:String, morse:String) {
		let cardView = CardView(frame: CGRect(x: appDelegate.theme.cardViewHorizontalMargin, y: appDelegate.theme.cardViewGroupVerticalMargin, width: self.scrollView.bounds.width - appDelegate.theme.cardViewHorizontalMargin - appDelegate.theme.cardViewHorizontalMargin, height: appDelegate.theme.cardViewHeight), text: text, morse: morse, textOnTop: true)
		cardView.delegate = self

		if self.cardViews.isEmpty {
			self.scrollView.addSubview(cardView)
		} else {
			self.scrollView.insertSubview(cardView, belowSubview: self.cardViews.last!)
		}
		self.cardViews.append(cardView)
		self.scrollView.addSubview(cardView)
	}

	func cardViewTapped(cardView:CardView) {
		if cardView !== self.currentFlippedCard {
			cardView.flip()
		}
		self.restoreCurrentFlippedCard()
		if cardView.flipped {
			self.currentFlippedCard = cardView
		}
	}

	func cardViewShareButtonTapped(cardView:CardView) {
		if let morse = cardView.morse {
			// TODO: How to use only Morse code when copying.
			let activityVC = UIActivityViewController(activityItems: [LocalizedStrings.General.sharePromote + " " + appStoreURLString + "\n" + morse], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = cardView.shareButton
			self.presentViewController(activityVC, animated: true) {
				self.restoreCurrentFlippedCard()
			}
		}
	}

	// This function does not take care of updating card constraints! It only put cardViews on the scrollView and array.
	private func addCards() {
		if self.cardViews.isEmpty {
			let textFontSize:CGFloat = 22
			let morseFontSize:CGFloat = 9
			let keys = MorseTransmitter.keys
			for var i = keys.count - 1; i >= 0; i-- {
				// Adding cards may take a while, so do it in another thread. Has to be synced because it's about UI
				dispatch_sync(dispatch_queue_create("Create Card Views On Dictonary VC Queue", nil)) {
					let text = keys[i]
					let morse = MorseTransmitter.encodeTextToMorseStringDictionary[text]!
					let colNum = Int(max(1, floor((self.view.bounds.width - theme.cardViewHorizontalMargin * 2 + theme.cardViewGap) / (self.cardViewMinWidth + theme.cardViewGap))))
					let width = (self.scrollView.bounds.width - theme.cardViewHorizontalMargin * 2 - CGFloat(colNum - 1) * theme.cardViewGap)/CGFloat(colNum)
					let cardView = CardView(frame: CGRect(x: theme.cardViewHorizontalMargin, y: theme.cardViewGroupVerticalMargin, width: width, height: theme.cardViewHeight), text: text.uppercaseString, morse: morse, textOnTop: true, deletable: false, textFontSize: textFontSize, morseFontSize: morseFontSize)
					cardView.delegate = self
					self.cardViews.append(cardView)
				}
			}

			for var i = self.cardViews.count - 1; i >= 0; i-- {
				self.scrollView.addSubview(self.cardViews[i])
			}
		}
	}

	private func initializeCardViewsConstraints() {
		let colNum = Int(max(1, floor((self.view.bounds.width - theme.cardViewHorizontalMargin * 2 + theme.cardViewGap) / (self.cardViewMinWidth + theme.cardViewGap))))
		let width = (self.scrollView.bounds.width - theme.cardViewHorizontalMargin * 2 - CGFloat(colNum - 1) * theme.cardViewGap)/CGFloat(colNum)
		let height = theme.cardViewHeight
		for i in 0..<self.cardViews.count {
			let card = self.cardViews[(self.cardViews.count - 1 - i)]
			var leftOffset = theme.cardViewHorizontalMargin + CGFloat(i%colNum) * (width + theme.cardViewGap)
			if layoutDirection == .RightToLeft {
				leftOffset = theme.cardViewHorizontalMargin + CGFloat((colNum - 1) - (i%colNum)) * (width + theme.cardViewGap)
			}
			card.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.scrollView).offset(theme.cardViewGroupVerticalMargin + CGFloat(i/colNum) * (height + theme.cardViewGap))
				make.width.equalTo(width)
				make.height.equalTo(height)
				make.left.equalTo(self.scrollView).offset(leftOffset)
			})
		}

		var contentHeight:CGFloat = 0
		if !self.cardViews.isEmpty {
			let count = self.cardViews.count
			let rowNum = count/colNum + (count % colNum == 0 ? 0 : 1)
			contentHeight = theme.cardViewGroupVerticalMargin * 2 + CGFloat(rowNum) * theme.cardViewHeight + CGFloat(rowNum - 1) * theme.cardViewGap
		}
		self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
	}

	private func updateMDShadows() {
		self.topBarView.addMDShadow(withDepth: 2)
		for card in self.cardViews {
			card.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
		}
	}

	func restoreCurrentFlippedCard() {
		// Flip back flipped card
		if self.currentFlippedCard != nil && self.currentFlippedCard!.flipped {
			self.currentFlippedCard?.flip()
		}
		self.currentFlippedCard = nil
	}

	func rotationDidChange() {
		dispatch_sync(dispatch_queue_create("Update Card View Constraints On Dictonary VC Queue", nil)) {
			self.initializeCardViewsConstraints()
		}
		UIView.animateWithDuration(TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
			delay: 0,
			options: .CurveEaseOut,
			animations: {
				self.scrollView.layoutIfNeeded()
			}) { succeed in
				if succeed {
					self.updateMDShadows()
				}
		}
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
