//
//  BouncerDynamicBehavior.swift
//  Bouncer
//
//  Created by Vojta Molda on 6/21/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class BouncerDynamicBehavior: UIDynamicBehavior {
    let gravity = UIGravityBehavior()
    
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollisionBehavior = UICollisionBehavior()
        lazilyCreatedCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedCollisionBehavior
        }()
    
    lazy var blockBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBlockBehavior = UIDynamicItemBehavior()
        lazilyCreatedBlockBehavior.allowsRotation = true
        lazilyCreatedBlockBehavior.elasticity = CGFloat(UserDefaults.standard.double(forKey: "BouncerBehavior.Elasticity"))
        lazilyCreatedBlockBehavior.friction = 0
        lazilyCreatedBlockBehavior.resistance = 0
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { (notification) -> Void in
                lazilyCreatedBlockBehavior.elasticity = CGFloat(UserDefaults.standard.double(forKey: "BounderBehavior.Elasticity"))
        }
        return lazilyCreatedBlockBehavior
        }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(blockBehavior)
    }
    
    func addBarrier(_ path: UIBezierPath, named name: String) {
        collider.removeBoundary(withIdentifier: name as NSCopying)
        collider.addBoundary(withIdentifier: name as NSCopying, for: path)
    }
    
    func addBlock(_ block: UIView) {
        dynamicAnimator?.referenceView?.addSubview(block)
        gravity.addItem(block)
        collider.addItem(block)
        blockBehavior.addItem(block)
    }
    
    func removeBlock(_ block: UIView) {
        gravity.removeItem(block)
        collider.removeItem(block)
        blockBehavior.removeItem(block)
        block.removeFromSuperview()
    }

}
