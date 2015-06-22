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
        lazilyCreatedBlockBehavior.elasticity = 0.85
        lazilyCreatedBlockBehavior.friction = 0
        lazilyCreatedBlockBehavior.resistance = 0
        return lazilyCreatedBlockBehavior
        }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(blockBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBlock(block: UIView) {
        dynamicAnimator?.referenceView?.addSubview(block)
        gravity.addItem(block)
        collider.addItem(block)
        blockBehavior.addItem(block)
    }
    
    func removeBlock(block: UIView) {
        gravity.removeItem(block)
        collider.removeItem(block)
        blockBehavior.removeItem(block)
        block.removeFromSuperview()
    }

}
