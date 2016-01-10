//
//  TableViewSwitchCell.swift
//  Morse
//
//  Created by Shuyang Sun on 1/10/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class TableViewSwitchCell: TableViewCell {

	var delegate:TableViewSwitchCellDelegate? = nil
	var switchButton:UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

		// Add switch
		self.switchButton = UISwitch()
		self.switchButton.onTintColor = theme.switchOnTintColor
		self.contentView.addSubview(self.switchButton)
		self.switchButton.addTarget(self, action: "switchToggled", forControlEvents: .ValueChanged)
		self.switchButton.snp_makeConstraints(closure: { (make) -> Void in
			make.centerY.equalTo(self.contentView)
			make.height.equalTo(switchButtonHeight)
			make.width.equalTo(switchButtonWidth)
			make.trailing.equalTo(self.contentView).offset(-tableViewCellTrailingPadding)
		})
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	override func updateColor() {
		super.updateColor()
		self.switchButton.onTintColor = theme.switchOnTintColor
	}

	func switchToggled() {
		self.delegate?.switchToggled?(self.switchButton)
	}
}
