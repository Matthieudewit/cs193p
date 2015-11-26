//
//  BreakoutDynamicBehavior.swift
//  Breakout
//
//  Created by Vojta Molda on 6/22/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

public enum BreakoutViewType: Int {
    case Ball = 1
    case Paddle
    case Brick
    case Boundary
}

public protocol BreakoutGameDelegate {
    func winGame() -> Void
    func endGame() -> Void
}

public extension UIView {
    var type: BreakoutViewType {
        get {
            return BreakoutViewType(rawValue: self.tag)!
        }
        set {
            self.tag = newValue.rawValue
        }
    }
}

class BreakoutGameBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    lazy private var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = false
        collider.collisionMode = UICollisionBehaviorMode.Everything
        collider.collisionDelegate = self
        return collider
        }()

    lazy private var ballBehavior: UIDynamicItemBehavior = {
        let ballBehavior = UIDynamicItemBehavior()
        ballBehavior.allowsRotation = false
        ballBehavior.density = 1.0
        ballBehavior.elasticity = 1.0
        ballBehavior.friction = 0.0
        ballBehavior.resistance = 0.0
        ballBehavior.angularResistance = 0.0
        return ballBehavior
        }()

    lazy private var paddleBehavior: UIDynamicItemBehavior = {
        let paddleBehavior = UIDynamicItemBehavior()
        paddleBehavior.allowsRotation = false
        paddleBehavior.density = 500.0
        paddleBehavior.elasticity = 1.0
        paddleBehavior.friction = 0.0
        paddleBehavior.resistance = 0.0
        paddleBehavior.angularResistance = 0.0
        return paddleBehavior
        }()

    lazy private var brickBehavior: UIDynamicItemBehavior = {
        let brickBehavior = UIDynamicItemBehavior()
        brickBehavior.allowsRotation = false
        brickBehavior.density = 100.0
        brickBehavior.elasticity = 1.0
        brickBehavior.friction = 0.0
        brickBehavior.resistance = 0.0
        brickBehavior.angularResistance = 0.0
        return brickBehavior
        }()

    lazy private var paddleAttachment: UIAttachmentBehavior? = nil

    lazy private var brickAttachments: [UIView: UIAttachmentBehavior] = [:]

    var delegate: BreakoutGameDelegate? = nil

    private struct Constants {
        struct Ball {
            static let MinVelocity = CGFloat(100.0)
            static let MaxVelocity = CGFloat(700.0)
        }
        struct Boundary {
            static let Top = "Top"
            static let Left = "Left"
            static let Right = "Right"
            static let Bottom = "Bottom"
        }
    }
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        addChildBehavior(paddleBehavior)
        addChildBehavior(brickBehavior)
    }

    func addView(view: UIView) {
        dynamicAnimator?.referenceView?.addSubview(view)
        collider.addItem(view)
        switch view.type {
            case .Ball:
                dynamicAnimator?.referenceView?.addSubview(view)
                ballBehavior.addItem(view)
            case .Paddle:
                dynamicAnimator?.referenceView?.addSubview(view)
                paddleAttachment = UIAttachmentBehavior(item: view, attachedToAnchor: view.center)
                paddleAttachment!.frequency = 1.0
                paddleAttachment!.damping = 0.5
                addChildBehavior(paddleAttachment!)
                paddleBehavior.addItem(view)
            case .Brick:
                brickAttachments[view] = UIAttachmentBehavior(item: view, attachedToAnchor: view.center)
                brickAttachments[view]!.frequency = 1.0
                brickAttachments[view]!.damping = 0.5
                addChildBehavior(brickAttachments[view]!)
                brickBehavior.addItem(view)
            default:
                return
        }
    }
    
    func createBoundary(view: UIView) {
        let topLeft = CGPoint(x: view.frame.minX, y: view.frame.minY)
        let topRight = CGPoint(x: view.frame.maxX, y: view.frame.minY)
        let bottomLeft = CGPoint(x: view.frame.minX, y: view.frame.maxY)
        let bottomRight = CGPoint(x: view.frame.maxX, y: view.frame.maxY)
        collider.addBoundaryWithIdentifier(Constants.Boundary.Top, fromPoint: topLeft, toPoint: topRight)
        collider.addBoundaryWithIdentifier(Constants.Boundary.Bottom, fromPoint: bottomLeft, toPoint: bottomRight)
        collider.addBoundaryWithIdentifier(Constants.Boundary.Left, fromPoint: topLeft, toPoint: bottomLeft)
        collider.addBoundaryWithIdentifier(Constants.Boundary.Right, fromPoint: topRight, toPoint: bottomRight)
    }
    
    func moveView(view: UIView, translation: CGPoint) {
        switch view.type {
        case .Paddle:
            let breakoutView = dynamicAnimator?.referenceView!
            view.center.x += translation.x
            view.center.x = max(view.center.x, breakoutView!.frame.minX + view.frame.width / 2)
            view.center.x = min(view.center.x, breakoutView!.frame.maxX - view.frame.width / 2)
            paddleAttachment?.anchorPoint.x = view.center.x
            dynamicAnimator?.updateItemUsingCurrentState(view)
        default:
            return
        }
    }

    func pushView(view: UIView, angle: CGFloat, magnitude: CGFloat) {
        let viewPush = UIPushBehavior(items: [view], mode: UIPushBehaviorMode.Instantaneous)
        viewPush.angle = angle
        viewPush.magnitude = magnitude
        viewPush.action = {
            viewPush.dynamicAnimator?.removeBehavior(viewPush)
        }
        dynamicAnimator?.addBehavior(viewPush)
    }
    
    func removeView(view: UIView, animated: Bool = true) {
        if animated == true {
            UIView.transitionWithView(view, duration: 1.0,
                options: .TransitionFlipFromTop,
                animations: { },
                completion: { (finished: Bool) -> Void in
                    self.removeView(view, animated: false)
            })
            return
        }
        switch view.type {
        case .Ball:
            ballBehavior.removeItem(view)
        case .Paddle:
            if paddleAttachment != nil {
                paddleBehavior.removeItem(view)
                removeChildBehavior(paddleAttachment!)
                paddleAttachment = nil
            } else { return }
        case .Brick:
            if brickAttachments[view] != nil {
                brickBehavior.removeItem(view)
                removeChildBehavior(brickAttachments[view]!)
                brickAttachments[view] = nil
            } else { return }
        default:
            return
        }
        collider.removeItem(view)
        view.removeFromSuperview()
    }
    
    private var pausedBallVelocity: CGPoint?

    func pauseGame() {
        if let ballView = ballBehavior.items.first as? UIView {
            pausedBallVelocity = ballBehavior.linearVelocityForItem(ballView)
            ballBehavior.addLinearVelocity(-pausedBallVelocity!, forItem: ballView)
        }
    }
    
    func resumeGame() {
        if let ballView = ballBehavior.items.first as? UIView {
            if pausedBallVelocity != nil {
                ballBehavior.addLinearVelocity(pausedBallVelocity!, forItem: ballView)
                pausedBallVelocity = nil
            }
        }
    }

    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        let (ballView, _, brickView) = collisionViewsForItems([item1, item2])
        if ballView != nil {
            ballBehavior.limitLinearVelocity(min: Constants.Ball.MinVelocity, max: Constants.Ball.MaxVelocity, forItem: ballView!)
        }
        if ballView != nil && brickView != nil {
            if brickAttachments.count == 1 {
                delegate?.winGame()
            }
            removeView(brickView!, animated: true)
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem) {
        let (ballView, paddleView, _) = collisionViewsForItems([item1, item2])
        if ballView != nil {
            ballBehavior.limitLinearVelocity(min: Constants.Ball.MinVelocity, max: Constants.Ball.MaxVelocity, forItem: ballView!)
        }
        if ballView != nil && paddleView != nil {
            ballBehavior.addLinearVelocity(CGPoint(x: 0.0, y: 10.0), forItem: ballView!)
        }
    }

    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        let (ballView, _, _) = collisionViewsForItems([item])
        if ballView != nil {
            ballBehavior.limitLinearVelocity(min: Constants.Ball.MinVelocity, max: Constants.Ball.MaxVelocity, forItem: ballView!)
        }
        if let boundaryName = identifier as? String {
            switch boundaryName {
            case Constants.Boundary.Bottom:
                if ballView != nil {
                    delegate?.endGame()
                }
            default:
                break
            }
        }
    }
    
    private func collisionViewsForItems(items: [UIDynamicItem]) -> (ballView: UIView?, paddleView: UIView?, brickView: UIView?) {
        var ballView: UIView? = nil
        var paddleView: UIView? = nil
        var brickView: UIView? = nil
        for item in items {
            if let view = item as? UIView {
                switch view.type {
                case .Ball:
                    ballView = view
                case .Paddle:
                    paddleView = view
                case .Brick:
                    brickView = view
                default:
                    break
                }
            }
        }
        return (ballView, paddleView, brickView)
    }
}

private extension UIDynamicItemBehavior {
    func limitLinearVelocity(min min: CGFloat, max: CGFloat, forItem item: UIDynamicItem) {
        assert(min < max, "min < max")
        let itemVelocity = linearVelocityForItem(item)
        if itemVelocity.magnitude == 0.0 { return }
        if itemVelocity.magnitude < min {
            let deltaVelocity = min/itemVelocity.magnitude * itemVelocity - itemVelocity
            addLinearVelocity(deltaVelocity, forItem: item)
        }
        if itemVelocity.magnitude > max  {
            let deltaVelocity = max/itemVelocity.magnitude * itemVelocity - itemVelocity
            addLinearVelocity(deltaVelocity, forItem: item)
        }
    }
}

private extension CGPoint {
    var angle: CGFloat {
        get { return CGFloat(atan2(self.x, self.y)) }
    }
    var magnitude: CGFloat {
        get { return CGFloat(sqrt(self.x*self.x + self.y*self.y)) }
    }
}

prefix func -(left: CGPoint) -> CGPoint {
    return CGPoint(x: -left.x, y: -left.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x-right.x, y: left.y-right.y)
}

func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left*right.x, y: left*right.y)
}