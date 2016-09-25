//
//  Tweet.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

// a simple container class which just holds the data in a Tweet
// IndexedKeywords are substrings of the Tweet's text
// for example, a hashtag or other user or url that is mentioned in the Tweet
// note carefully the comments on the two range properties in an IndexedKeyword
// Tweet instances re created by fetching from Twitter using a TwitterRequest

open class Tweet : CustomStringConvertible
{
    open let text: String
    open let user: User
    open let created: Date
    open let id: String?
    open let media: [MediaItem]
    open let hashtags: [IndexedKeyword]
    open let urls: [IndexedKeyword]
    open let userMentions: [IndexedKeyword]

    public struct IndexedKeyword: CustomStringConvertible
    {
        public let keyword: String              // will include # or @ or http:// prefix
        public let range: Range<String.Index>   // index into the Tweet's text property only
        public let nsrange: NSRange             // index into an NS[Attributed]String made from the Tweet's text

        public init?(data: NSDictionary?, inText: String, prefix: String?) {
            let indices = data?.value(forKeyPath: TwitterKey.Entities.Indices) as? NSArray
            if let startIndex = (indices?.firstObject as? NSNumber)?.intValue {
                if let endIndex = (indices?.lastObject as? NSNumber)?.intValue {
                    let length = inText.characters.count
                    if length > 0 {
                        let start = max(min(startIndex, length-1), 0)
                        let end = max(min(endIndex, length), 0)
                        if end > start {
                            var range = inText.characters.index(inText.startIndex, offsetBy: start)...inText.characters.index(inText.startIndex, offsetBy: end-1)
                            var keyword = inText.substring(with: range)
                            if prefix != nil && !keyword.hasPrefix(prefix!) && start > 0 {
                                range = inText.characters.index(inText.startIndex, offsetBy: start-1)...inText.characters.index(inText.startIndex, offsetBy: end-2)
                                keyword = inText.substring(with: range)
                            }
                            if prefix == nil || keyword.hasPrefix(prefix!) {
                                nsrange = inText.rangeOfString(keyword, nearRange: NSMakeRange(startIndex, endIndex-startIndex))
                                if nsrange.location != NSNotFound {
                                    self.keyword = keyword
                                    self.range = range
                                    return
                                }
                            }
                        }
                    }
                }
            }
            return nil
        }

        public var description: String { get { return "\(keyword) (\(nsrange.location), \(nsrange.location+nsrange.length-1))" } }
    }
    
    open var description: String { return "\(user) - \(created)\n\(text)\nhashtags: \(hashtags)\nurls: \(urls)\nuser_mentions: \(userMentions)" + (id == nil ? "" : "\nid: \(id!)") }

    // MARK: - Private Implementation

    init?(data: NSDictionary?) {
        if let user = User(data: data?.value(forKeyPath: TwitterKey.User) as? NSDictionary)
            , let text = data?.value(forKeyPath: TwitterKey.Text) as? String
            , let created = (data?.value(forKeyPath: TwitterKey.Created) as? String)?.asTwitterDate
        {
            self.user = user
            self.text = text
            self.created = created
            id = data?.value(forKeyPath: TwitterKey.ID) as? String
            var media = [MediaItem]()
            if let mediaEntities = data?.value(forKeyPath: TwitterKey.Media) as? NSArray {
                for mediaData in mediaEntities {
                    if let mediaItem = MediaItem(data: mediaData as? NSDictionary) {
                        media.append(mediaItem)
                    }
                }
            }
            self.media = media
            let hashtagMentionsArray = data?.value(forKeyPath: TwitterKey.Entities.Hashtags) as? NSArray
            self.hashtags = Tweet.getIndexedKeywords(hashtagMentionsArray, inText: text, prefix: "#")
            let urlMentionsArray = data?.value(forKeyPath: TwitterKey.Entities.URLs) as? NSArray
            self.urls = Tweet.getIndexedKeywords(urlMentionsArray, inText: text, prefix: "h")
            let userMentionsArray = data?.value(forKeyPath: TwitterKey.Entities.UserMentions) as? NSArray
            self.userMentions = Tweet.getIndexedKeywords(userMentionsArray, inText: text, prefix: "@")
            return
        }
        // we've failed
        // but compiler won't let us out of here with non-optional values unset
        // so set them to anything just to able to return nil
        // we could make these implicitly-unwrapped optionals, but they should never be nil, ever
        self.user = User()
        self.text = ""
        self.created = Date()
        self.id = nil
        self.media = []
        self.hashtags = []
        self.urls = []
        self.userMentions = []
        return nil
    }

    class fileprivate func getIndexedKeywords(_ dictionary: NSArray?, inText: String, prefix: String? = nil) -> [IndexedKeyword] {
        var results = [IndexedKeyword]()
        if let indexedKeywords = dictionary {
            for indexedKeywordData in indexedKeywords {
                if let indexedKeyword = IndexedKeyword(data: indexedKeywordData as? NSDictionary, inText: inText, prefix: prefix) {
                    results.append(indexedKeyword)
                }
            }
        }
        return results
    }
    
    struct TwitterKey {
        static let User = "user"
        static let Text = "text"
        static let Created = "created_at"
        static let ID = "id_str"
        static let Media = "entities.media"
        struct Entities {
            static let Hashtags = "entities.hashtags"
            static let URLs = "entities.urls"
            static let UserMentions = "entities.user_mentions"
            static let Indices = "indices"
        }
    }
}

private extension NSString {
    func rangeOfString(_ substring: NSString, nearRange: NSRange) -> NSRange {
        var start = max(min(nearRange.location, length-1), 0)
        var end = max(min(nearRange.location + nearRange.length, length), 0)
        var done = false
        while !done {
            let range = self.range(of: substring as String, options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(start, end-start))
            if range.location != NSNotFound {
                return range
            }
            done = true
            if start > 0 { start -= 1 ; done = false }
            if end < length { end += 1 ; done = false }
        }
        return NSMakeRange(NSNotFound, 0)
    }
}

private extension String {
    var asTwitterDate: Date? {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "C")
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            return dateFormatter.date(from: self)
        }
    }
}
