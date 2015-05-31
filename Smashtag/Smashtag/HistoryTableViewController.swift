//
//  HistoryTableViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/6/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController, UITableViewDelegate {
    
    private struct Storyboard {
        static let MentionHistoryCellIdentifier = "Mention History"
        static let SearchTweetsSegueIdentifier = "Search History"
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - User actions

    @IBAction func clearHistory(sender: UIBarButtonItem) {
        var alert = UIAlertController(title: "Clear all searched mentions?", message: "Action can't be undone", preferredStyle: UIAlertControllerStyle.Alert)
        // UIAlertAction(title: <#String#>, style: <#UIAlertActionStyle#>, handler: <#((UIAlertAction!) -> Void)!##(UIAlertAction!) -> Void#>)
        let clearAction = UIAlertAction(title: "Clear", style: UIAlertActionStyle.Destructive) {
            (action: UIAlertAction!) -> Void in
            History.clear()
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            (action: UIAlertAction!) -> Void in
        }
        alert.addAction(cancelAction)
        alert.addAction(clearAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return History.searchedMentions.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MentionHistoryCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = History.searchedMentions[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let navigationController = tabBarController?.viewControllers?[0] as? UINavigationController {
            if let tweetsTableController = navigationController.viewControllers[0] as? TweetsTableViewController {
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                tweetsTableController.searchText = cell?.textLabel?.text
                tabBarController?.selectedIndex = 0
            }
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetsTableController = segue.destinationViewController as? TweetsTableViewController {
            if let senderCell = sender as? UITableViewCell where senderCell.textLabel?.text != nil {
                tweetsTableController.searchText = senderCell.textLabel!.text
            }
        }
    }

}



struct History {
    static private let key = "History.SearchedMentions"
    static private let capacity = 100
    static private var mentions: [String] = NSUserDefaults.standardUserDefaults().objectForKey(History.key) as? [String] ?? [] {
        didSet {
            let aboveCapacity = History.searchedMentions.count - History.capacity
            if aboveCapacity >= 0 {
                History.mentions.removeRange(0 ... aboveCapacity)
            }
            NSUserDefaults.standardUserDefaults().setObject(searchedMentions, forKey: History.key)
        }
    }
    
    static var searchedMentions: [String] {
        get { return History.mentions }
    }
    
    static func append(searchedMention: String) {
        History.mentions = History.mentions.filter { $0 != searchedMention ? true : false }
        History.mentions.insert(searchedMention, atIndex: 0)
    }

    static func clear() {
        History.mentions = []
    }
}
