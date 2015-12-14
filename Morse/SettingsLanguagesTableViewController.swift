//
//  SettingsLanguagesTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsLanguagesTableViewController: UITableViewController {

	var currentCheckedCell:LanguageTableViewCell?

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

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		switch section {
		case 0: return 1 // Default
		case 1: return 3 // Asia
		case 2: return 1 // North America
		default: return 0
		}
    }

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell:LanguageTableViewCell = LanguageTableViewCell()
		let currentLanguageCode = appDelegate.currentLocaleLanguageCode
		if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Language Default Cell", forIndexPath: indexPath) as! LanguageTableViewCell
				cell.languageCode = ""
				if currentCheckedCell == nil && currentLanguageCode == appDelegate.firstLaunchSystemLanguageCode {
					cell.accessoryType = .Checkmark
					self.currentCheckedCell = cell
				}
			default: break
			}
		} else if indexPath.section == 1 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Language Detailed Cell", forIndexPath: indexPath) as! LanguageTableViewCell
				cell.languageCode = "ar"
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Language Detailed Cell", forIndexPath: indexPath) as! LanguageTableViewCell
				cell.languageCode = "zh-Hans"
			case 2:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Language Detailed Cell", forIndexPath: indexPath) as! LanguageTableViewCell
				cell.languageCode = "zh-Hant"
			default: break
			}
		} else if indexPath.section == 2 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Language Detailed Cell", forIndexPath: indexPath) as! LanguageTableViewCell
				cell.languageCode = "en"
			default: break
			}
		}

		if indexPath.section != 0 {
			if currentCheckedCell == nil && currentLanguageCode == cell.languageCode {
				cell.accessoryType = .Checkmark
				self.currentCheckedCell = cell
			}
		}
		
		// Configure the cell...

		return cell
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 1: return LocalizedStrings.Languages.asia
		case 2: return LocalizedStrings.Languages.northAmerica
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return tableViewCellHeight
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! LanguageTableViewCell
		cell.accessoryType = .Checkmark
		self.currentCheckedCell?.accessoryType = .None
		self.currentCheckedCell = cell
		let languageCode = cell.languageCode
		if languageCode.isEmpty {
			appDelegate.resetLocaleToSystemDefault()
		} else {
			appDelegate.updateLocalWithIdentifier(languageCode)
		}
		// TODO: warn user to restart
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
