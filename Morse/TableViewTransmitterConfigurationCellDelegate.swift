//
//  TableViewTransmitterConfigurationCellDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 1/11/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import Foundation

@objc protocol TableViewTransmitterConfigurationCellDelegate: UITextFieldDelegate {
	@objc optional func transConfigCell(_ cell:TableViewTransmitterConfigurationCell, minusButtonTapped button:UIButton)
	@objc optional func transConfigCell(_ cell:TableViewTransmitterConfigurationCell, plusButtonTapped button:UIButton)
	@objc optional func transConfigCell(_ cell:TableViewTransmitterConfigurationCell, sliderValueChanged slider:UISlider)
}
