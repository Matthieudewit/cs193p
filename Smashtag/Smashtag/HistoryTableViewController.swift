//
//  HistoryTableViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/6/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    fileprivate struct Storyboard {
        static let MentionHistoryCellReuseIdentifier = "Mention History"
        static let SearchTweetsSegueIdentifier = "Search History"
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - User actions

    @IBAction func clearHistory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Clear all searched mentions?", message: "Action can't be undone", preferredStyle: UIAlertControllerStyle.alert)
        let clearAction = UIAlertAction(title: "Clear", style: UIAlertActionStyle.destructive) {
            (action: UIAlertAction!) -> Void in
            History.clear()
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            (action: UIAlertAction!) -> Void in
        }
        alert.addAction(cancelAction)
        alert.addAction(clearAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return History.searchedMentions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MentionHistoryCellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = History.searchedMentions[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navigationController = tabBarController?.viewControllers?[0] as? UINavigationController {
            if let tweetsTableController = navigationController.viewControllers[0] as? TweetsTableViewController {
                let cell = tableView.cellForRow(at: indexPath)
                tweetsTableController.searchText = cell?.textLabel?.text
                tabBarController?.selectedIndex = 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            History.removeAtIndex((indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}



struct History {
    static fileprivate let key = "History.SearchedMentions"
    static fileprivate let capacity = 100
    static fileprivate var mentions: [String] = UserDefaults.standard.object(forKey: History.key) as? [String] ?? [] {
        didSet {
            let aboveCapacity = History.searchedMentions.count - History.capacity
            if aboveCapacity >= 0 {
                History.mentions.removeSubrange(0 ... aboveCapacity)
            }
            UserDefaults.standard.set(searchedMentions, forKey: History.key)
        }
    }
    
    static var searchedMentions: [String] {
        get { return History.mentions }
    }
    
    static func append(_ searchedMention: String) {
        History.mentions = History.mentions.filter { $0 != searchedMention ? true : false }
        History.mentions.insert(searchedMention, at: 0)
    }
    
    static func removeAtIndex(_ index: Int) {
        History.mentions.remove(at: index)
    }

    static func clear() {
        History.mentions = []
    }
}
