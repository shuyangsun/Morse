//
//  SettingsLanguagesTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsLanguagesTableViewController: TableViewController {

	var currentCheckedCell:TableViewLanguageCell?
	var initialLanguageCode:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.languages
		self.navigationController?.navigationBar.barTintColor = appDelegate.theme.navigationBarBackgroundColor
		self.navigationController?.navigationBar.tintColor = appDelegate.theme.navigationBarTitleTextColor
		var textAttributes = self.navigationController?.navigationBar.titleTextAttributes
		if textAttributes != nil {
			textAttributes![NSForegroundColorAttributeName] = appDelegate.theme.navigationBarTitleTextColor
		} else {
			textAttributes = [NSForegroundColorAttributeName: appDelegate.theme.navigationBarTitleTextColor]
		}
		self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()

		let tracker = GAI.sharedInstance().defaultTracker
		tracker?.set(kGAIScreenName, value: settingsLanguageVCName)

		let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])

		self.initialLanguageCode = appDelegate.currentLocaleLanguageCode
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 1 // Default
		case 1: return 3 // Asia
		case 2 : return 3 // Europe
		case 3: return 2 // North America
		default: return 0
		}
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell:TableViewLanguageCell = TableViewLanguageCell()
		let currentLanguageCode = appDelegate.currentLocaleLanguageCode
		if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCell(withIdentifier: "Settings Language Default Cell", for: indexPath) as! TableViewLanguageCell
				cell.languageCode = ""
				if currentCheckedCell == nil && currentLanguageCode == appDelegate.firstLaunchSystemLanguageCode {
					cell.accessoryType = .checkmark
					self.currentCheckedCell = cell
				}
			default: break
			}
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "Settings Language Detailed Cell", for: indexPath) as! TableViewLanguageCell
			if indexPath.section == 1 {
				switch indexPath.row {
				case 0:
					cell.languageCode = "ar"
				case 1:
					cell.languageCode = "zh-Hans"
				case 2:
					cell.languageCode = "zh-Hant"
				default: break
				}
			} else if indexPath.section == 2 {
				switch indexPath.row {
				case 0:
					cell.languageCode = "en-GB"
				case 1:
					cell.languageCode = "fr"
				case 2:
					cell.languageCode = "de"
				default: break
				}
			} else if indexPath.section == 3 {
				switch indexPath.row {
				case 0:
					cell.languageCode = "en-US"
				case 1:
					cell.languageCode = "es"
				default: break
				}
			}
		}

		if indexPath.section != 0 {
			if currentCheckedCell == nil && currentLanguageCode == cell.languageCode {
				cell.accessoryType = .checkmark
				self.currentCheckedCell = cell
			}
		}

		cell.updateColor()

		return cell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return LocalizedStrings.Languages.defaultGroup
		case 1: return LocalizedStrings.Languages.asia
		case 2: return LocalizedStrings.Languages.europe
		case 3: return LocalizedStrings.Languages.northAmerica
		default: return nil
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 0: return LocalizedStrings.Languages.restartReminderFooter
		default: return nil
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableViewCellHeight
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! TableViewLanguageCell
		if cell !== self.currentCheckedCell {
			self.currentCheckedCell?.accessoryType = .none
			self.currentCheckedCell?.updateColor()
			cell.accessoryType = .checkmark
			self.currentCheckedCell = cell
			cell.updateColor()
			let languageCode = cell.languageCode
			if languageCode.isEmpty {
				appDelegate.resetLocaleToSystemDefault()
			} else {
				appDelegate.updateLocalWithIdentifier(languageCode)
			}
			if appDelegate.showRestartAlert {
				// Tell user to restart app
				let alertController = MDAlertController(title: LocalizedStrings.Alert.titleRestartApp, message: LocalizedStrings.Alert.messageRestartApp)
				let action1 = MDAlertAction(title: LocalizedStrings.Alert.buttonGotIt)
				let action2 = MDAlertAction(title: LocalizedStrings.Alert.buttonDonnotShowAgain) {
					action in
					appDelegate.showRestartAlert = false
				}
				alertController.addAction(action1, action2)
				alertController.show()
			}
			let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action",
				action: "button_press",
				label: "Language Changed",
				value: nil).build() as! [AnyHashable: Any])
		}
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
