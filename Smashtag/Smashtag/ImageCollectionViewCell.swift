//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/8/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var imageURL: NSURL? = nil {
        didSet {
            backgroundColor = UIColor.darkGrayColor()
            imageView.image = nil
            fetchImage()
        }
    }
    
    var cache: NSCache?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private func fetchImage() {
        if let url = imageURL {
            if let cacheImageData = cache?.objectForKey(url) as? NSData {
                imageView.image = UIImage(data: cacheImageData)
            }
            spinner.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    if url == self.imageURL {
                        if imageData != nil {
                            self.imageView.image = UIImage(data: imageData!)
                            self.cache?.setObject(imageData!, forKey: url, cost: imageData!.length)
                        } else {
                            self.imageView.image = nil
                        }
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }

}
