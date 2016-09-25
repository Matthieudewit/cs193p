//
//  DiagnosedHappinessViewController.swift
//  Psychologist
//
//  Created by Vojta Molda on 2/24/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class DiagnosedHappinessViewController: HapinessViewController, UIPopoverPresentationControllerDelegate {

    fileprivate let defaults = UserDefaults.standard
    
    var diagnosticHistory: [Int] {
        get { return defaults.object(forKey: History.DefaultsKey) as? [Int] ?? [] }
        set { defaults.set(newValue, forKey: History.DefaultsKey) }
    }

    override var happiness: Int {
        didSet {
            diagnosticHistory += [happiness]
        }
    }

    
    fileprivate struct History {
        static let SegueIdentifier = "Show Diagnostic History"
        static let DefaultsKey = "DiagnosedHappinessViewController.History"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case History.SegueIdentifier:
                if let tvc = segue.destination as? TextViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                    tvc.text = "\(diagnosticHistory)"
                }
            default: break
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

}
