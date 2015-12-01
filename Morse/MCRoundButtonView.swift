//
//  MCRoundButtonView.swift
//  Morse
//
//  Created by Shuyang Sun on 12/1/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class MCRoundButtonView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	convenience init(origin:CGPoint, radius:CGFloat) {
		self.init(frame:CGRect(x: origin.x, y: origin.y, width: radius * 2, height: radius * 2))
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
}
