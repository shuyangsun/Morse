//
//  TableViewSwitchCell.swift
//  Morse
//
//  Created by Shuyang Sun on 1/10/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class TableViewSwitchCell: TableViewCell {

	override var tag:Int {
		willSet {
			self.switchButton.tag = newValue
		}
	}

	var delegate:TableViewSwitchCellDelegate? = nil
	var switchButton:UISwitch!
	var displaySwitchNextToLabel = false {
		willSet {
//			if newValue {
//				self.textLabelCouldChange = true
//			}
//			self.switchButton.snp_remakeConstraints(closure: { (make) -> Void in
//				make.centerY.equalTo(self.contentView)
//				make.height.equalTo(switchButtonHeight)
//				make.width.equalTo(switchButtonWidth)
//				if newValue && self.textLabel != nil {
//					make.leading.equalTo(self.textLabel!.snp_trailing).offset(tableViewCellHorizontalPadding)
//				} else {
//					make.trailing.equalTo(self.contentView).offset(-tableViewCellHorizontalPadding)
//				}
//			})
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

		// Add switch
		self.switchButton = UISwitch()
		self.switchButton.onTintColor = theme.switchOnTintColor
		self.contentView.addSubview(self.switchButton)
		self.switchButton.addTarget(self, action: #selector(TableViewSwitchCell.switchToggled), for: .valueChanged)
		self.switchButton.snp_remakeConstraints({ (make) -> Void in
			make.centerY.equalTo(self.contentView)
			make.height.equalTo(switchButtonHeight)
			make.width.equalTo(switchButtonWidth)
			make.trailing.equalTo(self.contentView).offset(-tableViewCellHorizontalPadding)
		})
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	/**
	Responsible for updating the UI when user changes the theme.
	*/
	override func updateColor() {
		super.updateColor()
		self.switchButton.onTintColor = theme.switchOnTintColor
	}

	func switchToggled() {
		self.delegate?.switchToggled?(self.switchButton)
	}
}
