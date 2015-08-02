//
//  GPXViewController.swift
//  Trax
//
//  Created by Vojta Molda on 6/21/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    var gpxURL: NSURL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                GPX.parse(url) {
                    if let gpx = $0 {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }

    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "Waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWayponintPopoverWidth = CGFloat(320)
    }
    
    private func clearWaypoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations as? [MKAnnotation])
        }
    }
    
    private func handleWaypoints(waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        center.addObserverForName(GPXURL.Notification, object: appDelegate, queue: queue) { notification in
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL {
                self.gpxURL = url
            }
        }
        
        gpxURL = NSURL(string: "http://cs193p.stanford.edu/Vacation.gpx");
    }
    
    
    @IBAction func addWaypoint(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = GPX.MutableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            waypoint.links.append(GPX.Link(href: "http://cs193p.stanford.edu/Images/Panorama.jpg"))
            mapView.addAnnotation(waypoint)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Constants.ShowImageSegue :
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let waypointImageViewController = segue.destinationViewController.contentViewController as? WaypointImageViewController {
                    waypointImageViewController.waypoint = waypoint
                } else if let imageViewController = segue.destinationViewController.contentViewController as? ImageViewController {
                    imageViewController.imageURL = waypoint.imageURL
                    imageViewController.title = waypoint.name
                }
            }
        case Constants.EditWaypointSegue:
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.MutableWaypoint {
                if let editWaypointViewController = segue.destinationViewController.contentViewController as? EditWaypointViewController {
                    if let popoverPresentationController = editWaypointViewController.popoverPresentationController {
                        let coordinatePoint = mapView.convertCoordinate(waypoint.coordinate, toPointToView: mapView)
                        popoverPresentationController.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint)
                        let minimumSize = editWaypointViewController.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                        editWaypointViewController.preferredContentSize = CGSize(width: Constants.EditWayponintPopoverWidth, height: minimumSize.height)
                        popoverPresentationController.delegate = self
                        
                    }
                    editWaypointViewController.waypoint = waypoint
                }
            }
        default:
            return
        }
    }

    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        
        view.draggable = annotation is GPX.MutableWaypoint

        view.leftCalloutAccessoryView = nil
        view.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            if annotation is GPX.MutableWaypoint {
                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
            }
        }

        return view
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let waypoint = view.annotation as? GPX.Waypoint {
            if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                if let imageData = NSData(contentsOfURL: waypoint.thumbnailURL!) { // Blocks main thread
                    if let image = UIImage(data: imageData) {
                        thumbnailImageButton.setImage(image, forState: .Normal)
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier(Constants.EditWaypointSegue, sender: view)
        } else if let imageURL = (view.annotation as? GPX.Waypoint)?.imageURL {
            performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
        }
    }
    
    // MARK: Popover presentation controller delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        visualEffectView.frame = navigationController.view.bounds
        navigationController.view.insertSubview(visualEffectView, atIndex: 0)
        return navigationController
    }
}


extension UIViewController {
    var contentViewController: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController
        } else {
            return self
        }
    }
}

extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(coordinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coordinatePoint
        popoverSourceRectCenter.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
    }
}


