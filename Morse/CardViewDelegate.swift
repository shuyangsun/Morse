//
//  CardViewDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 12/9/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

@objc protocol CardViewDelegate {
	func cardViewTapped(cardView:CardView)
	optional func cardViewHeld(cardView:CardView)
	func cardViewTouchesBegan(cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?)
	func cardViewTouchesEnded(cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?, deleteCard:Bool)
	func cardViewTouchesCancelled(cardView:CardView, touches: Set<UITouch>?, withEvent event: UIEvent?)
}