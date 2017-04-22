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
	optional func cardViewTapped(_ cardView:CardView)
	optional func cardViewHeld(_ cardView:CardView)
	optional func cardViewTouchesBegan(_ cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?)
	optional func cardViewTouchesEnded(_ cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?, deleteCard:Bool)
	optional func cardViewTouchesCancelled(_ cardView:CardView, touches: Set<UITouch>?, withEvent event: UIEvent?)
	// BackView Button Interactions
	optional func cardViewOutputButtonTapped(_ cardView:CardView)
	optional func cardViewShareButtonTapped(_ cardView:CardView)
}
