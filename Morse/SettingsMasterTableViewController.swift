//
//  SettingsMasterTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 12/14/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsMasterTableViewController: UITableViewController {

	private let _cellIdentifier = "Settings Default Cell Identifier"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.settings
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
		var result = 2
		#if DEBUG
			result = 3
		#endif
        return result
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 1
		case 1: return 2
		case 2: return 1
		default: return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = UITableViewCell()
		if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Languages Cell", forIndexPath: indexPath)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.languages
					, withFontSize: 16, color: appDelegate.theme.settingsCellTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
			default: break
			}
		} else if indexPath.section == 1 {
			switch indexPath.row {
			case 0:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Theme Cell", forIndexPath: indexPath)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.theme
					, withFontSize: 16, color: appDelegate.theme.settingsCellTitleTextColor, bold: false)
				cell.accessoryType = .DisclosureIndicator
			case 1:
				cell = tableView.dequeueReusableCellWithIdentifier("Settings Switch Layout Cell", forIndexPath: indexPath)
				cell.textLabel?.attributedText = getAttributedStringFrom(LocalizedStrings.Settings.switchLayoutDirection, withFontSize: 16, color: appDelegate.theme.settingsCellTitleTextColor, bold: false)
			default: break
			}
		}

        // Configure the cell...

        return cell
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return LocalizedStrings.Settings.general
		case 1: return LocalizedStrings.Settings.ui
		case 2: return LocalizedStrings.Settings.developer
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return tableViewCellHeight
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
