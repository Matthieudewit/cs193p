//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Vojta Molda on 5/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    var imageURL: NSURL? {
        didSet {
            largeImageView.image = nil
            fetchImage()
        }
    }

    @IBOutlet weak var largeImageView: UIImageView!

    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
    
    private func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if imageData != nil {
                            self.largeImageView.image = UIImage(data: imageData!)
                        } else {
                            self.largeImageView.image = nil
                        }
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }

}
