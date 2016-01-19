//
//  SettingsThemeTableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/9/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class SettingsThemeTableViewController: TableViewController {

	var currentCheckedCell:TableViewCell?

	private func setup() {
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()

		// Navigation bar configuration
		self.navigationItem.title = LocalizedStrings.Settings.theme
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: settingsThemeVCName)

		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 2
		case 1: return Theme.numberOfThemes - 2
		default: return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Settings Theme Name Cell", forIndexPath: indexPath) as! TableViewCell
		cell.textLabel?.text = Theme(rawValue: self.rowIndForIndexPath(indexPath))?.name
		if currentCheckedCell == nil && appDelegate.userSelectedTheme.rawValue == self.rowIndForIndexPath(indexPath) {
			cell.accessoryType = .Checkmark
			self.currentCheckedCell = cell
		}

		cell.updateColor()

		return cell
    }

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return tableViewCellHeight
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
		if cell !== self.currentCheckedCell {
			self.currentCheckedCell?.accessoryType = .None
			if self.currentCheckedCell != cell {
				self.currentCheckedCell?.updateColor()
			}
			cell.accessoryType = .Checkmark
			self.currentCheckedCell = cell

			appDelegate.userDefaults.setInteger(self.rowIndForIndexPath(indexPath), forKey: userDefaultsKeyUserSelectedTheme)
			appDelegate.userDefaults.synchronize()
			theme = Theme(rawValue: self.rowIndForIndexPath(indexPath))!
			let tracker = GAI.sharedInstance().defaultTracker; tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action",
				action: "button_press",
				label: "Theme Changed",
				value: nil).build() as [NSObject : AnyObject])
		}
	}

	private func rowIndForIndexPath(indexPath:NSIndexPath) -> Int {
		var counter = 0
		for section in 0..<indexPath.section {
			counter += self.tableView(self.tableView, numberOfRowsInSection: section)
		}
		return counter + indexPath.row
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
