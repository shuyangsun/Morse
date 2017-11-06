//
//  WebViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/28/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: GAITrackedViewController {

	var topBarView: UIView!
	var progressBarView: UIView!
	var topBarLabel: UILabel!
	var backButton: BackButton!
	var webView: WKWebView! {
		didSet {
			self.loadCurrentURLRequest()
		}
	}

	var URLstr:String? = nil

	fileprivate var backButtonWidth:CGFloat {
		return topBarHeight
	}

	fileprivate var _progressTimer:Timer!

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return theme.style == .dark ? .lightContent : .default
	}

	// Only support landscape when it's on an iPad
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		if isPad {
			return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscape]
		} else {
			return UIInterfaceOrientationMask.portrait
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		self.screenName = webVCName
        // Do any additional setup after loading the view.

		self.view.backgroundColor = UIColor.white

		if self.topBarView == nil {
			self.topBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: topBarHeight + statusBarHeight))
			self.topBarView.backgroundColor = appDelegate.theme.topBarBackgroundColor.colorWithAlpha(webViewUnloadedTopBarAlpha)
			self.view.addSubview(topBarView)

			self.topBarView.snp_remakeConstraints({ (make) -> Void in
				make.top.equalTo(self.view)
				make.leading.equalTo(self.view)
				make.trailing.equalTo(self.view)
				make.height.equalTo(topBarHeight + statusBarHeight)
			})

			if self.progressBarView == nil {
				let x = layoutDirection == .leftToRight ? 0 : self.view.bounds.width
				self.progressBarView = UIView(frame: CGRect(x: x, y: 0, width: 0, height: topBarHeight))
				self.progressBarView.backgroundColor = theme.topBarBackgroundColor
				self.topBarView.insertSubview(self.progressBarView, at: 0)
				self.progressBarView.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
					make.leading.equalTo(self.topBarView)
				})
				self.topBarView.setNeedsUpdateConstraints()
			}

			if self.topBarLabel == nil {
				self.topBarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.topBarView.bounds.width, height: topBarHeight))
				self.topBarLabel.textAlignment = .center
				self.topBarLabel.tintColor = appDelegate.theme.topBarLabelTextColor
				self.topBarLabel.attributedText = NSAttributedString(string: LocalizedStrings.Settings.privacyPolicy, attributes:
					[NSFontAttributeName: UIFont.boldSystemFont(ofSize: 23),
						NSForegroundColorAttributeName: appDelegate.theme.topBarLabelTextColor])
				self.topBarView.addSubview(self.topBarLabel)

				self.topBarLabel.snp_remakeConstraints({ (make) -> Void in
					make.top.equalTo(self.topBarView).offset(statusBarHeight)
					make.centerX.equalTo(self.topBarView)
					make.bottom.equalTo(self.topBarView)
				})
			}

			if self.backButton == nil {
				self.backButton = BackButton(origin: CGPoint(x: 0, y: 0), width: self.backButtonWidth)
				self.backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
				self.topBarView.addSubview(self.backButton)

				self.backButton.snp_makeConstraints({ (make) -> Void in
					make.centerY.equalTo(self.topBarLabel)
					make.leading.equalTo(self.topBarView)
					make.width.equalTo(topBarHeight)
					make.height.equalTo(self.backButton.snp_width)
				})
				self.backButton.alpha = 0
			}

			self.topBarView.addMDShadow(withDepth: 2)
		}

		if self.webView == nil {
			self.webView = WKWebView(frame: self.view.bounds)
			self.view.insertSubview(self.webView, at: 0)
			self.webView.snp_makeConstraints({ (make) -> Void in
				make.top.equalTo(self.topBarView.snp_bottom)
				make.left.equalTo(self.view)
				make.right.equalTo(self.view)
				make.bottom.equalTo(self.view)
			})
		}
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.backButton.appearWithDuration(defaultAnimationDuration)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func loadCurrentURLRequest() {
		self._progressTimer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(updateLoadingProgress), userInfo: nil, repeats: true)
		if self.URLstr != nil {
			let url = URL(string: self.URLstr!)
			if url != nil {
				let request = URLRequest(url: url!)
				self.webView.load(request)
			}
		}
	}

	func updateLoadingProgress() {
		let completionRatio = self.webView.estimatedProgress
		let width = self.topBarView.bounds.width * CGFloat(completionRatio)
		let x = layoutDirection == .leftToRight ? 0 : self.topBarView.bounds.width - width
		self.progressBarView.frame = CGRect(x: x, y: 0, width: width, height: self.topBarView.bounds.height)
		if completionRatio >= 1 {
			self._progressTimer.invalidate()
			self.progressBarView.snp_remakeConstraints({ (make) -> Void in
				make.edges.equalTo(self.topBarView)
			})
		}
	}

	func backButtonTapped(_ sender:AnyObject) {
		self.backButton.disappearWithDuration(defaultAnimationDuration) {
			self.dismiss(animated: true, completion: nil)
		}
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
