//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Vojta Molda on 8/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import MobileCoreServices

class EditWaypointViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var waypoint: GPX.MutableWaypoint? {
        didSet { updateUI() }
    }


    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTextFields()
    }
    
    func updateUI() {
        nameTextField?.text = waypoint?.name
        infoTextField?.text = waypoint?.info
        updateImage()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let textFieldObserver = nameTextFieldObserver {
            NSNotificationCenter.defaultCenter().removeObserver(textFieldObserver)
        }
        if let textFieldObserver = infoTextFieldObserver {
            NSNotificationCenter.defaultCenter().removeObserver(textFieldObserver)
        }

    }
    

    // MARK: - Image view

    var imageView = UIImageView()
    
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            imageViewContainer.addSubview(imageView)
        }
    }

    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.mediaTypes = [String(kUTTypeImage)]
            picker.allowsEditing = true
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func saveImageInWaypoint() {
        if let image = imageView.image {
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                let fileManager = NSFileManager()
                if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                    let unique = NSDate.timeIntervalSinceReferenceDate()
                    let url = docsDir.URLByAppendingPathComponent("\(unique).jpg")
                    if imageData.writeToURL(url, atomically: true) {
                        waypoint?.links = [GPX.Link(href: url.absoluteString)]
                    }
                }
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        makeRoomForImage()
        saveImageInWaypoint()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Text fields
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet { nameTextField.delegate = self }
    }
    var nameTextFieldObserver: NSObjectProtocol?

    @IBOutlet weak var infoTextField: UITextField! {
        didSet { infoTextField.delegate = self }
    }
    var infoTextFieldObserver: NSObjectProtocol?

    func observeTextFields() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        nameTextFieldObserver = center.addObserverForName(UITextFieldTextDidChangeNotification,
            object: nameTextField,
            queue: queue) { notification in
                if let waypoint = self.waypoint {
                    waypoint.name = self.nameTextField.text
                }
        }
        infoTextFieldObserver = center.addObserverForName(UITextFieldTextDidChangeNotification,
            object: infoTextField,
            queue: queue) { notification in
                if let waypoint = self.waypoint {
                    waypoint.info = self.infoTextField.text
                }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}


extension EditWaypointViewController {
    func updateImage() {
        if let url = waypoint?.imageURL {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                if let imageData = NSData(contentsOfURL: url) {
                    if url == self?.waypoint?.imageURL {
                        if let image = UIImage(data: imageData) {
                            dispatch_async(dispatch_get_main_queue()) {
                                self?.imageView.image = image
                                self?.makeRoomForImage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // all we do in makeRoomForImage() is adjust our preferredContentSize
    // we assume that our preferredContentSize is what is currently desired (pre-adjustment)
    // then we adjust it to make up for any differences in the size of our image view or its container
    // if our preferredContentSize change can be accomodated, our container will get taller
    // and more of our image will show
    // if not, we tried our best to show as much of the image as possible
    // because we use the entire width of our container view and
    // show an appropriate height depending on our image's aspect ratio
    // this is sort of a "quick and dirty" way to do this
    // in a real application, one would probably want to be more exacting here
    // (perhaps apply more sophisticated autolayout to the problem)
    
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}


