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
            mapView.mapType = .satellite
            mapView.delegate = self
        }
    }
    
    var gpxURL: URL? {
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

    fileprivate struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "Waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWayponintPopoverWidth = CGFloat(320)
    }
    
    fileprivate func clearWaypoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    fileprivate func handleWaypoints(_ waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let appDelegate = UIApplication.shared.delegate
        center.addObserver(forName: NSNotification.Name(rawValue: GPXURL.Notification), object: appDelegate, queue: queue) { notification in
            if let url = (notification as NSNotification).userInfo?[GPXURL.Key] as? URL {
                self.gpxURL = url
            }
        }
        
        gpxURL = URL(string: "http://cs193p.stanford.edu/Vacation.gpx");
    }
    
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let waypoint = GPX.MutableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            waypoint.links.append(GPX.Link(href: "http://cs193p.stanford.edu/Images/Panorama.jpg"))
            mapView.addAnnotation(waypoint)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nil { return }
        switch segue.identifier! {
        case Constants.ShowImageSegue :
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let waypointImageViewController = segue.destination.contentViewController as? WaypointImageViewController {
                    waypointImageViewController.waypoint = waypoint
                } else if let imageViewController = segue.destination.contentViewController as? ImageViewController {
                    imageViewController.imageURL = waypoint.imageURL
                    imageViewController.title = waypoint.name
                }
            }
        case Constants.EditWaypointSegue:
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.MutableWaypoint {
                if let editWaypointViewController = segue.destination.contentViewController as? EditWaypointViewController {
                    if let popoverPresentationController = editWaypointViewController.popoverPresentationController {
                        let coordinatePoint = mapView.convert(waypoint.coordinate, toPointTo: mapView)
                        popoverPresentationController.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint)
                        let minimumSize = editWaypointViewController.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        annotationView!.isDraggable = annotation is GPX.MutableWaypoint

        annotationView!.leftCalloutAccessoryView = nil
        annotationView!.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                annotationView!.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            if annotation is GPX.MutableWaypoint {
                annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
            }
        }
        return annotationView!
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let waypoint = view.annotation as? GPX.Waypoint {
            if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                if let imageData = try? Data(contentsOf: waypoint.thumbnailURL! as URL) { // Blocks main thread
                    if let image = UIImage(data: imageData) {
                        thumbnailImageButton.setImage(image, for: UIControlState())
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let buttonType = (control as? UIButton)?.buttonType {
            switch buttonType {
            case UIButtonType.detailDisclosure:
                mapView.deselectAnnotation(view.annotation, animated: false)
                performSegue(withIdentifier: Constants.EditWaypointSegue, sender: view)
            default:
                performSegue(withIdentifier: Constants.ShowImageSegue, sender: view)
            }
        }
    }
    
    // MARK: Popover presentation controller delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navigationController.view.bounds
        navigationController.view.insertSubview(visualEffectView, at: 0)
        return navigationController
    }
}


extension UIViewController {
    var contentViewController: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController!
        } else {
            return self
        }
    }
}

extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(_ coordinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coordinatePoint
        popoverSourceRectCenter.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
    }
}


