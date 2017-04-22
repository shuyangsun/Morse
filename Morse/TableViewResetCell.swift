//
//  TableViewResetCell.swift
//  Morse
//
//  Created by Shuyang Sun on 1/11/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class TableViewResetCell: TableViewCell {

	override var tapFeedbackColor:UIColor {
		return theme.resetCellTapFeedbackColor
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.backgroundColor = theme.resetCellBackgroundColor
		self.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.reset
			, withFontSize: tableViewCellTextLabelFontSize, color: theme.resetCellTextColor, bold: false)
		self.textLabel?.textAlignment = .center
    }
}
