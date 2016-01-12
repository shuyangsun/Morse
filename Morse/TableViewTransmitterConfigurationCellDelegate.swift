//
//  TableViewTransmitterConfigurationCellDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 1/11/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import Foundation

@objc protocol TableViewTransmitterConfigurationCellDelegate {
	optional func transConfigCell(cell:TableViewTransmitterConfigurationCell, minusButtonTapped button:UIButton)
	optional func transConfigCell(cell:TableViewTransmitterConfigurationCell, plusButtonTapped button:UIButton)
	optional func transConfigCell(cell:TableViewTransmitterConfigurationCell, sliderValueChanged slider:UISlider)
}
