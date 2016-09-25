//
//  ViewController.swift
//  Autolayout
//
//  Created by Vojta Molda on 3/9/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lastLoginLabel: UILabel!

    var loggedInUser: User? {
        didSet { updateUI() }
    }
    var secure: Bool = false {
        didSet { updateUI() }
    }
    var aspectRatioConstraint: NSLayoutConstraint? {
        willSet {
            if let existingConstraint = aspectRatioConstraint {
                view.removeConstraint(existingConstraint)
            }
        }
        didSet {
            if let newConstraint = aspectRatioConstraint {
                view.addConstraint(newConstraint)
            }
        }
    }
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            if let constrainedView = imageView {
                if let newImage = newValue {
                    aspectRatioConstraint = NSLayoutConstraint(
                        item: constrainedView,
                        attribute: .width,
                        relatedBy: .equal,
                        toItem: constrainedView,
                        attribute: .height,
                        multiplier: newImage.aspectRatio,
                        constant: 0)
                } else {
                    aspectRatioConstraint = nil
                }
            }
        }
    }
    
    fileprivate struct AlertStrings {
        struct LoginError {
            static let Title = NSLocalizedString("Login Error",
                comment: "Title of alert when user types in an incorrect user name or password")
            static let Message = NSLocalizedString("Invalid user name or password",
                comment: "Message in an alert when the user types in an incorrect user name or password")
            static let DismissButton = NSLocalizedString("Try Again",
                comment: "The only button available in an alert presented when the user types incorrect user name or password")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    fileprivate func updateUI() {
        passwordField.isSecureTextEntry = secure
        let password = NSLocalizedString("Password", comment: "Prompt for a password when it is not secure (i.e. plain text)")
        let securedPassword = NSLocalizedString("Secure Password", comment: "Prompt for a password when it is secure (i.e. obscured)")
        passwordLabel.text = secure ? securedPassword : password
        nameLabel.text = loggedInUser?.name
        companyLabel.text = loggedInUser?.company
        image = loggedInUser?.image
        if let lastLogin = loggedInUser?.lastLogin {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            dateFormatter.dateStyle = DateFormatter.Style.none
            let time = dateFormatter.string(from: lastLogin as Date)
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            let daysAgo = numberFormatter.string(from: NSNumber(value: lastLogin.timeIntervalSinceNow/(60*60*24)))!
            let lastLoginFormatString = NSLocalizedString("Last Login %@ days ago at %@", comment: "Report the number of days ago and time the use last logged in")
            lastLoginLabel.text = String.localizedStringWithFormat(lastLoginFormatString, daysAgo, time)
        } else {
            lastLoginLabel.text = ""
        }
    }
    
    @IBAction func login() {
        loggedInUser = User.login(loginField.text ?? "", password: passwordField.text ?? "")
        if loggedInUser == nil {
            let alert = UIAlertController(title: AlertStrings.LoginError.Title, message: AlertStrings.LoginError.Message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: AlertStrings.LoginError.DismissButton, style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func toggleSecurity() {
        secure = !secure
    }
}


extension User {
    var image: UIImage? {
        return UIImage(named: login) ?? UIImage(named: "unknown_user")
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width/size.height : 0
    }
}
