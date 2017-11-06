//
//  MDAlertController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/14/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

/** A class that is similar with UIAlertController, but the presentation style is using Material Design. */
class MDAlertController: UIViewController {

	var alertView:UIView!
	var titleLabel:UILabel!
	var messageLabel:UILabel!
	var snapshot:UIView? {
		willSet {
			if newValue != nil {
				self.view.insertSubview(newValue!, at: 0)
			}
            newValue?.snp_makeConstraints({ (make) -> Void in
				make.edges.equalTo(self.view)
			})
		}
	}
	var backgroundView:UIView!
	var buttonOutlineView:UIView! {
		didSet {
			for tuple in self._actionsAndButtons {
				let button = tuple.button
				self.buttonOutlineView.addSubview(button)
			}
			self.updateButtonConstraints()
		}
	}
	fileprivate var _alertTitle:String?
	fileprivate var _alertMessage:String?
	fileprivate var _actionsAndButtons:[(action:MDAlertAction, button:UIButton)] = []
	fileprivate var _didAddCustomAction = false

	func setup() {
		self.view.backgroundColor = UIColor.clear
		if self.backgroundView == nil {
			self.backgroundView = UIView(frame: self.view.bounds)
			self.backgroundView.backgroundColor = theme.mdAlertControllerBackgroundColor
			self.view.addSubview(self.backgroundView)
            self.backgroundView.snp_makeConstraints({ (make) -> Void in
				make.edges.equalTo(self.view)
			})
		}
		
		if self.alertView == nil {
			self.alertView = UIView()
			self.alertView.backgroundColor = theme.mdAlertControllerAlertBackgroundColor
			self.alertView.layer.cornerRadius = theme.mdAlertControllerAlertCornerRadius
			self.alertView.clipsToBounds = false
			self.view.addSubview(alertView)
		}

		let titleAttrText = getAttributedStringFrom(self._alertTitle, withFontSize: mdAlertTitleFontSize, color: theme.mdAlertControllerTitleTextColor, bold: true)
		var titleStrSize = titleAttrText!.boundingRect(with: CGSize(width: 9999, height: 9999), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
		titleStrSize = CGRect(x: titleStrSize.origin.x, y: titleStrSize.origin.y, width: titleStrSize.width, height: titleStrSize.height + 5)
		if self.titleLabel == nil {
			self.titleLabel = UILabel()
			self.titleLabel.textColor = theme.mdAlertControllerTitleTextColor
			self.titleLabel.attributedText = titleAttrText
			self.alertView.addSubview(self.titleLabel)
            self.titleLabel.snp_makeConstraints({ (make) -> Void in
				make.leading.equalTo(self.alertView).offset(mdAlertPaddingHorizontal)
				make.trailing.equalTo(self.alertView).offset(-mdAlertPaddingHorizontal)
				make.top.equalTo(self.alertView).offset(mdAlertPaddingVertical * 1.5)
			})
		}

		let alertWidth = min(self.view.bounds.width - mdAlertMarginHorizontal * 2, mdAlertMaxWidth)
		let messageAttrText = getAttributedStringFrom(self._alertMessage, withFontSize: mdAlertMessageFontSize, color: theme.mdAlertControllerMessageTextColor, bold: false)
		var messageStrSize = messageAttrText!.boundingRect(with: CGSize(width: alertWidth - mdAlertPaddingHorizontal * 2, height: 10000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
		let height = min(messageStrSize.height + 5, self.view.bounds.height - 2 * mdAlertMarginVertical - mdAlertButtonHeight - mdAlertPaddingVertical * 3 - titleStrSize.height)
		messageStrSize = CGRect(x: messageStrSize.origin.x, y: messageStrSize.origin.y, width: messageStrSize.width, height: height)
		if self.messageLabel == nil {
			self.messageLabel = UILabel()
			self.messageLabel.numberOfLines = 9999
			self.messageLabel.textColor = theme.mdAlertControllerMessageTextColor
			self.messageLabel.attributedText = messageAttrText
			self.alertView.addSubview(self.messageLabel)
            self.messageLabel.snp_makeConstraints({ (make) -> Void in
				make.leading.equalTo(self.alertView).offset(mdAlertPaddingHorizontal)
				make.trailing.equalTo(self.alertView).offset(-mdAlertPaddingHorizontal)
				make.centerY.equalTo(self.alertView)
				make.height.equalTo(messageStrSize.height)
			})
		}

		if self.buttonOutlineView == nil {
			self.buttonOutlineView = UIView()
			self.buttonOutlineView.backgroundColor = UIColor.clear
			self.buttonOutlineView.layer.cornerRadius = theme.mdAlertControllerAlertCornerRadius
			self.buttonOutlineView.clipsToBounds = true
			self.alertView.addSubview(self.buttonOutlineView)
            self.buttonOutlineView.snp_makeConstraints({ (make) -> Void in
				make.leading.equalTo(self.alertView)
				make.trailing.equalTo(self.alertView)
				make.bottom.equalTo(self.alertView)
				make.height.equalTo(mdAlertButtonHeight)
			})
		}

		let alertHeight = min(self.view.bounds.height, max(mdAlertMinHeight, mdAlertButtonHeight + mdAlertPaddingVertical * 3 + messageStrSize.height + titleStrSize.height))
        self.alertView.snp_makeConstraints({ (make) -> Void in
			make.center.equalTo(self.view)
			make.width.equalTo(alertWidth)
			make.height.equalTo(alertHeight)
		})

        NotificationCenter.default.addObserver(self, selector: #selector(updateColorWithAnimation), name: NSNotification.Name(rawValue: themeDidChangeNotificationName), object: nil)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setup()
    }

	override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.alertView.addMDShadow(withDepth: 5)
	}

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return theme.style == .dark ? .lightContent : .default
	}

	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		if isPad {
			return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscape]
		} else {
			return UIInterfaceOrientationMask.portrait
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	/**
	Initialize a MDAlertController with title and message. If you don't add any action (customized button) to it, there will be an "OK" button by default, which does nothing but dismiss this alert view controller.
	- Parameters:
		- title: The title of alert view.
		- message: The message body of alert view.
	*/
	convenience init(title: String?, message: String?) {
		self.init()
		self._alertTitle = title
		self._alertMessage = message
		let actionOK = MDAlertAction(title: LocalizedStrings.Alert.buttonOK)
		self.addAction(actionOK)
		self._didAddCustomAction = false
		self.modalPresentationStyle = .custom
		self.transitioningDelegate = UIApplication.shared.windows[0].rootViewController as! TabBarController
	}

	/**
	Add an alert action (button) to this controller. Adding any button will automatically remove the default "OK" button.
	- Parameters:
		- action: An action specifying the title, handler of the button.
	*/
	func addAction(_ actions:MDAlertAction...) {
		for action in actions {
			if !self._didAddCustomAction {
				// If the user hasn't add any custom action, remove the default "OK" action
				if !self._actionsAndButtons.isEmpty {
					self._actionsAndButtons.first?.button.removeFromSuperview()
					self._actionsAndButtons.removeFirst()
				}
			}
			let button = UIButton()
			button.setAttributedTitle(getAttributedStringFrom(action.title.uppercased(), withFontSize: mdAlertButtonFontSize, color: theme.mdAlertControllerButtonTextColorNormal, bold: true), for: UIControlState())
			button.setAttributedTitle(getAttributedStringFrom(action.title.uppercased(), withFontSize: mdAlertButtonFontSize, color: theme.mdAlertControllerButtonTextColorHighlighted, bold: true), for: .highlighted)
			button.addTarget(self, action: #selector(MDAlertController.buttonTapped(_:)), for: .touchUpInside)
			self._actionsAndButtons.append((action, button))
			if self.buttonOutlineView != nil {
				self.buttonOutlineView.addSubview(button)
				self.updateButtonConstraints()
			}
			self._didAddCustomAction = true
		}
	}

	fileprivate func updateButtonConstraints() {
		let count = self._actionsAndButtons.count
		for i in 0 ..< count {
			let tuple = self._actionsAndButtons[i]
			let button = tuple.button
            button.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.buttonOutlineView)
				make.bottom.equalTo(self.buttonOutlineView)
				if i == 0 {
					make.trailing.equalTo(self.buttonOutlineView).offset(-mdAlertPaddingHorizontal)
				} else {
					let lastButton = self._actionsAndButtons[i - 1].button
					make.trailing.equalTo(lastButton.snp_leading).offset(-mdAlertPaddingHorizontal * 1.5)
				}
			})
		}
	}

	func buttonTapped(_ button:UIButton) {
		let centerPoint = CGPoint(x: button.bounds.width/2.0, y: button.bounds.height/2.0)
		let convertedPoint = self.alertView.convert(centerPoint, from: button)
		self.alertView.triggerTapFeedBack(atLocation: convertedPoint, withColor: theme.mdAlertControllerButtonTapFeedbackColor, atBottom:false, scaleDuration: true) {
			var actionClosure:((MDAlertAction) -> Void)? = nil
			var action:MDAlertAction? = nil
			for tuple in self._actionsAndButtons {
				if tuple.button === button {
					action = tuple.action
					actionClosure = action?.actionHandler
					break
				}
			}
			if action != nil {
				if action!.dismissAlertView {
					self.dismiss(animated: true) {
						actionClosure?(action!)
					}
				} else {
					actionClosure?(action!)
				}
			}
		}
	}

	/**
	Present this alert view controller. The presenting controller will be the root controller, so the alert view controller will always show at the top of view controller hierarchy.
	*/
	func show() {
		(UIApplication.shared.windows[0].rootViewController! as! TabBarController).present(self, animated: true, completion: nil)
	}

	func rotationDidChange() {
		self.snapshot?.removeFromSuperview()
		self.snapshot = self.presentingViewController?.view.snapshotView(afterScreenUpdates: false)
		self.view.insertSubview(self.snapshot!, at: 0)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	/**
	Responsible for updating the UI when user changes the theme.
	- Parameters:
		- animated: A boolean determines if the theme change should be animated.
	*/
	func updateColor(animated:Bool = true) {
		self.snapshot?.removeFromSuperview()
		self.snapshot = self.presentingViewController?.view.snapshotView(afterScreenUpdates: true)
		self.view.insertSubview(self.snapshot!, at: 0)

		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animate(withDuration: duration,
			delay: 0,
			options: UIViewAnimationOptions(),
			animations: {
				self.view.backgroundColor = theme.mdAlertControllerBackgroundColor
				self.alertView.layer.cornerRadius = theme.mdAlertControllerAlertCornerRadius
				self.alertView.backgroundColor = theme.mdAlertControllerAlertBackgroundColor
				self.titleLabel.textColor = theme.mdAlertControllerTitleTextColor
				self.messageLabel.textColor = theme.mdAlertControllerMessageTextColor
				for tuple in self._actionsAndButtons {
					let button = tuple.button
					let action = tuple.action
					button.setAttributedTitle(getAttributedStringFrom(action.title.uppercased(), withFontSize: mdAlertButtonFontSize, color: theme.mdAlertControllerButtonTextColorNormal, bold: true), for: UIControlState())
					button.setAttributedTitle(getAttributedStringFrom(action.title.uppercased(), withFontSize: mdAlertButtonFontSize, color: theme.mdAlertControllerButtonTextColorHighlighted, bold: true), for: .highlighted)
				}
			}, completion: nil)
	}

	// This method is for using selector
	func updateColorWithAnimation() {
		self.updateColor(animated: true)
	}

	// This method is for using selector
	func updateColorWithoutAnimation() {
		self.updateColor()
	}
}
