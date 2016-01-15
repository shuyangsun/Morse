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

	var userDefaults:NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}

	var theme:Theme {
		get {
			return Theme(rawValue: self.userDefaults.integerForKey(userDefaultsKeyTheme))!
		}
		set {
			self.userDefaults.setInteger(newValue.rawValue, forKey: userDefaultsKeyTheme)
			self.userDefaults.synchronize()
			NSNotificationCenter.defaultCenter().postNotificationName(themeDidChangeNotificationName, object: nil)
		}
	}

	var userSelectedTheme:Theme {
		return Theme(rawValue: self.userDefaults.integerForKey(userDefaultsKeyUserSelectedTheme))!
	}

	// UI theme
	var addExtraTextWhenShare:Bool {
		return self.userDefaults.boolForKey(userDefaultsKeyExtraTextWhenShare)
	}

	var prosignTranslationType:ProsignTranslationType {
		get {
			return ProsignTranslationType(rawValue: self.userDefaults.integerForKey(userDefaultsKeyProsignTranslationType))!
		}
		set {
			self.userDefaults.setInteger(newValue.rawValue, forKey: userDefaultsKeyProsignTranslationType)
			self.userDefaults.synchronize()
		}
	}

	var notFirstLaunch:Bool {
		return self.userDefaults.boolForKey(userDefaultsKeyNotFirstLaunch)
	}

	var interactionSoundDisabled:Bool {
		return self.userDefaults.boolForKey(userDefaultsKeyInteractionSoundDisabled)
	}

	var animationDurationScalar:NSTimeInterval {
		let result = self.userDefaults.doubleForKey(userDefaultsKeyAnimationDurationScalar)
		return result == 0 ? 1 : NSTimeInterval(result)
	}

	var firstLaunchSystemLanguageCode:String {
		let res = self.userDefaults.stringForKey(userDefaultsKeyFirstLaunchLanguageCode)
		return res == nil ? "en" : res!
	}

	var soundOutputEnabled:Bool {
		return self.userDefaults.boolForKey(userDefaultsKeySoundOutputEnabled)
	}

	var flashOutputEnabled:Bool {
		return self.userDefaults.boolForKey(userDefaultsKeyFlashOutputEnabled)
	}

	var outputWPM:Int {
		get {
			return self.userDefaults.integerForKey(userDefaultsKeyOutputWPM)
		}
		set {
			appDelegate.userDefaults.setInteger(newValue, forKey: userDefaultsKeyOutputWPM)
			appDelegate.userDefaults.synchronize()
		}
	}

	var outputPitch:Float {
		get {
			return self.userDefaults.floatForKey(userDefaultsKeyOutputPitch)
		}
		set {
			appDelegate.userDefaults.setFloat(newValue, forKey: userDefaultsKeyOutputPitch)
			appDelegate.userDefaults.synchronize()
		}
	}

	var inputWPM:Int {
		get {
			return self.userDefaults.integerForKey(userDefaultsKeyInputWPM)
		}
		set {
			appDelegate.userDefaults.setInteger(newValue, forKey: userDefaultsKeyInputWPM)
			appDelegate.userDefaults.synchronize()
			NSNotificationCenter.defaultCenter().postNotificationName(inputWPMDidChangeNotificationName, object: nil)
		}
	}

	var inputWPMAutomatic:Bool {
		get {
			return self.userDefaults.boolForKey(userDefaultsKeyInputWPMAutomatic)
		}
		set {
			self.userDefaults.setBool(newValue, forKey: userDefaultsKeyInputWPMAutomatic)
			self.userDefaults.synchronize()
		}
	}

	var inputPitch:Float {
		get {
			return self.userDefaults.floatForKey(userDefaultsKeyInputPitch)
		}
		set {
			appDelegate.userDefaults.setFloat(newValue, forKey: userDefaultsKeyInputPitch)
			appDelegate.userDefaults.synchronize()
			NSNotificationCenter.defaultCenter().postNotificationName(inputPitchDidChangeNotificationName, object: nil)
		}
	}

	var inputPitchAutomatic:Bool {
		get {
			return self.userDefaults.boolForKey(userDefaultsKeyInputPitchAutomatic)
		}
		set {
			self.userDefaults.setBool(newValue, forKey: userDefaultsKeyInputPitchAutomatic)
			self.userDefaults.synchronize()
		}
	}

	var brightenScreenWhenOutput:Bool {
		get {
			return self.userDefaults.boolForKey(userDefaultsKeyBrightenScreenWhenOutput)
		}
		set {
			self.userDefaults.setBool(newValue, forKey: userDefaultsKeyBrightenScreenWhenOutput)
			self.userDefaults.synchronize()
		}
	}

	var autoCorrectMissSpelledWordsForAudioInput:Bool {
		get {
			return self.userDefaults.boolForKey(userDefaultsKeyAutoCorrectMisSpelledWordsForAudioInput)
		}
		set {
			self.userDefaults.setBool(newValue, forKey: userDefaultsKeyAutoCorrectMisSpelledWordsForAudioInput)
			self.userDefaults.synchronize()
		}
	}

	var automaticNightMode:Bool {
		return self.userDefaults.boolForKey(userDefaultsKeyAutoNightMode)
	}

	var automaticNightModeThreshold:Float {
		return self.userDefaults.floatForKey(userDefaultsKeyAutoNightModeThreshold)
	}

	var showRestartAlert:Bool {
		get {
			return self.userDefaults.boolForKey(userDefaultsKeyShowRestarAlert)
		}
		set {
			self.userDefaults.setBool(newValue, forKey: userDefaultsKeyShowRestarAlert)
			self.userDefaults.synchronize()
		}
	}

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		NSTimer.scheduledTimerWithTimeInterval(defaultAutoNightModeUpdateTimeInterval, target: self, selector: "updateThemeIfAutoNight", userInfo: nil, repeats: true)

		if !self.notFirstLaunch {
			self.userDefaults.setBool(true, forKey: userDefaultsKeyExtraTextWhenShare)
			self.userDefaults.setBool(true, forKey: userDefaultsKeyBrightenScreenWhenOutput)
			self.userDefaults.setBool(true, forKey: userDefaultsKeyInputWPMAutomatic)
			self.userDefaults.setBool(true, forKey: userDefaultsKeyInputPitchAutomatic)
			self.userDefaults.setBool(true, forKey: userDefaultsKeyAutoCorrectMisSpelledWordsForAudioInput)
			self.userDefaults.setBool(true, forKey: userDefaultsKeyAutoNightMode)
			self.userDefaults.setBool(true, forKey: userDefaultsKeyShowRestarAlert)
			self.userDefaults.setInteger(defaultInputWPM, forKey: userDefaultsKeyInputWPM)
			self.userDefaults.setFloat(defaultInputPitch, forKey: userDefaultsKeyInputPitch)
			self.userDefaults.setInteger(defaultOutputWPM, forKey: userDefaultsKeyOutputWPM)
			self.userDefaults.setFloat(defaultOutputPitch, forKey: userDefaultsKeyOutputPitch)
			self.userDefaults.setFloat(defaultAutoNightModeThreshold, forKey: userDefaultsKeyAutoNightModeThreshold)
			self.userDefaults.setInteger(ProsignTranslationType.Always.rawValue, forKey: userDefaultsKeyProsignTranslationType)
			self.userDefaults.synchronize()
			self.userDefaults.setObject(NSLocale.preferredLanguages().first!, forKey: userDefaultsKeyFirstLaunchLanguageCode)
		}

		// Configure tracker from GoogleService-Info.plist.
		var configureError:NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(configureError)")

		// Optional: configure GAI options.
		let gai = GAI.sharedInstance()
		gai.trackUncaughtExceptions = true  // report uncaught exceptions
		gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release

		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.

		// If the app is going to terminate, set notFirstLaunch to true.
		self.userDefaults.setBool(true, forKey: userDefaultsKeyNotFirstLaunch)
		self.userDefaults.synchronize()
		self.saveContext()
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: NSURL = {
	    // The directory the application uses to store the Core Data store file. This code uses a directory named "shuyangsun.Morse" in the application's documents Application Support directory.
	    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
	    return urls[urls.count-1]
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
	    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
	    let modelURL = NSBundle.mainBundle().URLForResource("Morse", withExtension: "momd")!
	    return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
	    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
	    // Create the coordinator and store
	    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
	    var failureReason = "There was an error creating or loading the application's saved data."
	    do {
	        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
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
	    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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
			let brightness = UIScreen.mainScreen().brightness
			var shouldBeTheme = Theme(rawValue: self.userDefaults.integerForKey(userDefaultsKeyUserSelectedTheme))!
			if brightness <= CGFloat(self.automaticNightModeThreshold) {
				shouldBeTheme = .Night
			}
			if self.theme != shouldBeTheme {
				self.theme = shouldBeTheme
			}
		}
	}

	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		if let action = shortcutItem.userInfo?["action"] as? String {
			if let tabbarVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? TabBarController {
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

