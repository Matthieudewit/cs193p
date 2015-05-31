//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 5/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class MentionsTableViewController: UITableViewController, UITableViewDelegate {

    private struct Section {
        let header: String
        let cellIdentifier: String
        let mentions: [Mention]
        private enum Mention {
            case Image(imageURL: NSURL, aspectRatio: CGFloat)
            case Hashtag(keyword: String)
            case User(keyword: String)
            case URL(URL: String)
        }
    }
    
    private var sections = [Section]()
    
    private struct Storyboard {
        static let SearchTweetsSegueIdentifier = "Search Tweets"
    }

    var tweet: Tweet? {
        didSet {
            if tweet?.media.count > 0 {
                let imagesSection = Section(header: "Images",
                    cellIdentifier: "Mention Image",
                    mentions: tweet!.media.map{ Section.Mention.Image(imageURL: $0.url, aspectRatio: CGFloat($0.aspectRatio)) })
                sections.append(imagesSection)
            }
            if tweet?.hashtags.count > 0 {
                let hashtagsSection = Section(header: "Hashtags",
                    cellIdentifier: "Mention Hashtag",
                    mentions: tweet!.hashtags.map{ Section.Mention.Hashtag(keyword: $0.keyword) })
                sections.append(hashtagsSection)
            }
            if tweet?.userMentions.count > 0 {
                let usersSection = Section(header: "Users",
                    cellIdentifier: "Mention User",
                    mentions: tweet!.userMentions.map{ Section.Mention.User(keyword: $0.keyword) })
                sections.append(usersSection)
            }
            if tweet?.urls.count > 0 {
                let urlsSection = Section(header: "URLs",
                    cellIdentifier: "Mention URL",
                    mentions: tweet!.urls.map{  Section.Mention.URL(URL: $0.keyword) })
                sections.append(urlsSection)
            }
        }
    }

    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].mentions.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch sections[indexPath.section].mentions[indexPath.row] {
        case .Image(let imageURL, let aspectRatio):
            return ( tableView.bounds.width - CGFloat(25) ) * aspectRatio
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(sections[indexPath.section].cellIdentifier,
            forIndexPath: indexPath) as! UITableViewCell

        switch sections[indexPath.section].mentions[indexPath.row] {
        case .Image(let imageURL, let aspectRatio):
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.cellImageURL = imageURL
            }
        case .Hashtag(let hashtag):
            cell.textLabel?.text = hashtag
        case .User(let user):
            cell.textLabel?.text = user
        case .URL(let url):
            cell.textLabel?.text = url
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sections[indexPath.section]
        let rowData = section.mentions[indexPath.row]
        switch rowData {
        case .Image(let url):
            break
        case .Hashtag:
            performSegueWithIdentifier(Storyboard.SearchTweetsSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
        case .User:
            performSegueWithIdentifier(Storyboard.SearchTweetsSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
        case .URL(let url):
            if let nsUrl = NSURL(string: url) {
                UIApplication.sharedApplication().openURL(nsUrl)
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
        if let imageScrollController = segue.destinationViewController as? ImageScrollViewController {
            if let senderCell = sender as? ImageTableViewCell where senderCell.cellImageView.image != nil {
                imageScrollController.image = senderCell.cellImageView.image!
            }
        }
    }

}
