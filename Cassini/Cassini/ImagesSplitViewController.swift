//
//  ImagesSplitViewController.swift
//  Cassini
//
//  Created by Vojta Molda on 6/29/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class ImagesSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    // MARK: - Split view controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }

}
