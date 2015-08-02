//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Vojta Molda on 8/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {
    
    var waypoint: GPX.MutableWaypoint? {
        didSet { updateUI() }
    }

    @IBOutlet weak var nameTextField: UITextField! {
        didSet { nameTextField.delegate = self }
    }
    var nameTextFieldObserver: NSObjectProtocol?

    @IBOutlet weak var infoTextField: UITextField! {
        didSet { infoTextField.delegate = self }
    }
    var infoTextFieldObserver: NSObjectProtocol?
    
    
    
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
    }
    
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
    
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
