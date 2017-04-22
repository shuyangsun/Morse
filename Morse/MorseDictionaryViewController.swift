//
//  MorseDictionaryViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MorseDictionaryViewController: GAITrackedViewController, CardViewDelegate, UIScrollViewDelegate, MorseOutputPlayerDelegate {

	// *****************************
	// MARK: Views
	// *****************************

	// Top bar views
	var statusBarView: UIView!
	var topBarView: UIView!
	var topBarLabel: UILabel!
	var scrollView:UIScrollView!

	fileprivate var cardViews:[CardView] = []
	fileprivate var transmitter = MorseTransmitter()
	fileprivate let _toneGenerator = ToneGenerator()
	fileprivate let _outputPlayer = MorseOutputPlayer()

	// *****************************
	// MARK: View Related Variables
	// *****************************

	// Don't need tabBarHeight if using iAd
	fileprivate var tabBarHeight:CGFloat {
		if let tabBarController = self.tabBarController {
			return tabBarController.tabBar.bounds.height
		} else {
			return 0
		}
	}

	var cardViewMinWidth:CGFloat = 0.0

	fileprivate let _updateCardConstraintsQueue = DispatchQueue(label: "Update Card View Constraints On Dictonary VC Queue", attributes: [])
	fileprivate let _createCardViewsQueue = DispatchQueue(label: "Create Card Views On Dictonary VC Queue", attributes: [])

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return theme.style == .dark ? .lightContent : .default
	}

	// *****************************
	// MARK: MVC LifeCycle
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()
//		self.canDisplayBannerAds = !appDelegate.adsRemoved
		self.screenName = dictionaryVCName

		// Calculate the min width for a card to show the longest String.
		let str = NSAttributedString(string: "• • • — — — • • •", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: cardViewMorseFontSizeDictionary)])
		let size = str.size()
		self.cardViewMinWidth = max(dictionaryVCCardViewMinWidth, size.width + cardViewLabelPaddingHorizontal * 2)

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
				self.topBarLabel.textAlignment = .center
				self.topBarLabel.tintColor = appDelegate.theme.topBarLabelTextColor
				self.topBarLabel.attributedText = NSAttributedString(string: LocalizedStrings.Label.topBarMorseDictionary, attributes:
					[NSFontAttributeName: UIFont.boldSystemFont(ofSize: 23),
						NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
				self.topBarView.addSubview(self.topBarLabel)

				self.topBarLabel.snp_remakeConstraints(closure: { (make) -> Void in
					make.edges.equalTo(self.topBarView).inset(UIEdgeInsetsMake(0, 0, 0, 0))
				})
			}
			self.topBarView.addMDShadow(withDepth: 2)
		}

		if self.scrollView == nil {
			self.scrollView = UIScrollView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - statusBarHeight - topBarHeight))
			self.scrollView.backgroundColor = appDelegate.theme.scrollViewBackgroundColor
			self.scrollView.isUserInteractionEnabled = true
			self.scrollView.bounces = true
			self.scrollView.showsHorizontalScrollIndicator = false
			self.scrollView.showsVerticalScrollIndicator = true
			self.scrollView.delegate = self
			self.scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
			self.view.insertSubview(self.scrollView, at: 0)

			self.scrollView.snp_remakeConstraints { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
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

		self._outputPlayer.delegate = self

		NotificationCenter.default.addObserver(self, selector: #selector(updateColorWithAnimation), name: themeDidChangeNotificationName, object: nil)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAdsStatus", name: adsShouldDisplayDidChangeNotificationName, object: nil)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.addCards()
		self._updateCardConstraintsQueue.sync {
			self.updateCardViewsConstraints()
		}
		self.view.setNeedsUpdateConstraints()
		self.updateMDShadows()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self._outputPlayer.stop()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self._outputPlayer.stop()
	}

	// *****************************
	// MARK: Card Stuff
	// *****************************

	/**
	Private helper function that creates one cardView with given text and morse code. The cardView is created and it's added to the "cardViews" array. Note at this time none of the constraints are set, they the card is simply added onto the scrollView.
	- parameter text: Text on the card, always on top.
	- parameter morse: Morse code on the card, always at bottom.
	*/
	fileprivate func addCardViewWithText(_ text:String, morse:String) {
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

	/**
	Private helper function that creates one cardView with given text and morse code. The cardView is created and it's added to the "cardViews" array. Note at this time none of the constraints are set, they the card is simply added onto the scrollView.
	- parameter text: Text on the card, always on top.
	- parameter morse: Morse code on the card, always at bottom.
	*/
	func cardViewTapped(_ cardView:CardView) {
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
			action: "button_press",
			label: "DicVC Card View Tapped",
			value: nil).build() as [AnyHashable: Any])
		self._toneGenerator.mute()
		self._toneGenerator.stop()
		self._outputPlayer.stop()
		if let morse = cardView.morse {
			self._toneGenerator.mute()
			self._toneGenerator.play()
			self._outputPlayer.morse = morse
			self._outputPlayer.start()
		}
	}

	// This function does not take care of updating card constraints! It only put cardViews on the scrollView and array.
	fileprivate func addCards() {
		if self.cardViews.isEmpty {
			let keys = MorseTransmitter.keys
			let prosignTitlesAndMorse = LocalizedStrings.Prosign.titlesAndMorse
			for i in (0..<keys.count + prosignTitlesAndMorse.count).reversed() {
				// Adding cards may take a while, so do it in another thread. Has to be synced because it's about UI
				self._createCardViewsQueue.sync {
					var text = ""
					var morse = ""
					var textFontSize:CGFloat = 0
					var isProsignCard = false
					var isProsignEmergencyCard = false
					if i >= keys.count {
						// Add prosign cards
						isProsignCard = true
						isProsignEmergencyCard = (i == (keys.count + prosignTitlesAndMorse.count - 1))
						text = prosignTitlesAndMorse[i - keys.count].0
						morse = prosignTitlesAndMorse[i - keys.count].1
						textFontSize = cardViewTextProsignFontSizeDictionary
					} else {
						// Add regular cards
						text = keys[i]
						morse = MorseTransmitter.encodeTextToMorseStringDictionary[text]!
						text = text.uppercased()
						textFontSize = cardViewTextFontSizeDictionary
					}
					let colNum = Int(max(1, floor((self.view.bounds.width - theme.cardViewHorizontalMargin * 2 + theme.cardViewGap) / (self.cardViewMinWidth + theme.cardViewGap))))
					let width = (self.scrollView.bounds.width - theme.cardViewHorizontalMargin * 2 - CGFloat(colNum - 1) * theme.cardViewGap)/CGFloat(colNum)
					let cardView = CardView(frame: CGRect(x: theme.cardViewHorizontalMargin, y: theme.cardViewGroupVerticalMargin, width: width, height: theme.cardViewHeight), text: text, morse: morse, textOnTop: true, deletable: false, canBeFlipped: false, textFontSize: textFontSize, morseFontSize: cardViewMorseFontSizeDictionary, isProsignCard: isProsignCard, isProsignEmergencyCard: isProsignEmergencyCard)
					cardView.delegate = self
					self.cardViews.append(cardView)
				}
			}

			for i in (0..<self.cardViews.count).reversed() {
				self.scrollView.addSubview(self.cardViews[i])
			}
		}
	}

	fileprivate func updateCardViewsConstraints() {
		let colNum = Int(max(1, floor((self.view.bounds.width - theme.cardViewHorizontalMargin * 2 + theme.cardViewGap) / (self.cardViewMinWidth + theme.cardViewGap))))
		let width = (self.scrollView.bounds.width - theme.cardViewHorizontalMargin * 2 - CGFloat(colNum - 1) * theme.cardViewGap)/CGFloat(colNum)
		let height = theme.cardViewHeight
		for i in 0..<self.cardViews.count {
			let card = self.cardViews[(self.cardViews.count - 1 - i)]
			var leftOffset = theme.cardViewHorizontalMargin + CGFloat(i%colNum) * (width + theme.cardViewGap)
			if layoutDirection == .rightToLeft {
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

	fileprivate func updateMDShadows() {
		self.topBarView.addMDShadow(withDepth: 2)
		for card in self.cardViews {
			card.addMDShadow(withDepth: theme.cardViewMDShadowLevelDefault)
		}
	}

	func rotationDidChange() {
		self._updateCardConstraintsQueue.sync {
			self.updateCardViewsConstraints()
		}
		UIView.animate(withDuration: TAP_FEED_BACK_DURATION * appDelegate.animationDurationScalar,
			delay: 0,
			options: .curveEaseOut,
			animations: {
				self.scrollView.layoutIfNeeded()
			}) { succeed in
				self.updateMDShadows()
		}
	}

	// *****************************
	// MARK: Output Player Delegate
	// *****************************

	func startSignal() {
		self._toneGenerator.unmute()
	}

	func stopSignal() {
		self._toneGenerator.mute()
	}

	func playEnded() {
		self._toneGenerator.mute()
	}

	// *****************************
	// MARK: Update Color
	// *****************************

	/**
	Responsible for updating the UI when user changes the theme.
	- parameter animated: A boolean determines if the theme change should be animated.
	*/
	func updateColor(animated:Bool = true) {
		self._updateCardConstraintsQueue.sync {
			self.updateCardViewsConstraints()
		}
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animate(withDuration: duration,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				self.scrollView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.scrollView.backgroundColor = theme.scrollViewBackgroundColor
				self.statusBarView.backgroundColor = theme.statusBarBackgroundColor
				self.topBarView.backgroundColor = theme.topBarBackgroundColor
				self.topBarLabel.textColor = theme.topBarLabelTextColor
				for cardView in self.cardViews {
					cardView.layer.cornerRadius = theme.cardViewCornerRadius
					cardView.layer.borderWidth = theme.cardViewBorderWidth
					cardView.layer.borderColor = theme.cardViewBorderColor.cgColor
					if cardView.flipped {
						cardView.backView.backgroundColor = theme.cardBackViewBackgroundColor
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
//			make.top.equalTo(self.topBarView.snp_bottom)
//			make.trailing.equalTo(self.view)
//			make.leading.equalTo(self.view)
//			if self.canDisplayBannerAds {
//				make.bottom.equalTo(self.view)
//			} else {
//				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
//			}
//		}
//	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
