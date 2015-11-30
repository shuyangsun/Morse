//
//  MCHomeViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import SnapKit

let TEXT_VIEW_HEIGHT:CGFloat = 140
let LINE_BREAK_HEIGHT:CGFloat = 1.0

class MCHomeViewController: UIViewController, UITextViewDelegate {

	// *****************************
	// MARK: Internal Properties
	// *****************************

	// *****************************
	// MARK: Private Properties
	// *****************************

	private var statusBarView:UIView!
	private var topBarView:UIView!
	private var hiddenLineView:UIView!
	private var inputTextView:UITextView!
	private var lineBreakView:UIView!
	private var outputTextView:UITextView!
	private var scrollView:UIScrollView!
	private var isDirectionEncode:Bool = true
	private let coder = MorseCoder()

	private var viewWidth:CGFloat {
		return self.view.bounds.width
	}

	private var viewHeight:CGFloat {
		return self.view.bounds.height - self.tabBarHeight
	}

	private var tabBarHeight:CGFloat {
		if let tabBarController = self.tabBarController {
			return tabBarController.tabBar.bounds.height
		} else {
			return 0
		}
	}

	private var statusBarHeight:CGFloat {
		return UIApplication.sharedApplication().statusBarFrame.size.height
	}

	private let topBarHeight:CGFloat = 56

	private var theme:Theme {
		if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
			return delegate.theme
		} else {
			return Theme.Default
		}
	}

	private var hintText:String {
		if self.isDirectionEncode {
			return "Encode text to Morse"
		} else {
			return "Decode Morse to Text"
		}
	}

	private var attributedHintText:NSMutableAttributedString {
		return NSMutableAttributedString(string: self.hintText, attributes:
			[NSFontAttributeName: UIFont.systemFontOfSize(16),
				NSForegroundColorAttributeName: UIColor(hex: 0x000, alpha: MDDarkTextHintAlpha)])
	}

	// *****************************
	// MARK: Public Functions
	// *****************************

    override func viewDidLoad() {
        super.viewDidLoad()

		// TODO: Custom tab bar item
		self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 0)
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if self.statusBarView == nil {
			self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.statusBarHeight))
			self.statusBarView.backgroundColor = self.theme.colorPalates.primary.P700
			self.view.addSubview(self.statusBarView)
			self.statusBarView.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view)
				make.left.equalTo(self.view)
				make.right.equalTo(self.view)
				make.height.equalTo(self.statusBarHeight)
			})
		}

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: self.statusBarHeight, width: self.view.bounds.width, height: self.topBarHeight))
			self.topBarView.backgroundColor = self.theme.primaryColor(withLevel: .Dark)
			self.view.addSubview(topBarView)
			let topBarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.topBarView.bounds.width, height: self.topBarHeight))
			topBarLabel.textAlignment = .Center
			topBarLabel.tintColor = UIColor.whiteColor()
			topBarLabel.attributedText = NSAttributedString(string: "Morse Coder", attributes:
				[NSFontAttributeName: UIFont.boldSystemFontOfSize(23),
					NSForegroundColorAttributeName: UIColor.whiteColor()])
			self.topBarView.addSubview(topBarLabel)

			self.topBarView.snp_makeConstraints(closure: { (make) -> Void in
				make.top.equalTo(self.view).offset(self.statusBarHeight)
				make.left.equalTo(self.view).offset(0)
				make.right.equalTo(self.view).offset(0)
				make.height.equalTo(self.topBarHeight)
			})
			topBarLabel.snp_makeConstraints(closure: { (make) -> Void in
				 make.edges.equalTo(self.topBarView).inset(UIEdgeInsetsMake(0, 0, 0, 0))
			})
		}

		if self.inputTextView == nil {
			self.inputTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.viewWidth, height: TEXT_VIEW_HEIGHT/2.0))
			self.inputTextView.backgroundColor = self.theme.colorPalates.primary.P50
			self.inputTextView.keyboardType = .ASCIICapable
			self.inputTextView.returnKeyType = .Done
			self.inputTextView.attributedText = self.attributedHintText
			self.inputTextView.delegate = self
			self.inputTextView.layer.borderColor = UIColor.clearColor().CGColor
			self.inputTextView.layer.borderWidth = 0
			self.inputTextView.layer.zPosition = 1
			self.view.addSubview(self.inputTextView)

			// Configure contraints
			self.inputTextView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.right.equalTo(self.view)
				make.left.equalTo(self.view)
				make.height.equalTo(TEXT_VIEW_HEIGHT/2.0)
			}
		}

		if self.hiddenLineView == nil {
			self.hiddenLineView = UIView(frame: CGRect(x: 0, y: TEXT_VIEW_HEIGHT/2.0 + self.statusBarHeight + self.topBarHeight - LINE_BREAK_HEIGHT, width: self.inputTextView.bounds.width, height: LINE_BREAK_HEIGHT))
			if let color = self.inputTextView.backgroundColor {
				self.hiddenLineView.backgroundColor = color
			}
			self.hiddenLineView.layer.zPosition = CGFloat.max - 1
			self.view.addSubview(self.hiddenLineView)

			self.hiddenLineView.snp_remakeConstraints(closure: { (make) -> Void in
				make.left.equalTo(self.inputTextView)
				make.right.equalTo(self.inputTextView)
				make.bottom.equalTo(self.inputTextView)
				make.height.equalTo(LINE_BREAK_HEIGHT)
			})
		}

		if self.outputTextView == nil {
			self.outputTextView = UITextView(frame: CGRect(x: 0, y: self.inputTextView.bounds.height + self.topBarHeight + self.statusBarHeight, width: self.viewWidth, height: TEXT_VIEW_HEIGHT/2.0))
			self.outputTextView.backgroundColor = self.theme.colorPalates.primary.P50
			self.outputTextView.editable = false
			self.outputTextView.layer.borderColor = UIColor.clearColor().CGColor
			self.outputTextView.layer.borderWidth = 0
			self.outputTextView.layer.zPosition = 1
			self.view.addSubview(self.outputTextView)

			// Configure contraints
			self.outputTextView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.inputTextView.snp_bottom)
				make.right.equalTo(self.view)
				make.left.equalTo(self.view)
				make.height.equalTo(TEXT_VIEW_HEIGHT/2.0)
			}
		}

		if self.inputTextView.isFirstResponder() {
			self.outputTextView.addMDShadow(withDepth: 2)
		} else {
			self.outputTextView.addMDShadow(withDepth: 1)
		}

		if self.scrollView == nil {
			self.scrollView = UIScrollView(frame: CGRect(x: 0, y: TEXT_VIEW_HEIGHT, width: self.viewWidth, height: self.viewHeight - TEXT_VIEW_HEIGHT))
			self.scrollView.backgroundColor = self.theme.colorPalates.primary.P50
			self.scrollView.layer.zPosition = 0
			self.view.addSubview(self.scrollView)

			self.scrollView.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self.outputTextView.snp_bottom)
				make.right.equalTo(self.view).offset(0)
				make.bottom.equalTo(self.view).offset(-self.tabBarHeight)
				make.left.equalTo(self.view).offset(0)
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// *****************************
	// MARK: Text View Delegate
	// *****************************
	func textViewDidBeginEditing(textView: UITextView) {

		self.inputTextView.attributedText = self.getAttributedStringFrom(" ")

		if self.lineBreakView == nil {
			self.lineBreakView = UIView(frame: CGRect(x: 0, y: TEXT_VIEW_HEIGHT + self.statusBarHeight + self.topBarHeight - LINE_BREAK_HEIGHT, width: textView.bounds.width, height: LINE_BREAK_HEIGHT))
			self.lineBreakView.backgroundColor = UIColor(hex: 0x000, alpha: 0.1)
			self.lineBreakView.layer.zPosition = CGFloat.max
			self.view.addSubview(self.lineBreakView)
		}

		self.lineBreakView.hidden = false
		self.inputTextView.layer.zPosition = 1
		self.outputTextView.layer.zPosition = 1
		self.lineBreakView.snp_remakeConstraints(closure: { (make) -> Void in
			make.left.equalTo(self.outputTextView)
			make.right.equalTo(self.outputTextView)
			make.bottom.equalTo(self.inputTextView)
			make.height.equalTo(LINE_BREAK_HEIGHT)
		})

		UIView.animateWithDuration(0.15,
			delay: 0.0,
			options: .CurveLinear,
			animations: { () -> Void in
				self.view.layoutIfNeeded()
			}) { (succeed) -> Void in
		}
	}

	func textViewDidChange(textView: UITextView) {
		self.coder.text = textView.text
		let outputText = self.coder.morse
		self.outputTextView.attributedText = self.getAttributedStringFrom(outputText)
		if outputText != nil {
			self.outputTextView.scrollRangeToVisible(NSMakeRange(outputText!.startIndex.distanceTo(outputText!.endIndex), 0))
		}
	}

	func textViewDidEndEditing(textView: UITextView) {
		self.outputTextView.text = nil
		textView.attributedText = self.attributedHintText
		self.lineBreakView.snp_remakeConstraints(closure: { (make) -> Void in
			make.left.equalTo(textView)
			make.right.equalTo(textView)
			make.bottom.equalTo(self.outputTextView)
			make.height.equalTo(LINE_BREAK_HEIGHT)
		})
		UIView.animateWithDuration(0.15,
			delay: 0.0,
			options: .CurveLinear,
			animations: { () -> Void in
				self.view.layoutIfNeeded()
			}) { (succeed) -> Void in
				if succeed {
					self.lineBreakView.hidden = true
				}
		}
	}

	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
		}
		return true
	}

	// *****************************
	// MARK: Private Functions
	// *****************************

	private func getAttributedStringFrom(text:String?) -> NSMutableAttributedString? {
		return text == nil ? nil : NSMutableAttributedString(string: text!, attributes:
			[NSFontAttributeName: UIFont.systemFontOfSize(16),
				NSForegroundColorAttributeName: UIColor(hex: 0x000, alpha: MDDarkTextPrimaryAlpha)])
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
