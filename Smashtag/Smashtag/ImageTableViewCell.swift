//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Vojta Molda on 5/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    var cellImageURL: NSURL? {
        didSet {
            if let url = cellImageURL {
                let qos = Int(QOS_CLASS_USER_INITIATED.value)
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    let imageData = NSData(contentsOfURL: url)
                    dispatch_async(dispatch_get_main_queue()) {
                        if url == self.cellImageURL {
                            if imageData != nil {
                                self.cellImageView?.image = UIImage(data: imageData!)
                            } else {
                                self.cellImageView?.image = nil
                            }
                        }
                    }
                }
                
                if let data = NSData(contentsOfURL: cellImageURL!) {
                    let cellImage = UIImage(data: data)
                    cellImageView.image = cellImage
                }
            }
        }
    }

    @IBOutlet weak var cellImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }

}
 