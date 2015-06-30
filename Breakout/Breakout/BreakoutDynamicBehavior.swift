//
//  BreakoutDynamicBehavior.swift
//  Breakout
//
//  Created by Vojta Molda on 6/22/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class BreakoutDynamicBehavior: UIDynamicBehavior {
    
    lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = false
        return lazyCollider
        }()

    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazyBallBehavior = UIDynamicItemBehavior()
        lazyBallBehavior.allowsRotation = true
        lazyBallBehavior.elasticity = 0.9
        lazyBallBehavior.friction = 0.0
        lazyBallBehavior.resistance = 0.0
        return lazyBallBehavior
        }()

    lazy var brickBehavior: UIDynamicItemBehavior = {
        let lazyBrickBehavior = UIDynamicItemBehavior()
        lazyBrickBehavior.allowsRotation = false
        lazyBrickBehavior.density = 1.0
        lazyBrickBehavior.elasticity = 0.9
        lazyBrickBehavior.friction = 0.0
        lazyBrickBehavior.resistance = 0.0
        return lazyBrickBehavior
        }()
    
    lazy var brickAttachment: UIAttachmentBehavior = {
        let lazyBrickAttachment = UIAttachmentBehavior()
        lazyBrickAttachment.frequency = 1.0
        lazyBrickAttachment.damping = 0.5
        lazyBrickAttachment.frictionTorque = 0.0
        return lazyBrickAttachment
        }()
    
    lazy var paddleBehavior: UIDynamicItemBehavior = {
        let lazyPaddleBehavior = UIDynamicItemBehavior()
        lazyPaddleBehavior.allowsRotation = false
        lazyPaddleBehavior.density = 100.0
        lazyPaddleBehavior.elasticity = 1.0
        lazyPaddleBehavior.friction = 0.5
        lazyPaddleBehavior.resistance = 0.5
        return lazyPaddleBehavior
        }()

    lazy var paddleSnap: UISnapBehavior = {
        let lazyPaddleSnap = UISnapBehavior()
        lazyPaddleSnap.damping = 0.5
        return lazyPaddleSnap
        }()

    struct Boundaries {
        static let Top = "Top"
        static let Left = "Left"
        static let Right = "Right"
        static let Bottom = "Bottom"
    }
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        addChildBehavior(brickBehavior)
        addChildBehavior(paddleBehavior)
    }

    func addBrick(view: UIView) {
        dynamicAnimator?.referenceView?.addSubview(view)
        collider.addItem(view)
        brickBehavior.addItem(view)
    }
    
    func removeBrick(view: UIView) {
        brickBehavior.removeItem(view)
        collider.removeItem(view)
        view.removeFromSuperview()
    }
    
    func addBall(view: UIView) {
        dynamicAnimator?.referenceView?.addSubview(view)
        collider.addItem(view)
        ballBehavior.addItem(view)
    }
    
    func pushBall(view: UIView) {
        
    }
    
    func removeBall(view: UIView) {
        ballBehavior.removeItem(view)
        collider.removeItem(view)
        view.removeFromSuperview()
    }
    
    func addPaddle(view: UIView) {
        dynamicAnimator?.referenceView?.addSubview(view)
        collider.addItem(view)
        paddleBehavior.addItem(view)
    }
    
    func removePaddle(view: UIView) {
        paddleBehavior.removeItem(view)
        collider.removeItem(view)
        view.removeFromSuperview()
    }

    func addBoundary(view: UIView) {
        let topLeft = CGPoint(x: view.bounds.minX, y: view.bounds.minY)
        let topRight = CGPoint(x: view.bounds.maxX, y: view.bounds.minY)
        let bottomLeft = CGPoint(x: view.bounds.minX, y: view.bounds.maxY)
        let bottomRight = CGPoint(x: view.bounds.maxX, y: view.bounds.maxY)

        collider.addBoundaryWithIdentifier(Boundaries.Top, fromPoint: topLeft, toPoint: topRight)
        collider.addBoundaryWithIdentifier(Boundaries.Bottom, fromPoint: bottomLeft, toPoint: bottomRight)
        collider.addBoundaryWithIdentifier(Boundaries.Left, fromPoint: topLeft, toPoint: bottomLeft)
        collider.addBoundaryWithIdentifier(Boundaries.Right, fromPoint: topRight, toPoint: bottomRight)
    }

}
