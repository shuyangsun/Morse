//
//  TableViewCell.swift
//  Morse
//
//  Created by Shuyang Sun on 12/15/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

		let tapGR = UITapGestureRecognizer(target: self, action: "tapped:")
		tapGR.cancelsTouchesInView = false
		self.addGestureRecognizer(tapGR)
    }

	func tapped(tapGR:UITapGestureRecognizer) {
		let location = tapGR.locationInView(self)
		self.triggerTapFeedBack(atLocation:location, withColor: appDelegate.theme.cellTapFeedBackColor, duration: TAP_FEED_BACK_DURATION, atBottom: false)
	}
}
