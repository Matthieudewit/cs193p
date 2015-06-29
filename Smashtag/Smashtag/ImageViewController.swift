//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/5/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.bounds.size
            spinner?.stopAnimating()
        }
    }
    
    var imageURL: NSURL? = nil

    private var imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = imageView.frame.size
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 3.0
            scrollView.addSubview(imageView)
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if image == nil {
            fetchImage()
        }
    }

    func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if imageData != nil {
                            self.image = UIImage(data: imageData!)
                        } else {
                            self.image = nil
                        }
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Scroll view delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
