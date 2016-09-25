//
//  HapinessViewController.swift
//  Hapiness
//
//  Created by Vojta Molda on 2/14/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class HapinessViewController: UIViewController, FaceViewDataSource {
    
    var happiness: Int = 100 { // 0 = very sad, 100 = ecstatic
        didSet {
            happiness = min(max(happiness, 0), 100)
            print("hapiness = \(happiness)")
            updateUI()
        }
    }

    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.dataSource = self
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: Selector(("scale:"))))
        }
    }
    
    fileprivate struct Constants {
        static let HappinessGestureScale: CGFloat = 4
    }
    
    @IBAction func changeHapiness(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended: fallthrough
        case .changed:
            let translation = gesture.translation(in: faceView)
            let happinessChange = Int(translation.y / Constants.HappinessGestureScale)
            if happinessChange != 0 {
                happiness += happinessChange
                gesture.setTranslation(CGPoint.zero, in: faceView)
            }
        default: break;
        }
    }

    fileprivate func updateUI() {
        faceView.setNeedsDisplay()
    }
    
    func smilinessForFaceView(_ sender: FaceView) -> Double? {
        return Double(happiness-50)/50
    }

}
