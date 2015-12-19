//
//  OutputViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/18/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class OutputViewController: UIViewController {

	var statusBarView:UIView!
	var topBarView:UIView!
	var progressBarView:UIView!
	var doneButton:UIButton!
	var percentageLabel:UILabel!
	var soundToggleButton:UIButton!
	var flashToggleButton:UIButton!
	var morseTextBackgroundView:UIView!
	var morseTextLabel:UILabel!
	var screenFlashView:UIView!

	var morse:String = ""
	private var playing = false
	private var soundEnabled = appDelegate.soundOutputEnabled
	private var flashEnabled = appDelegate.flashOutputEnabled

	private var morseTextLabelHeight:CGFloat {
		// Calculate the height required to draw the morse code.
		return ceil(getAttributedStringFrom("• —", withFontSize: morseFontSizeProgressBar, color: UIColor.blackColor(), bold: false)!.size().height) + 2 // + 2 to be safe
	}
	private let doneButtonWidth:CGFloat = 100
	private var controlButtonWidth = topBarHeight

    override func viewDidLoad() {
        super.viewDidLoad()

		if self.statusBarView == nil {
			self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: statusBarHeight))
			self.statusBarView.backgroundColor = theme.statusBarBackgroundColor
			self.view.addSubview(self.statusBarView)
			self.statusBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(statusBarHeight)
			})
		}

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: self.view.bounds.width, height: topBarHeight))
			self.topBarView.backgroundColor = theme.topBarBackgroundColor
			self.view.addSubview(self.topBarView)
			self.topBarView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.statusBarView.snp_bottom)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(topBarHeight)
			})

			if self.progressBarView == nil {
				self.progressBarView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: topBarHeight))
				self.progressBarView.backgroundColor = theme.progressBarColor
				self.topBarView.addSubview(self.progressBarView)
				self.progressBarView.snp_remakeConstraints(closure: { (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
					make.width.equalTo(0)
				})
			}

			if self.doneButton == nil {
				self.doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.doneButtonWidth, height: topBarHeight))
				self.doneButton.backgroundColor = UIColor.clearColor()
				self.doneButton.tintColor = theme.topBarLabelTextColor
				self.doneButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
				self.doneButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
				self.doneButton.setTitle(LocalizedStrings.Button.done, forState: .Normal)
				self.doneButton.addTarget(self, action: "doneButtonTapped", forControlEvents: .TouchUpInside)
				self.topBarView.addSubview(self.doneButton)
				self.doneButton.snp_remakeConstraints { (make) -> Void in
					make.top .equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
					make.width.equalTo(self.doneButtonWidth)
				}
			}

			if self.soundToggleButton == nil {
				self.soundToggleButton = UIButton(frame: CGRect(x: 0, y: self.view.bounds.width - self.controlButtonWidth, width: self.controlButtonWidth, height: topBarHeight))
				self.soundToggleButton.backgroundColor = UIColor.clearColor()
				self.soundToggleButton.tintColor = theme.topBarLabelTextColor
				self.soundToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
				self.soundToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
				self.soundToggleButton.setTitle("SOUND", forState: .Normal) // TODO: Use custom image for this button
				self.soundToggleButton.addTarget(self, action: "soundToggleButtonTapped", forControlEvents: .TouchUpInside)
				self.topBarView.addSubview(self.soundToggleButton)
				self.soundToggleButton.snp_remakeConstraints { (make) -> Void in
					make.top .equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.trailing.equalTo(self.topBarView)
					make.width.equalTo(self.controlButtonWidth)
				}
			}

			if self.flashToggleButton == nil {
				self.flashToggleButton = UIButton(frame: CGRect(x: 0, y: self.view.bounds.width - self.controlButtonWidth * 2, width: self.controlButtonWidth, height: topBarHeight))
				self.flashToggleButton.backgroundColor = UIColor.clearColor()
				self.flashToggleButton.tintColor = theme.topBarLabelTextColor
				self.flashToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonTextColor, forState: .Normal)
				self.flashToggleButton.setTitleColor(appDelegate.theme.cardBackViewButtonSelectedTextColor, forState: .Highlighted)
				self.flashToggleButton.setTitle("FLASH", forState: .Normal) // TODO: Use custom image for this button
				self.flashToggleButton.addTarget(self, action: "soundToggleButtonTapped", forControlEvents: .TouchUpInside)
				self.topBarView.addSubview(self.flashToggleButton)
				self.flashToggleButton.snp_remakeConstraints { (make) -> Void in
					make.top .equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.trailing.equalTo(self.soundToggleButton.snp_leading)
					make.width.equalTo(self.controlButtonWidth)
				}
			}
		}

		if self.morseTextBackgroundView == nil {
			self.morseTextBackgroundView = UIView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: self.morseTextLabelHeight))
			self.morseTextBackgroundView.backgroundColor = theme.topBarBackgroundColor
			self.view.addSubview(self.morseTextBackgroundView)
			self.morseTextBackgroundView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.left.equalTo(self.view)
				make.right.equalTo(self.view)
				make.height.equalTo(self.morseTextLabelHeight)
			})
		}

		if self.morseTextLabel == nil {
			self.morseTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.morseTextLabelHeight))
			self.morseTextLabel.backgroundColor = UIColor.clearColor()
			self.morseTextLabel.attributedText = getAttributedStringFrom(self.morse, withFontSize: morseFontSizeProgressBar, color: theme.morseTextProgressBarColor, bold: false)
			self.morseTextLabel.textAlignment = .Left
			self.morseTextBackgroundView.addSubview(self.morseTextLabel)
			self.morseTextLabel.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.morseTextBackgroundView)
				make.left.equalTo(self.morseTextBackgroundView)
				make.height.equalTo(self.morseTextLabelHeight)
				make.width.equalTo(self.morseTextLabel.attributedText!.size().width + 10) // +10 to be safe
			})
		}

		if self.screenFlashView == nil {
			self.screenFlashView = UIView(frame: CGRect(x: 0, y: statusBarHeight + topBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - statusBarHeight - topBarHeight))
			self.screenFlashView.backgroundColor = UIColor.blackColor()
			let tapGR = UITapGestureRecognizer(target: self, action: "screenFlashViewTapped")
			self.screenFlashView.addGestureRecognizer(tapGR)
			self.view.addSubview(self.screenFlashView)
			self.screenFlashView.snp_remakeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.morseTextLabel.snp_bottom)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.bottom.equalTo(self.view)
			})
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func doneButtonTapped() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func soundToggleButtonTapped() {
		// TODO: Button color and image change
		self.soundEnabled = !self.soundEnabled
		appDelegate.userDefaults.setBool(self.soundEnabled, forKey: userDefaultsKeySoundOutputEnabled)
		appDelegate.userDefaults.synchronize()
	}
    
	func flashToggleButtonTapped() {
		// TODO: Button color and image change
		self.flashEnabled = !self.flashEnabled
		appDelegate.userDefaults.setBool(self.soundEnabled, forKey: userDefaultsKeyFlashOutputEnabled)
		appDelegate.userDefaults.synchronize()
	}

	func screenFlashViewTapped() {

		self.playing = !self.playing
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
