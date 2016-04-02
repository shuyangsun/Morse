//
//  TableViewController.swift
//  Morse
//
//  Created by Shuyang Sun on 1/10/16.
//  Copyright © 2016 Shuyang Sun. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

		self.view.backgroundColor = theme.tableViewBackgroundColor
		self.tableView.separatorColor = theme.tableViewSeparatorColor

		self.tableView.indicatorStyle = theme.scrollViewIndicatorStyle
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewController.updateColorWithAnimation), name: themeDidChangeNotificationName, object: nil)
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

	override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.textColor = theme.tableViewHeaderTextColor
		}
	}

	override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.textColor = theme.tableViewFooterTextColor
		}
	}

	/**
	Responsible for updating the UI when user changes the theme.
	- parameter animated: A boolean determines if the theme change should be animated.
	*/
	func updateColor(animated animated:Bool = true) {
		let duration = animated ? defaultAnimationDuration * animationDurationScalar : 0
		UIView.animateWithDuration(duration,
			delay: 0,
			options: .CurveEaseInOut,
			animations: {
				self.tableView.indicatorStyle = theme.scrollViewIndicatorStyle
				self.view.backgroundColor = theme.tableViewBackgroundColor
				self.tableView.separatorColor = theme.tableViewSeparatorColor
				self.navigationController?.navigationBar.barTintColor = theme.navigationBarBackgroundColor
				self.navigationController?.navigationBar.tintColor = theme.navigationBarTitleTextColor
				self.tabBarController?.tabBar.barTintColor = theme.tabBarBackgroundColor
				self.tabBarController?.tabBar.tintColor = theme.tabBarSelectedTintColor
			}) { succeed in
				// Update cell colors:
				self.tableView.reloadData()
		}
	}

	// This method is for using selector
	func updateColorWithAnimation() {
		self.updateColor(animated: true)
	}

	// This method is for using selector
	func updateColorWithoutAnimation() {
		self.updateColor()
	}

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

