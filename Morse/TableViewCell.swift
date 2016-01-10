//
//  TableViewCell.swift
//  Morse
//
//  Created by Shuyang Sun on 12/15/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
	var tapFeebackEnabled = true
	var textLabelCouldChange = false
	var detailedTextLabelCouldChange = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

		self.backgroundColor = theme.tableViewCellBackgroundColor
		self.tintColor = theme.tableViewCellCheckmarkColor
		self.textLabel?.text = nil
		self.detailTextLabel?.text = nil
		self.selectionStyle = .None

		let tapGR = UITapGestureRecognizer(target: self, action: "tapped:")
		tapGR.cancelsTouchesInView = false
		self.addGestureRecognizer(tapGR)
    }

	func tapped(tapGR:UITapGestureRecognizer) {
		if self.tapFeebackEnabled {
			let location = tapGR.locationInView(self)
			self.triggerTapFeedBack(atLocation:location, withColor: theme.cellTapFeedBackColor, duration: TAP_FEED_BACK_DURATION, atBottom: false)
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if let textLabelFrame = self.textLabel?.frame {
			if self.textLabelCouldChange {
				self.textLabel?.frame = CGRect(origin: textLabelFrame.origin, size: CGSize(width: tableViewCellTextLabelWidth, height: textLabelFrame.height))
			}
		}

		if let detailedTextLabelFrame = self.detailTextLabel?.frame {
			if self.detailedTextLabelCouldChange {
				self.detailTextLabel?.frame = CGRect(origin: detailedTextLabelFrame.origin, size: CGSize(width: tableViewCellTextLabelWidth, height: detailedTextLabelFrame.height))
			}
		}
	}

	func updateColor() {
		self.tintColor = theme.tableViewCellCheckmarkColor
		if self.accessoryType == .None {
			self.backgroundColor = theme.tableViewCellBackgroundColor
			self.textLabel?.attributedText = getAttributedStringFrom(self.textLabel!.text, withFontSize: tableViewCellTextLabelFontSize, color: theme.cellTitleTextColor, bold: false)
			self.detailTextLabel?.attributedText = getAttributedStringFrom(self.detailTextLabel!.text, withFontSize: tableViewCellDetailTextLabelFontSize, color: theme.cellDetailTitleTextColor, bold: false)
		} else {
			self.backgroundColor = theme.tableViewCellSelectedBackgroundColor
			self.textLabel?.attributedText = getAttributedStringFrom(self.textLabel!.text, withFontSize: tableViewCellTextLabelFontSize, color: theme.cellTitleTextSelectedColor, bold: false)
			self.detailTextLabel?.attributedText = getAttributedStringFrom(self.detailTextLabel!.text, withFontSize: tableViewCellDetailTextLabelFontSize, color: theme.cellDetailTitleTextSelectedColor, bold: false)
		}
	}
}
