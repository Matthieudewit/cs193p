//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Vojta Molda on 6/22/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController {
    
    @IBOutlet weak var breakoutView: UIView!
    
    lazy var breakoutBehavior = BreakoutDynamicBehavior()
    
    lazy var breakoutAnimator: UIDynamicAnimator = {
        let lazyBreakoutAnimator = UIDynamicAnimator(referenceView: self.breakoutView)
        return lazyBreakoutAnimator
    }()
    
    private var ballView: UIView?
    
    private var paddleView: UIView?
    
    private struct Constants {
        struct Ball {
            static let Size = CGSize(width: 25.0, height: 25.0)
            static let BackgroundColor = UIColor.redColor()
            static let BorderColor = UIColor.blackColor()
            static let BorderWidth = CGFloat(1.0)
        }
        struct Paddle {
            static let Size = CGSize(width: 100.0, height: 10.0)
            static let BackgroundColor = UIColor.greenColor()
            static let BorderColor = UIColor.blackColor()
            static let BorderWidth = CGFloat(1.0)
            static let BottomOffset = CGFloat(15.0)
        }
    }

    // MARK: View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        breakoutAnimator.addBehavior(breakoutBehavior)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        breakoutBehavior.addBoundary(breakoutView)

        let ballViewOrigin = CGPoint(x: breakoutView.bounds.midX - Constants.Ball.Size.width / 2,
                                     y: breakoutView.bounds.midY - Constants.Ball.Size.height / 2)
        ballView = UIView(frame: CGRect(origin: ballViewOrigin, size: Constants.Ball.Size))
        ballView!.layer.backgroundColor = Constants.Ball.BackgroundColor.CGColor
        ballView!.layer.borderColor = Constants.Ball.BorderColor.CGColor
        ballView!.layer.borderWidth = Constants.Ball.BorderWidth
        ballView!.layer.cornerRadius = Constants.Ball.Size.height / 2.0
        breakoutBehavior.addBall(ballView!)

        let paddleViewOrigin = CGPoint(x: breakoutView.bounds.midX - Constants.Paddle.Size.width / 2,
                                       y: breakoutView.bounds.maxY - Constants.Paddle.BottomOffset)
        paddleView = UIView(frame: CGRect(origin: paddleViewOrigin, size: Constants.Paddle.Size))
        paddleView!.layer.backgroundColor = Constants.Paddle.BackgroundColor.CGColor
        paddleView!.layer.borderColor = Constants.Paddle.BorderColor.CGColor
        paddleView!.layer.borderWidth = Constants.Paddle.BorderWidth
        paddleView!.layer.cornerRadius = Constants.Paddle.Size.height / 2
        breakoutBehavior.addPaddle(paddleView!)
        
    }

    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began: fallthrough
        case .Changed: fallthrough
        case .Ended:
            let translation = gesture.translationInView(breakoutView)
            paddleView!.center.x += translation.x
            paddleView!.bounds.origin.y = breakoutView.bounds.maxY - Constants.Paddle.BottomOffset
            gesture.setTranslation(CGPointZero, inView: breakoutView)
            breakoutAnimator.updateItemUsingCurrentState(paddleView!)
        default: break;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    


}
