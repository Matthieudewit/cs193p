//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 5/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class MentionsTableViewController: UITableViewController {

    private struct Section {
        let header: String
        let cellIdentifier: String
        var mentions: [Mention]
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
        static let ShowWebsiteSegueIdentifier = "Show Website"
        static let ShowImageSegueIdentifier = "Show Image"
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
            if tweet != nil {
                var userMentions = tweet!.userMentions.map{ Section.Mention.User(keyword: $0.keyword) }
                userMentions.insert(Section.Mention.User(keyword: "@" + tweet!.user.screenName), atIndex: 0)
                let usersSection = Section(header: "Users",
                    cellIdentifier: "Mention User",
                    mentions: userMentions)
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
        case .Image(_, let aspectRatio):
            let height = ( tableView.bounds.width - CGFloat(25) ) / aspectRatio
            return height
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(sections[indexPath.section].cellIdentifier, forIndexPath: indexPath)
        switch sections[indexPath.section].mentions[indexPath.row] {
        case .Image(let imageURL, _):
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageURL = imageURL
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
        case .Hashtag:
            performSegueWithIdentifier(Storyboard.SearchTweetsSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
        case .User:
            performSegueWithIdentifier(Storyboard.SearchTweetsSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
        default:
            break
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Storyboard.SearchTweetsSegueIdentifier:
            if let tweetsTableController = segue.destinationViewController as? TweetsTableViewController {
                if let senderCell = sender as? UITableViewCell where senderCell.textLabel?.text != nil {
                    tweetsTableController.searchText = senderCell.textLabel!.text
                }
            }
        case Storyboard.ShowImageSegueIdentifier:
            if let imageController = segue.destinationViewController as? ImageViewController {
                if let senderCell = sender as? ImageTableViewCell where senderCell.imageURL != nil {
                    imageController.imageURL = senderCell.imageURL
                }
            }
        case Storyboard.ShowWebsiteSegueIdentifier:
            if let websiteController = segue.destinationViewController as? WebsiteViewController {
                if let senderCell = sender as? UITableViewCell where senderCell.textLabel?.text != nil {
                    websiteController.websiteURL = NSURL(string: senderCell.textLabel!.text!)
                }
            }
         default:
            break
        }
    }

}
