//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Vojta Molda on 5/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    var imageURL: URL? {
        didSet {
            largeImageView.image = nil
            fetchImage()
        }
    }

    @IBOutlet weak var largeImageView: UIImageView!

    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = UITableViewCellAccessoryType.disclosureIndicator
    }
    
    fileprivate func fetchImage() {
        if let url = imageURL {
            spinner.startAnimating()
            let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            DispatchQueue.global(priority: qos).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async {
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
