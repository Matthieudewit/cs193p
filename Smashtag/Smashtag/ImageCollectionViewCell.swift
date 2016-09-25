//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/8/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var imageURL: URL? = nil {
        didSet {
            backgroundColor = UIColor.darkGray
            imageView.image = nil
            fetchImage()
        }
    }
    
    var cache: NSCache<AnyObject, AnyObject>?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    fileprivate func fetchImage() {
        if let url = imageURL {
            if let cacheImageData = cache?.object(forKey: url as AnyObject) as? Data {
                imageView.image = UIImage(data: cacheImageData)
            }
            spinner.startAnimating()
            let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            DispatchQueue.global(priority: qos).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [unowned self] in
                    if url == self.imageURL {
                        if imageData != nil {
                            self.imageView.image = UIImage(data: imageData!)
                            self.cache?.setObject(imageData!, forKey: url, cost: imageData!.count)
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
