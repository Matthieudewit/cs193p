//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 5/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MentionsTableViewController: UITableViewController {

    fileprivate struct Section {
        let header: String
        let cellIdentifier: String
        var mentions: [Mention]
        fileprivate enum Mention {
            case image(imageURL: Foundation.URL, aspectRatio: CGFloat)
            case hashtag(keyword: String)
            case user(keyword: String)
            case url(URL: String)
        }
    }
    
    fileprivate var sections = [Section]()
    
    fileprivate struct Storyboard {
        static let SearchTweetsSegueIdentifier = "Search Tweets"
        static let ShowWebsiteSegueIdentifier = "Show Website"
        static let ShowImageSegueIdentifier = "Show Image"
    }

    var tweet: Tweet? {
        didSet {
            if tweet?.media.count > 0 {
                let imagesSection = Section(header: "Images",
                    cellIdentifier: "Mention Image",
                    mentions: tweet!.media.map{ Section.Mention.image(imageURL: $0.url as URL, aspectRatio: CGFloat($0.aspectRatio)) })
                sections.append(imagesSection)
            }
            if tweet?.hashtags.count > 0 {
                let hashtagsSection = Section(header: "Hashtags",
                    cellIdentifier: "Mention Hashtag",
                    mentions: tweet!.hashtags.map{ Section.Mention.hashtag(keyword: $0.keyword) })
                sections.append(hashtagsSection)
            }
            if tweet != nil {
                var userMentions = tweet!.userMentions.map{ Section.Mention.user(keyword: $0.keyword) }
                userMentions.insert(Section.Mention.user(keyword: "@" + tweet!.user.screenName), at: 0)
                let usersSection = Section(header: "Users",
                    cellIdentifier: "Mention User",
                    mentions: userMentions)
                sections.append(usersSection)
            }
            if tweet?.urls.count > 0 {
                let urlsSection = Section(header: "URLs",
                    cellIdentifier: "Mention URL",
                    mentions: tweet!.urls.map{  Section.Mention.url(URL: $0.keyword) })
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].mentions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[(indexPath as NSIndexPath).section].mentions[(indexPath as NSIndexPath).row] {
        case .image(_, let aspectRatio):
            let height = ( tableView.bounds.width - CGFloat(25) ) / aspectRatio
            return height
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sections[(indexPath as NSIndexPath).section].cellIdentifier, for: indexPath)
        switch sections[(indexPath as NSIndexPath).section].mentions[(indexPath as NSIndexPath).row] {
        case .image(let imageURL, _):
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageURL = imageURL
            }
        case .hashtag(let hashtag):
            cell.textLabel?.text = hashtag
        case .user(let user):
            cell.textLabel?.text = user
        case .url(let url):
            cell.textLabel?.text = url
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[(indexPath as NSIndexPath).section]
        let rowData = section.mentions[(indexPath as NSIndexPath).row]
        switch rowData {
        case .hashtag:
            performSegue(withIdentifier: Storyboard.SearchTweetsSegueIdentifier, sender: tableView.cellForRow(at: indexPath))
        case .user:
            performSegue(withIdentifier: Storyboard.SearchTweetsSegueIdentifier, sender: tableView.cellForRow(at: indexPath))
        default:
            break
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Storyboard.SearchTweetsSegueIdentifier:
            if let tweetsTableController = segue.destination as? TweetsTableViewController {
                if let senderCell = sender as? UITableViewCell , senderCell.textLabel?.text != nil {
                    tweetsTableController.searchText = senderCell.textLabel!.text
                }
            }
        case Storyboard.ShowImageSegueIdentifier:
            if let imageController = segue.destination as? ImageViewController {
                if let senderCell = sender as? ImageTableViewCell , senderCell.imageURL != nil {
                    imageController.imageURL = senderCell.imageURL
                }
            }
        case Storyboard.ShowWebsiteSegueIdentifier:
            if let websiteController = segue.destination as? WebsiteViewController {
                if let senderCell = sender as? UITableViewCell , senderCell.textLabel?.text != nil {
                    websiteController.websiteURL = URL(string: senderCell.textLabel!.text!)
                }
            }
         default:
            break
        }
    }

}
