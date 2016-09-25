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
                let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
                DispatchQueue.global(priority: qos).async {
                    let imageData = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
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
            
            let formatter = DateFormatter()
            if Date().timeIntervalSince(tweet.created as Date) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetCreatedLabel?.text = formatter.string(from: tweet.created as Date)
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
                attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.brown, range: hashtag.nsrange)
            }
            for userMention in self.userMentions {
                attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: userMention.nsrange)
            }
            for url in self.urls {
                attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: url.nsrange)
            }

            return attributedText
        }
    }
}

