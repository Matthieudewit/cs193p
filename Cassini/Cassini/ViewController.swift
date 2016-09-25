//
//  ViewController.swift
//  Cassini
//
//  Created by Vojta Molda on 3/10/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ivc = segue.destination as? ImageViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "Earth":
                    ivc.imageURL = DemoURL.NASA.Earth
                    ivc.title = "Earth"
                case "Cassini":
                    ivc.imageURL = DemoURL.NASA.Cassini
                    ivc.title = "Cassini"
                case "Saturn":
                    ivc.imageURL = DemoURL.NASA.Saturn
                    ivc.title = "Saturn"
                default:
                    break
                }
            }
        }
    }



}

