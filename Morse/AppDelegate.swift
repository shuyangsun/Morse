//
//  AppDelegate.swift
//  Morse
//
//  Created by Shuyang Sun on 11/29/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	var userDefaults:UserDefaults {
		return UserDefaults.standard
	}

	var theme:Theme {
		get {
			return Theme(rawValue: self.userDefaults.integer(forKey: userDefaultsKeyTheme))!
		}
		set {
			self.userDefaults.set(newValue.rawValue, forKey: userDefaultsKeyTheme)
			self.userDefaults.synchronize()
			NotificationCenter.default.post(name: Notification.Name(rawValue: themeDidChangeNotificationName), object: nil)
		}
	}

	var adsRemoved:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyAdsRemoved)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyAdsRemoved)
			self.userDefaults.synchronize()
			NotificationCenter.default.post(name: Notification.Name(rawValue: adsShouldDisplayDidChangeNotificationName), object: nil)
		}
	}

	var isAbleToTurnOffPromotionalTextWhenShare:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyIsAbleToTurnOffPromotionalTextWhenShare)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyIsAbleToTurnOffPromotionalTextWhenShare)
			self.userDefaults.synchronize()
		}
	}

	var userSelectedTheme:Theme {
		return Theme(rawValue: self.userDefaults.integer(forKey: userDefaultsKeyUserSelectedTheme))!
	}

	// UI theme
	var addExtraTextWhenShare:Bool {
		return self.userDefaults.bool(forKey: userDefaultsKeyExtraTextWhenShare)
	}

	var prosignTranslationType:ProsignTranslationType {
		get {
			return ProsignTranslationType(rawValue: self.userDefaults.integer(forKey: userDefaultsKeyProsignTranslationType))!
		}
		set {
			self.userDefaults.set(newValue.rawValue, forKey: userDefaultsKeyProsignTranslationType)
			self.userDefaults.synchronize()
		}
	}

	var notFirstLaunch:Bool {
		return self.userDefaults.bool(forKey: userDefaultsKeyNotFirstLaunch)
	}

	var interactionSoundDisabled:Bool {
		return self.userDefaults.bool(forKey: userDefaultsKeyInteractionSoundDisabled)
	}

	var animationDurationScalar:TimeInterval {
		let result = self.userDefaults.double(forKey: userDefaultsKeyAnimationDurationScalar)
		return result == 0 ? 1 : TimeInterval(result)
	}

	var firstLaunchSystemLanguageCode:String {
		let res = self.userDefaults.string(forKey: userDefaultsKeyFirstLaunchLanguageCode)
		return res == nil ? "en" : res!
	}

	var soundOutputEnabled:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeySoundOutputEnabled)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeySoundOutputEnabled)
			self.userDefaults.synchronize()
		}
	}

	var flashOutputEnabled:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyFlashOutputEnabled)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyFlashOutputEnabled)
			self.userDefaults.synchronize()
		}
	}

	var outputWPM:Int {
		get {
			return self.userDefaults.integer(forKey: userDefaultsKeyOutputWPM)
		}
		set {
			appDelegate.userDefaults.set(newValue, forKey: userDefaultsKeyOutputWPM)
			appDelegate.userDefaults.synchronize()
		}
	}

	var outputPitch:Float {
		get {
			return self.userDefaults.float(forKey: userDefaultsKeyOutputPitch)
		}
		set {
			appDelegate.userDefaults.set(newValue, forKey: userDefaultsKeyOutputPitch)
			appDelegate.userDefaults.synchronize()
		}
	}

	var inputWPM:Int {
		get {
			return self.userDefaults.integer(forKey: userDefaultsKeyInputWPM)
		}
		set {
			appDelegate.userDefaults.set(newValue, forKey: userDefaultsKeyInputWPM)
			appDelegate.userDefaults.synchronize()
			NotificationCenter.default.post(name: Notification.Name(rawValue: inputWPMDidChangeNotificationName), object: nil)
		}
	}

	var inputWPMAutomatic:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyInputWPMAutomatic)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyInputWPMAutomatic)
			self.userDefaults.synchronize()
		}
	}

	var inputPitch:Float {
		get {
			return self.userDefaults.float(forKey: userDefaultsKeyInputPitch)
		}
		set {
			appDelegate.userDefaults.set(newValue, forKey: userDefaultsKeyInputPitch)
			appDelegate.userDefaults.synchronize()
			NotificationCenter.default.post(name: Notification.Name(rawValue: inputPitchDidChangeNotificationName), object: nil)
		}
	}

	var inputPitchAutomatic:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyInputPitchAutomatic)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyInputPitchAutomatic)
			self.userDefaults.synchronize()
		}
	}

	var brightenScreenWhenOutput:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyBrightenScreenWhenOutput)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyBrightenScreenWhenOutput)
			self.userDefaults.synchronize()
		}
	}

	var autoCorrectMissSpelledWordsForAudioInput:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyAutoCorrectMisSpelledWordsForAudioInput)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyAutoCorrectMisSpelledWordsForAudioInput)
			self.userDefaults.synchronize()
		}
	}

	var automaticNightMode:Bool {
		return self.userDefaults.bool(forKey: userDefaultsKeyAutoNightMode)
	}

	var automaticNightModeThreshold:Float {
		return self.userDefaults.float(forKey: userDefaultsKeyAutoNightModeThreshold)
	}

	var showRestartAlert:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyShowRestarAlert)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyShowRestarAlert)
			self.userDefaults.synchronize()
		}
	}

	var showAddedTutorialCardsAlert:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyShowAddedTutorialCardsAlert)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyShowAddedTutorialCardsAlert)
			self.userDefaults.synchronize()
		}
	}

	// App store rating related:
	/** Whether the user wants the rating prompt to show up. Will set to false if the user choose "Don't show again." */
	var showRateOnAppStorePrompt:Bool {
		get {
			return self.userDefaults.bool(forKey: userDefaultsKeyShowAppStoreRatingPrompt)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyShowAddedTutorialCardsAlert)
			self.userDefaults.synchronize()
		}
	}

	var lastRatedVersionString:String? {
		get {
			return self.userDefaults.string(forKey: userDefaultsKeyLastRatedVersion)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyLastRatedVersion)
			self.userDefaults.synchronize()
		}
	}
	/** Set the "last rated version" string to the current version of OS. */
	func setRatedThisVersion() {
		self.lastRatedVersionString = ProcessInfo.processInfo.operatingSystemVersionString
	}

	var appLaunchCount:Int {
		get {
			return self.userDefaults.integer(forKey: userDefaultsKeyAppLaunchCount)
		}
		set {
			self.userDefaults.set(newValue, forKey: userDefaultsKeyAppLaunchCount)
			self.userDefaults.synchronize()
		}
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		self.appLaunchCount += 1
		UIApplication.shared.statusBarStyle = .lightContent
		Timer.scheduledTimer(timeInterval: defaultAutoNightModeUpdateTimeInterval, target: self, selector: #selector(updateThemeIfAutoNight), userInfo: nil, repeats: true)

		if !self.notFirstLaunch {
			self.userDefaults.set(true, forKey: userDefaultsKeyExtraTextWhenShare)
			self.userDefaults.set(true, forKey: userDefaultsKeyBrightenScreenWhenOutput)
			self.userDefaults.set(true, forKey: userDefaultsKeyInputWPMAutomatic)
			self.userDefaults.set(true, forKey: userDefaultsKeyInputPitchAutomatic)
			self.userDefaults.set(true, forKey: userDefaultsKeyAutoCorrectMisSpelledWordsForAudioInput)
			self.userDefaults.set(true, forKey: userDefaultsKeyAutoNightMode)
			self.userDefaults.set(true, forKey: userDefaultsKeyAdsRemoved)
			self.userDefaults.set(true, forKey: userDefaultsKeyIsAbleToTurnOffPromotionalTextWhenShare)
			self.userDefaults.set(true, forKey: userDefaultsKeyShowAppStoreRatingPrompt)
			self.resetAlerts()
			self.userDefaults.set(defaultInputWPM, forKey: userDefaultsKeyInputWPM)
			self.userDefaults.set(defaultInputPitch, forKey: userDefaultsKeyInputPitch)
			self.userDefaults.set(defaultOutputWPM, forKey: userDefaultsKeyOutputWPM)
			self.userDefaults.set(defaultOutputPitch, forKey: userDefaultsKeyOutputPitch)
			self.userDefaults.set(defaultAutoNightModeThreshold, forKey: userDefaultsKeyAutoNightModeThreshold)
			self.userDefaults.set(ProsignTranslationType.always.rawValue, forKey: userDefaultsKeyProsignTranslationType)
			self.userDefaults.synchronize()
			self.userDefaults.set(Locale.preferredLanguages.first!, forKey: userDefaultsKeyFirstLaunchLanguageCode)
		}

		// Configure tracker from GoogleService-Info.plist.
		var configureError:NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(configureError)")

		// Optional: configure GAI options.
		let gai = GAI.sharedInstance()
		gai.trackUncaughtExceptions = true  // report uncaught exceptions
		gai.logger.logLevel = GAILogLevel.verbose  // remove before app release
		#if DEBUG
			gai.optOut = true
		#endif
		return true
	}

	func resetAlerts() {
		self.userDefaults.set(true, forKey: userDefaultsKeyShowRestarAlert)
		self.userDefaults.set(true, forKey: userDefaultsKeyShowAddedTutorialCardsAlert)
		self.userDefaults.synchronize()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.

		// If the app is going to terminate, set notFirstLaunch to true.
		self.userDefaults.set(true, forKey: userDefaultsKeyNotFirstLaunch)
		self.userDefaults.synchronize()
		self.saveContext()
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: URL = {
	    // The directory the application uses to store the Core Data store file. This code uses a directory named "shuyangsun.Morse" in the application's documents Application Support directory.
	    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	    return urls[urls.count-1]
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
	    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
	    let modelURL = Bundle.main.url(forResource: "Morse", withExtension: "momd")!
	    return NSManagedObjectModel(contentsOf: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
	    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
	    // Create the coordinator and store
	    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	    let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
	    var failureReason = "There was an error creating or loading the application's saved data."
	    do {
	        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
	    } catch let error as NSError {
	        // Report any error we got.
	        var dict = [String: AnyObject]()
	        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
	        dict[NSLocalizedFailureReasonErrorKey] = failureReason

	        dict[NSUnderlyingErrorKey] = error
	        let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
	        // Replace this with code to handle the error appropriately.
	        // abort() causes the application to generate a crash log a nd terminate. You should not use this function in a shipping application, although it may be useful during development.
	        NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
	        abort()
		} catch {
			
		}

	    return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext = {
	    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
	    let coordinator = self.persistentStoreCoordinator
	    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	    managedObjectContext.persistentStoreCoordinator = coordinator
	    return managedObjectContext
	}()

	// MARK: - Core Data Saving support

	func saveContext () {
	    if managedObjectContext.hasChanges {
	        do {
	            try managedObjectContext.save()
	        } catch {
	            // Replace this implementation with code to handle the error appropriately.
	            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            let nserror = error as NSError
	            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
	            abort()
	        }
	    }
	}

	func updateThemeIfAutoNight() {
		if self.automaticNightMode {
			let brightness = UIScreen.main.brightness
			var shouldBeTheme = Theme(rawValue: self.userDefaults.integer(forKey: userDefaultsKeyUserSelectedTheme))!
			if brightness <= CGFloat(self.automaticNightModeThreshold) {
				shouldBeTheme = .night
			}
			if self.theme != shouldBeTheme {
				self.theme = shouldBeTheme
			}
		}
	}

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		if let action = shortcutItem.userInfo?["action"] as? String {
			if let tabbarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController {
				if action == "ENCODE_TEXT" {
					tabbarVC.selectedIndex = 0
					if let homeVC = tabbarVC.viewControllers?[0] as? HomeViewController {
						homeVC.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: homeVC.scrollView.bounds.width, height: 1), animated: false)
						if !homeVC.topSectionViewController.isDirectionEncode {
							homeVC.topSectionViewController.roundButtonTapped(nil)
						}
						homeVC.topSectionViewController.keyboardButtonTapped()
					}
				} else if action == "DECODE_MORSE" {
					tabbarVC.selectedIndex = 0
					if let homeVC = tabbarVC.viewControllers?[0] as? HomeViewController {
						homeVC.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: homeVC.scrollView.bounds.width, height: 1), animated: false)
						if homeVC.topSectionViewController.isDirectionEncode {
							homeVC.topSectionViewController.roundButtonTapped(nil)
						}
						homeVC.topSectionViewController.keyboardButtonTapped()
					}
				} else if action == "AUDIO_DECODER" {
					tabbarVC.selectedIndex = 0
					if let homeVC = tabbarVC.viewControllers?[0] as? HomeViewController {
						homeVC.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: homeVC.scrollView.bounds.width, height: 1), animated: false)
						if homeVC.topSectionViewController.isDirectionEncode {
							homeVC.topSectionViewController.roundButtonTapped(nil)
						}
						homeVC.microphoneButtonTapped()
						homeVC.topSectionViewController.microphoneButtonTapped()
					}
				} else if action == "DICTIONARY" {
					tabbarVC.selectedIndex = 1
					if let dicVC = tabbarVC.viewControllers?[1] as? MorseDictionaryViewController {
						dicVC.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: dicVC.scrollView.bounds.width, height: 1), animated: true)
					}
				}
			}
		}
	}
}

