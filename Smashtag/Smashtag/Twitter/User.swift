//
//  User.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

// container to hold data about a Twitter user

public struct User: CustomStringConvertible
{
    public let screenName: String
    public let name: String
    public let profileImageURL: URL?
    public let verified: Bool
    public let id: String!
    
    public var description: String { let v = verified ? " ✅" : ""; return "@\(screenName) (\(name))\(v)" }

    // MARK: - Private Implementation

    init?(data: NSDictionary?) {
        let name = data?.value(forKeyPath: TwitterKey.Name) as? String
        let screenName = data?.value(forKeyPath: TwitterKey.ScreenName) as? String
        if name != nil && screenName != nil {
            self.name = name!
            self.screenName = screenName!
            self.id = data?.value(forKeyPath: TwitterKey.ID) as? String
            if let verified = (data?.value(forKeyPath: TwitterKey.Verified) as AnyObject).boolValue {
                self.verified = verified
            } else {
                self.verified = false
            }
            if let urlString = data?.value(forKeyPath: TwitterKey.ProfileImageURL) as? String {
                self.profileImageURL = URL(string: urlString)
            } else {
                self.profileImageURL = nil
            }
            return
        }
        return nil
    }

    var asPropertyList: AnyObject {
        var dictionary = Dictionary<String,String>()
        dictionary[TwitterKey.Name] = self.name
        dictionary[TwitterKey.ScreenName] = self.screenName
        dictionary[TwitterKey.ID] = self.id
        dictionary[TwitterKey.Verified] = verified ? "YES" : "NO"
        dictionary[TwitterKey.ProfileImageURL] = profileImageURL?.absoluteString
        return dictionary as AnyObject
    }

    
    init() {
        screenName = "Unknown"
        name = "Unknown"
        verified = false
        id = nil
        profileImageURL = nil
    }
    
    struct TwitterKey {
        static let Name = "name"
        static let ScreenName = "screen_name"
        static let ID = "id_str"
        static let Verified = "verified"
        static let ProfileImageURL = "profile_image_url"
    }
}
