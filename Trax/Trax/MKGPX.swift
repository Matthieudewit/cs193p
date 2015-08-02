//
//  MKGPX.swift
//  Trax
//
//  Created by Vojta Molda on 8/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import MapKit

extension GPX.Waypoint: MKAnnotation {
    
    var title: String! { return name }
    var subtitle: String! { return info }
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    
    var thumbnailURL: NSURL? { return getImageURLOfType("thumbnail") }
    var imageURL: NSURL? { return getImageURLOfType("large") }

    private func getImageURLOfType(type: String) -> NSURL? {
        for link in links {
            if link.type == type {
                return link.url
            }
        }
        return nil
    }

}
