//
//  ImageScrollViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/5/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageScrollViewController: UIViewController, UIScrollViewDelegate {

    var image: UIImage {
        get { return imageView.image! }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
        }
    }
    
    private var imageView = UIImageView() {
        didSet {
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 3.0
            scrollView.addSubview(imageView)
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Scroll view delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
