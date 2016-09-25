//
//  MKGPX.swift
//  Trax
//
//  Created by Vojta Molda on 8/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import MapKit

extension GPX {

    class MutableWaypoint: GPX.Waypoint {
        
        override var coordinate: CLLocationCoordinate2D {
            get { return super.coordinate }
            set { latitude = newValue.latitude; longitude = newValue.longitude }
        }
        
        override var thumbnailURL: URL? { return links.first?.url as URL? }
        override var imageURL: URL? { return links.first?.url as URL? }


    }
}

extension GPX.Waypoint: MKAnnotation {
    
    var title: String? { return name }
    var subtitle: String? { return info }
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    
    var thumbnailURL: URL? { return getImageURLOfType("thumbnail") }
    var imageURL: URL? { return getImageURLOfType("large") }

    fileprivate func getImageURLOfType(_ type: String) -> URL? {
        for link in links {
            if link.type == type {
                return link.url as URL?
            }
        }
        return nil
    }

}
