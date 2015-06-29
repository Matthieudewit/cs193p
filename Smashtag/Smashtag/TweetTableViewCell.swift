//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Vojta Molda on 3/25/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        tweetProfileImageView?.image = nil
        tweetScreenNameLabel?.text = nil
        tweetCreatedLabel?.text = nil
        tweetTextLabel?.attributedText = nil
        
        if let tweet = self.tweet {
            tweetTextLabel?.attributedText = tweet.attributedText
            
            tweetScreenNameLabel?.text = "\(tweet.user)"
            
            if let url = tweet.user.profileImageURL {
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    let imageData = NSData(contentsOfURL: url)
                    dispatch_async(dispatch_get_main_queue()) {
                        if url == tweet.user.profileImageURL {
                            if imageData != nil {
                                self.tweetProfileImageView?.image = UIImage(data: imageData!)
                            } else {
                                self.tweetProfileImageView?.image = nil
                            }
                        }
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
        
    }
}

private extension Tweet {
    var attributedText: NSAttributedString {
        get {
            var text = self.text
            for _ in self.media {
                text += " ."
            }
            let attributedText = NSMutableAttributedString(string: text)
            for hashtag in self.hashtags {
                attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.brownColor(), range: hashtag.nsrange)
            }
            for userMention in self.userMentions {
                attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: userMention.nsrange)
            }
            for url in self.urls {
                attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: url.nsrange)
            }

            return attributedText
        }
    }
}

