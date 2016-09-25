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

    fileprivate struct Storyboard {
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
    
    fileprivate func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }

    @IBAction func refresh(_ sender: UIRefreshControl?) {
        if searchText != nil {
            History.append(searchText!)
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets) -> Void in
                    DispatchQueue.main.async { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccesfulRequest = request
                            self.tweets.insert(newTweets, at: 0)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellReuseIdentifier, for: indexPath) as! TweetTableViewCell
        cell.tweet = tweets[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        return cell
    }

    // MARK: - Navigation
    
    @IBAction func searchTweetsSegue(_ segue: UIStoryboardSegue) {
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Storyboard.ShowMentionsSegueIdentifier:
            if let mentionsController = segue.destination as? MentionsTableViewController {
                if let senderTweetCell = sender as? TweetTableViewCell , senderTweetCell.tweet != nil {
                    mentionsController.tweet = senderTweetCell.tweet!
                }
            }
        case Storyboard.ShowCollectionSegueIdentifier:
            if let collectionController = segue.destination as? ImagesCollectionViewController {
                collectionController.tweets = tweets
            }
        default:
            break
        }
    }
}
