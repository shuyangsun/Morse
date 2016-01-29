//
//  Theme.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

var theme:Theme {
	get {
		return appDelegate.theme
	}
	set {
		appDelegate.theme = newValue
	}
}

enum ThemeStyle {
	case Light
	case Dark
}

enum Theme: Int {
	static let numberOfThemes = 4

	case Default = 0
	case Night = 1
	case Forest = 2
	case Industrial = 3

	// General information about theme
	var name:String {
		switch self {
		case .Default: return LocalizedStrings.ThemeName.defaultName
		case .Night: return LocalizedStrings.ThemeName.night
		case .Forest: return LocalizedStrings.ThemeName.forest
		case .Industrial: return LocalizedStrings.ThemeName.industrial
		}
	}

	var style:ThemeStyle {
		switch self {
		case .Night: return .Dark
		case .Industrial: return .Dark
		default: return .Light
		}
	}

	// Color pallete
	var darkPrimaryColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P700
		case .Night: return MDColorPalette.Grey.P900
		case .Forest: return MDColorPalette.Green.P700
		case .Industrial: return MDColorPalette.BlueGrey.P700
		}
	}

	var primaryColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P500
		case .Night: return MDColorPalette.Grey.P800
		case .Forest: return MDColorPalette.Green.P500
		case .Industrial: return MDColorPalette.BlueGrey.P500
		}
	}

	var lightPrimaryColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.Blue.P300
		case .Night: return MDColorPalette.Grey.P500
		case .Forest: return MDColorPalette.Green.P300
		case .Industrial: return MDColorPalette.BlueGrey.P400
		}
	}

	var accentColor:UIColor {
		switch self {
		case .Default: return MDColorPalette.LightGreen.P500
		case .Night: return MDColorPalette.Blue.A400!
		case .Forest: return MDColorPalette.Lime.A200!
		case .Industrial: return MDColorPalette.Cyan.A700!
		}
	}

	var lightAccentColor: UIColor {
		switch self {
		case .Default: return MDColorPalette.LightGreen.P200
		case .Night: return MDColorPalette.Blue.A100!
		case .Forest: return MDColorPalette.Lime.A100!
		case .Industrial: return MDColorPalette.Cyan.A400!
		}
	}

	var primaryTextColor:UIColor {
		switch self.style {
		case .Light: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		case .Dark: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var secondaryTextColor:UIColor {
		switch self.style {
		case .Light: return UIColor(hex: 0x000, alpha: MDDarkTextSecondaryAlpha)
		case .Dark: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var hintTextColor:UIColor {
		switch self.style {
		case .Light: return UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)
		case .Dark: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	// Some iOS UI Styles about theme
	var keyboardAppearance:UIKeyboardAppearance {
		switch self.style {
		case .Light: return .Default
		case .Dark: return .Dark
		}
	}

	var scrollViewIndicatorStyle: UIScrollViewIndicatorStyle {
		switch self.style {
		case .Light: return .Default
		case .Dark: return .White
		}
	}

	// *****************************
	// MARK: Colors
	// *****************************

	// **************************************************************************************************

	var scrollViewBackgroundColor:UIColor {
		switch self {
		case .Night: return MDColorPalette.Grey.P900
		case .Forest: return self.lightPrimaryColor
		case .Industrial: return self.lightPrimaryColor
		default: return UIColor(hex: 0xEEEEEE)
		}
	}

	var textViewBackgroundColor:UIColor {
		switch self {
		case .Night: return MDColorPalette.Grey.P700
		case .Forest: return MDColorPalette.Green.P100
		case .Industrial: return self.lightPrimaryColor
		default: return UIColor.whiteColor()
		}
	}

	var cardViewBackgroudColor:UIColor {
		switch self {
		case .Default: return UIColor.whiteColor()
		case .Night: return MDColorPalette.Grey.P800
		case .Forest: return MDColorPalette.Green.P600
		case .Industrial: return self.primaryColor
		}
	}

	var cardViewExpandButtonColor:UIColor {
		switch self {
		case .Industrial: return self.lightPrimaryColor
		default: return self.lightPrimaryColor
		}
	}

	var cardViewTextColor:UIColor {
		switch self {
		case .Forest: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		default: return self.primaryTextColor
		}
	}

	var cardViewMorseColor:UIColor {
		switch self {
		case .Forest: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		default: return self.secondaryTextColor
		}
	}

	var audioPlotPitchFilteredColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: MDColorPalette.Blue.A400!.hex, alpha: 0.8)
		default: return UIColor(hex: self.primaryColor.hex, alpha: 0.8)
		}
	}

	var cellImageTintColor:UIColor {
		switch self {
		case.Forest: return self.lightAccentColor
		case.Industrial: return MDColorPalette.BlueGrey.P100
		default: return self.lightPrimaryColor
		}
	}

	var buttonWithAccentBackgroundTintColor:UIColor {
		switch self {
		case.Forest: return self.primaryColor
		default: return UIColor.whiteColor()
		}
	}

	// **************************************************************************************************

	private var defaultTapFeedbackColorDark:UIColor {
		return UIColor(hex: 0x000000, alpha: 0.2)
	}

	private var defaultTapFeedbackColorLight:UIColor {
		return UIColor(hex: 0xFFFFFF, alpha: 0.3)
	}

	var statusBarBackgroundColor:UIColor {
		switch self {
		default: return self.darkPrimaryColor
		}
	}

	var topBarBackgroundColor:UIColor {
		switch self {
		default: return self.primaryColor
		}
	}

	var topBarLabelTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var textViewBreakLineColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: 0.1)
		default: return UIColor(hex: 0x000, alpha: 0.1)
		}
	}

	var textViewTapFeedbackColor:UIColor {
		switch self {
		default: return self.lightAccentColor
		}
	}

	var textViewHintTextColor:UIColor {
		switch self {
		default: return self.hintTextColor
		}
	}

	var textViewInputTextColor:UIColor {
		switch self {
		default: return self.primaryTextColor
		}
	}

	var textViewOutputTextColor:UIColor {
		switch self {
		default: return self.textViewInputTextColor
		}
	}

	var buttonImageTintColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}

	var roundButtonBackgroundColor:UIColor? {
		switch self {
		case .Night: return nil
		default: return self.accentColor
		}
	}

	var roundButtonTapFeedbackColor:UIColor {
		switch self {
		default: return self.lightAccentColor
		}
	}

	var keyboardButtonBackgroundColor:UIColor {
		switch self {
		default: return UIColor.clearColor()
		}
	}

	var keyboardButtonTintColor:UIColor {
		switch self {
		case .Default: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		case .Forest: return UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)
		case .Industrial: return self.lightAccentColor
		}
	}

	var keyboardButtonTapFeedbackColor:UIColor {
		switch self {
		default: return self.lightAccentColor
		}
	}

	var scrollViewOverlayColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0x000, alpha: 0.8)
		default: return UIColor(hex: 0x000, alpha: 0.35)
		}
	}

	var cardViewProsignBackgroudColor:UIColor {
		switch self {
		default: return self.cardViewBackgroudColor
		}
	}

	var cardViewProsignEmergencyBackgroundColor:UIColor {
		switch self {
		default: return MDColorPalette.Red.P500
		}
	}

	var cardViewExpandedBackgroudColor:UIColor {
		switch self {
		default: return self.cardViewBackgroudColor
		}
	}

	var cardViewTapfeedbackColor:UIColor {
		switch self {
		default: return self.lightAccentColor
		}
	}

	var cardViewProsignTextColor:UIColor {
		switch self {
		default: return self.cardViewTextColor
		}
	}

	var cardViewProsignMorseColor:UIColor {
		switch self {
		default: return self.cardViewMorseColor
		}
	}

	var cardViewProsignEmergencyTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var cardViewProsignEmergencyMorseColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var cardBackViewBackgroundColor:UIColor {
		switch self {
		default: return self.accentColor
		}
	}

	var cardViewBorderColor:UIColor {
		switch self {
		case .Industrial: return self.darkPrimaryColor
		default: return UIColor.clearColor()
		}
	}

	// Output VC
	var outputVCTopBarColor:UIColor {
		switch self {
		default: return UIColor.blackColor()
		}
	}

	var progressBarColor:UIColor {
		switch self {
		default: return self.primaryColor
		}
	}

	var percentageTextColor:UIColor {
		switch self {
		case .Night: return MDColorPalette.Grey.P400
		default: return self.topBarLabelTextColor
		}
	}

	var morseTextProgressBarColor:UIColor {
		switch self {
		default: return self.percentageTextColor
		}
	}

	var outputVCButtonTintColor:UIColor {
		switch self {
		default: return UIColor.whiteColor()
		}
	}

	var outputVCLabelTextColorEmphasized:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var outputVCLabelTextColorNormal:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	var waveformVCLabelTextColorEmphasized:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		}
	}

	var waveformVCLabelTextColorNormal:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	// Tab bar VC
	var tabBarBackgroundColor:UIColor {
		switch self {
		case .Forest: return self.primaryColor
		default: return self.scrollViewBackgroundColor
		}
	}

	var tabBarSelectedTintColor:UIColor {
		switch self {
		case .Industrial: return self.lightAccentColor
		default: return self.accentColor
		}
	}

	var tabBarUnselectedTintColor:UIColor {
		switch self {
		case .Industrial: return self.accentColor
		default: return self.lightAccentColor
		}
	}

	var navigationBarBackgroundColor:UIColor {
		switch self {
		default: return self.primaryColor
		}
	}

	var navigationBarTitleTextColor:UIColor {
		switch self {
		default: return self.topBarLabelTextColor
		}
	}

	var tableViewCellBackgroundColor:UIColor {
		switch self {
		case .Night: return MDColorPalette.Grey.P800
		case .Forest: return self.cardViewBackgroudColor
		case .Industrial: return self.cardViewBackgroudColor
		default: return UIColor.whiteColor()
		}
	}

	var tableViewCellSelectedBackgroundColor:UIColor {
		switch self {
//		case .Default: return MDColorPalette.Blue.P300
//		case .Night: return MDColorPalette.Blue.A200!
		default: return self.tableViewCellBackgroundColor
		}
	}

	var tableViewBackgroundColor:UIColor {
		switch self {
		default: return self.scrollViewBackgroundColor
		}
	}

	var tableViewSeparatorColor:UIColor? {
		switch self {
		case .Night: return MDColorPalette.Grey.P600
		case .Industrial: return self.cardViewBorderColor
		default: return nil
		}
	}

	var cellTitleTextColor:UIColor {
		switch self {
		case .Forest: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		default: return self.primaryTextColor
		}
	}

	var cellTitleTextSelectedColor:UIColor {
		switch self {
		default: return self.cellTitleTextColor
		}
	}

	var cellDetailTitleTextColor:UIColor {
		switch self {
		case .Forest: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextSecondaryAlpha)
		default: return self.hintTextColor
		}
	}

	var cellDetailTitleTextSelectedColor:UIColor {
		switch self {
		default: return self.cellDetailTitleTextColor
		}
	}

	var tableViewCellCheckmarkColor:UIColor {
		switch self {
		default: return self.accentColor
		}
	}

	var cellTapFeedBackColor:UIColor {
		switch self {
		default: return self.lightAccentColor
		}
	}

	var tableViewHeaderTextColor:UIColor {
		switch self {
		default: return self.secondaryTextColor
		}
	}

	var tableViewFooterTextColor:UIColor {
		switch self {
		case .Industrial: return self.secondaryTextColor
		default: return self.hintTextColor
		}
	}

	var tableViewFooterUpgradesTextColor:UIColor {
		switch self {
		default: return MDColorPalette.Red.P300
		}
	}

	var sliderMinTrackTintColor:UIColor? {
		switch self {
		default: return self.accentColor
		}
	}

	var sliderMaxTrackTintColor:UIColor? {
		switch self {
		default: return nil
		}
	}

	var sliderThumbTintColor:UIColor? {
		switch self {
		default: return self.accentColor
		}
	}

	var switchOnTintColor:UIColor? {
		switch self {
		default: return self.accentColor
		}
	}

	// Audio VC

	var audioPlotBackgroundColor:UIColor {
		switch self {
		default: return UIColor(hex: 0x000, alpha: 0.8)
		}
	}

	var audioPlotColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: 0.5)
		}
	}

	var scrollViewBlurTintColor:UIColor {
		switch self {
		case .Night: return UIColor(hex: 0xFFFFFF, alpha: 0.2)
		default: return UIColor(hex: 0x000, alpha: 0.2)
		}
	}

	var transValConfigViewPlusMinusButtonTintColorNormal:UIColor {
		switch self {
		default: return self.accentColor
		}
	}

	var transValConfigViewNumPadDoneButtonBackgroundColor:UIColor {
		switch self {
		default: return self.accentColor
		}
	}

	var transValConfigViewNumPadDoneButtonTextColorNormal:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var transValConfigViewNumPadDoneButtonTextColorHighlighted:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextHintAlpha)
		}
	}

	var mdAlertControllerBackgroundColor:UIColor {
		switch self.style {
		default: return UIColor(hex: 0x000, alpha: 0.65)
		}
	}

	var mdAlertControllerAlertBackgroundColor:UIColor {
		switch self {
		case .Forest: return self.lightPrimaryColor
		default: return self.cardViewBackgroudColor
		}
	}

	var mdAlertControllerTitleTextColor:UIColor {
		switch self.style {
		default: return self.primaryTextColor
		}
	}

	var mdAlertControllerMessageTextColor:UIColor {
		switch self.style {
		default: return self.secondaryTextColor
		}
	}

	var mdAlertControllerButtonTextColorNormal:UIColor {
		switch self {
		case .Night: return MDColorPalette.Blue.A100!
		default: return self.accentColor
		}
	}

	var mdAlertControllerButtonTextColorHighlighted:UIColor {
		switch self {
		case .Night: return MDColorPalette.Blue.A100!
		default: return self.lightAccentColor
		}
	}

	var mdAlertControllerButtonTapFeedbackColor:UIColor {
		switch self {
		default: return self.lightAccentColor
		}
	}

	// *****************************
	// MARK: Numbers
	// *****************************

	var cardViewHorizontalMargin:CGFloat {
		switch self {
		case .Industrial: return 0
		default: return isPhone ? 16 : 32
		}
	}

	var cardViewGroupVerticalMargin:CGFloat {
		switch self {
		case .Industrial: return 0
		default: return cardViewHorizontalMargin
		}
	}

	var cardViewGap:CGFloat {
		switch self {
		case .Industrial: return 0
		default: return isPhone ? 16 : 8
		}
	}

	var cardViewHeight:CGFloat {
		switch self {
		default: return 86
		}
	}

	var cardViewBorderWidth:CGFloat {
		switch self {
		case .Industrial: return 1
		default: return 0
		}
	}

	var cardViewCornerRadius:CGFloat {
		switch self {
		case .Forest: return 15
		case .Industrial: return 0
		default: return 2
		}
	}

	var scrollViewBlurRadius:CGFloat {
		switch self {
		default: return 15
		}
	}

	var mdAlertControllerAlertCornerRadius:CGFloat {
		switch self {
		default: return self.cardViewCornerRadius
		}
	}

	// *****************************
	// MARK: Shadows
	// *****************************

	var cardViewMDShadowLevelDefault:Int {
		switch self {
		case .Industrial: return 0
		default: return 1
		}
	}

	var roundButtonMDShadowLevelDefault:Int {
		switch self {
		case .Default: return 1
		default: return 0
		}
	}

	var roundButtonMDShadowLevelTapped:Int {
		switch self {
		case .Default: return 2
		default: return 0
		}
	}

	// *****************************
	// MARK: Things Don't Really Change
	// *****************************

	var resetCellBackgroundColor:UIColor {
		switch self {
		default: return MDColorPalette.Red.P300
		}
	}

	var resetCellTapFeedbackColor:UIColor {
		switch self {
		default: return MDColorPalette.Red.P200
		}
	}

	var resetCellTextColor:UIColor {
		switch self {
		default: return UIColor(hex: 0xFFFFFF, alpha: MDLightTextPrimaryAlpha)
		}
	}

	var transConfigHeaderLabelTextColor:UIColor {
		switch self {
		default: return self.tableViewHeaderTextColor
		}
	}

	var transConfigLabelTextColorEmphasized:UIColor {
		switch self {
		default: return self.cellTitleTextColor
		}
	}

	var transConfigLabelTextColorNormal:UIColor {
		switch self {
		default: return self.cellDetailTitleTextColor
		}
	}

	var transValConfigViewPlusMinusButtonTintColorHighlighted:UIColor {
		switch self {
		default: return UIColor(hex: self.transValConfigViewPlusMinusButtonTintColorNormal.hex, alpha: 0.5)
		}
	}

	// *****************************
	// MARK: Image Names

	var backButtonImageName:String {
		switch self.style {
		default: return layoutDirection == .LeftToRight ? "Back LeftToRight" : "Back RightToLeft"
		}
	}

	var microphoneIconImageName:String {
		switch self.style {
		default: return "Microphone Button Dark"
		}
	}

	var keyboardIconImageName:String {
		switch self.style {
		default: return "Keyboard Button Dark"
		}
	}

	var outputImageName:String {
		switch self.style {
		default: return "Output"
		}
	}

	var shareImageName:String {
		switch self.style {
		default: return "Share"
		}
	}

	var outputPlayButtonImageName:String {
		switch self {
		default: return "Output VC Play"
		}
	}

	var flashOnImageName:String {
		switch self.style {
		default: return "Flash On"
		}
	}

	var flashOffImageName:String {
		switch self.style {
		default: return "Flash Off"
		}
	}

	var soundOnImageName:String {
		switch self.style {
		default: return "Sound On"
		}
	}

	var soundOffImageName:String {
		switch self.style {
		default: return "Sound Off"
		}
	}

	var tabBarItemHomeUnselectedImageName:String {
		switch self.style {
		default: return "Home Dark Unselected"
		}
	}

	var tabBarItemDictionaryUnselectedImageName:String {
		switch self.style {
		default: return "Dictionary Dark Unselected"
		}
	}

	var tabBarItemSettingsUnselectedImageName:String {
		switch self.style {
		default: return "Settings Dark Unselected"
		}
	}

	var settingsLanguageImageName:String {
		switch self.style {
		default: return "Settings Language"
		}
	}

	var settingsShareExtraTextImageName:String {
		switch self.style {
		default: return "Settings Share Extra Text"
		}
	}

	var settingsThemeImageName:String {
		switch self.style {
		default: return "Settings Theme"
		}
	}

	var settingsAutoNightModeImageName:String {
		switch self.style {
		default: return "Settings Auto Night Mode"
		}
	}

	var settingsSignalOutputImageName:String {
		switch self.style {
		default: return "Settings Singal Output"
		}
	}

	var settingsAudioDecoderImageName:String {
		switch self.style {
		default: return "Settings Audio Decoder"
		}
	}

	var settingsDecodeProsignImageName:String {
		switch self.style {
		default: return "Settings Decode Prosign"
		}
	}

	var settingsPurchaseUnlimitedCardSlotsImageName:String {
		switch self.style {
		default: return "Settings Purchase Unlimited Card Slots"
		}
	}

	var settingsPurchaseThemesImageName:String {
		switch self.style {
		default: return "Settings Purchase Themes"
		}
	}

	var settingsPurchaseAudioDecoderImageName:String {
		switch self.style {
		default: return "Settings Purchase Audio Decoder"
		}
	}

	var settingsRestorePurchasesImageName:String {
		switch self.style {
		default: return "Settings Restore Purchases"
		}
	}

	var settingsTellFriendsImageName:String {
		switch self.style {
		default: return "Settings Tell Friends"
		}
	}

	var settingsRateOnAppStoreImageName:String {
		switch self.style {
		default: return "Settings Rate On App Store"
		}
	}

	var settingsContactDeveloperImageName:String {
		switch self.style {
		default: return "Settings Contact Developer"
		}
	}

	var settingsPrivacyPolicyImageName:String {
		switch self.style {
		default: return "Settings Privacy Policy"
		}
	}

	var settingsClearCardsImageName:String {
		switch self.style {
		default: return "Settings Clear Cards"
		}
	}

	var settingsAddTutorialCardsImageName:String {
		switch self.style {
		default: return "Settings Add Tutorial Cards"
		}
	}

	var settingsRestoreAlertsImageName:String {
		switch self.style {
		default: return "Settings Restore Alerts"
		}
	}

	var cardViewExpandButtonImageName:String {
		switch self.style {
		default: return "Card View Expand Button"
		}
	}
}