//
//  LanguageTableViewCell.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class LanguageTableViewCell: TableViewCell {

	var languageCode = "" {
		willSet {
			if newValue == "" {
				self.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Languages.systemDefault, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
			} else {
				self.textLabel?.attributedText = getAttributedStringFrom(supportedLanguages[newValue]!.original, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				self.detailTextLabel?.attributedText = getAttributedStringFrom(supportedLanguages[newValue]!.localized, withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
			}
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.tintColor = appDelegate.theme.cellCheckmarkColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	func updateColor() {
		if self.accessoryType == .None {
			self.backgroundColor = appDelegate.theme.cellBackgroundColor
			if self.languageCode == "" {
				self.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Languages.systemDefault, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
			} else {
				self.textLabel?.attributedText = getAttributedStringFrom(supportedLanguages[self.languageCode]!.original, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextColor, bold: false)
				self.detailTextLabel?.attributedText = getAttributedStringFrom(supportedLanguages[self.languageCode]!.localized, withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextColor, bold: false)
			}
		} else {
			self.backgroundColor = appDelegate.theme.cellSelectedBackgroundColor
			if self.languageCode == "" {
				self.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Languages.systemDefault, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextSelectedColor, bold: false)
			} else {
				self.textLabel?.attributedText = getAttributedStringFrom(supportedLanguages[self.languageCode]!.original, withFontSize: tableViewCellTextLabelFontSize, color: appDelegate.theme.cellTitleTextSelectedColor, bold: false)
				self.detailTextLabel?.attributedText = getAttributedStringFrom(supportedLanguages[self.languageCode]!.localized, withFontSize: tableViewCellDetailTextLabelFontSize, color: appDelegate.theme.cellDetailTitleTextSelectedColor, bold: false)
			}
		}
	}

}
