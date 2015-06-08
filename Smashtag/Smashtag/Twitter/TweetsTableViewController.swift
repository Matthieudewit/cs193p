//
//  TweetsTableViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 3/25/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class TweetsTableViewController: UITableViewController, UITextFieldDelegate {

    var tweets = [[Tweet]]()
    
    var lastSuccesfulRequest: TwitterRequest?

    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccesfulRequest == nil {
            if searchText != nil {
                if searchText!.hasPrefix("@") {
                    return TwitterRequest(search: "\(searchText!) OR from:\(searchText!)", count: 100)
                } else {
                    return TwitterRequest(search: searchText!, count: 100)
                }
            }
            return nil
        } else {
            return lastSuccesfulRequest!.requestForNewer
        }
    }

    var searchText: String? = "#stanford" {
        didSet {
            searchTextField.text = searchText
            lastSuccesfulRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }

    private struct Storyboard {
        static let TweetCellReuseIdentifier = "Tweet"
        static let ShowMentionsSegueIdentifier = "Show Mentions"
        static let ShowCollectionSegueIdentifier = "Show Images"
    }
    
    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
    }
    
    private func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }

    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            History.append(searchText!)
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccesfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    // MARK: - Navigation
    
    @IBAction func searchTweetsSegue(segue: UIStoryboardSegue) {
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Storyboard.ShowMentionsSegueIdentifier:
            if let mentionsController = segue.destinationViewController as? MentionsTableViewController {
                if let senderTweetCell = sender as? TweetTableViewCell where senderTweetCell.tweet != nil {
                    mentionsController.tweet = senderTweetCell.tweet!
                }
            }
        case Storyboard.ShowCollectionSegueIdentifier:
            if let collectionController = segue.destinationViewController as? ImagesCollectionViewController {
                collectionController.tweets = tweets
            }
        default:
            break
        }
    }
}
