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
	@objc optional func cardViewTapped(_ cardView:CardView)
	@objc optional func cardViewHeld(_ cardView:CardView)
	@objc optional func cardViewTouchesBegan(_ cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?)
	@objc optional func cardViewTouchesEnded(_ cardView:CardView, touches: Set<UITouch>, withEvent event: UIEvent?, deleteCard:Bool)
	@objc optional func cardViewTouchesCancelled(_ cardView:CardView, touches: Set<UITouch>?, withEvent event: UIEvent?)
	// BackView Button Interactions
	@objc optional func cardViewOutputButtonTapped(_ cardView:CardView)
	@objc optional func cardViewShareButtonTapped(_ cardView:CardView)
}
