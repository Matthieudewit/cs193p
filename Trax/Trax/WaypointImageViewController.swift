//
//  WaypointImageViewController.swift
//  Trax
//
//  Created by Vojta Molda on 8/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class WaypointImageViewController: ImageViewController {
    
    var waypoint: GPX.Waypoint? {
        didSet {
            imageURL = waypoint?.imageURL
            title = waypoint?.name
            updateEmbeddedMap()
        }
    }
    
    var simpleMapViewController: SimpleMapViewController?
    
    func updateEmbeddedMap() {
        if let mapView = simpleMapViewController?.mapView {
            mapView.mapType = .Hybrid
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(waypoint)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Embed Map" {
            simpleMapViewController = segue.destinationViewController as? SimpleMapViewController
            updateEmbeddedMap()
        }
    }

}