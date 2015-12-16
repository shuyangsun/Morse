//
//  CardViewDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 12/9/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

@objc protocol CardViewDelegate {
	// CardView Interactions
	optional func cardViewTapped(cardView:CardView)
	optional func cardViewHeld(cardView:CardView)
	optional func cardViewTouchesBegan(cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?)
	optional func cardViewTouchesEnded(cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?, deleteCard:Bool)
	optional func cardViewTouchesCancelled(cardView:CardView, touches: Set<UITouch>?, withEvent event: UIEvent?)
	// BackView Button Interactions
	optional func cardViewOutputButtonTapped(cardView:CardView)
	optional func cardViewShareButtonTapped(cardView:CardView)
}