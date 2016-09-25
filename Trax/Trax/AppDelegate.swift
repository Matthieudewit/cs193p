//
//  AppDelegate.swift
//  Trax
//
//  Created by Vojta Molda on 6/21/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

struct GPXURL {
    static let Notification = "GPXURL Radio Station"
    static let Key = "GPXURL URL Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: GPXURL.Notification), object: self, userInfo: [GPXURL.Key:url])
        center.post(notification)
        return true
    }

}

