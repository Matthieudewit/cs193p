//
//  BezierPathsView.swift
//  Dropit
//
//  Created by Vojta Molda on 6/7/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {

    fileprivate var bezierPaths = [String:UIBezierPath]()
    
    func setPath(_ path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }

}
