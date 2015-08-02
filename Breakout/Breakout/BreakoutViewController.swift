//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Vojta Molda on 6/22/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, BreakoutGameDelegate {
    
    @IBOutlet weak var breakoutView: UIView!
    
    lazy var breakoutGame: BreakoutGameBehavior = {
        let lazyBreakoutGame = BreakoutGameBehavior()
        lazyBreakoutGame.delegate = self
        return lazyBreakoutGame
    }()

    lazy var breakoutAnimator: UIDynamicAnimator = {
        let lazyBreakoutAnimator = UIDynamicAnimator(referenceView: self.breakoutView)
        return lazyBreakoutAnimator
    }()
    
    private var ballView: UIView? = nil
    
    private var paddleView: UIView? = nil
    
    private var brickViews: [[UIView]] = [[]]

    private struct Constants {
        struct Ball {
            static var Size: CGSize { return CGSize(width: AppDelegate.Settings.Ball.Size, height: AppDelegate.Settings.Ball.Size) }
            static var StartSpreadAngle: CGFloat { return AppDelegate.Settings.Ball.StartSpreadAngle }
            static let BackgroundColor = UIColor.redColor()
            static let BorderColor = UIColor.blackColor()
            static let BorderWidth = CGFloat(1.0)
            static let BottomOffset = CGFloat(40.0)
        }
        struct Paddle {
            static let Size = CGSize(width: 100.0, height: 10.0)
            static let BackgroundColor = UIColor.greenColor()
            static let BorderColor = UIColor.blackColor()
            static let BorderWidth = CGFloat(1.0)
            static let BottomOffset = CGFloat(15.0)
        }
        struct Brick {
            static var Rows: Int { return AppDelegate.Settings.Brick.Rows }
            static var Columns: Int { return AppDelegate.Settings.Brick.Columns }
            static let Gap = CGFloat(10.0)
            static let Height = CGFloat(30.0)
            static let BackgroundColor = UIColor.blueColor()
            static let BorderColor = UIColor.blackColor()
            static let BorderWidth = CGFloat(1.0)
            static let TopOffset = CGFloat(100.0)
        }
    }

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        breakoutAnimator.addBehavior(breakoutGame)
    }
    
    override func viewWillAppear(animated: Bool) {
        breakoutGame.resumeGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startGame()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        breakoutGame.pauseGame()
    }

    @IBAction func moveBall(tapGesture: UITapGestureRecognizer) {
        switch tapGesture.state {
        case .Ended:
            let angleBasePart = CGFloat(M_PI/2)
            let angleRandomSpread = CGFloat(Float(arc4random()) / Float(UINT32_MAX) - 0.5) * Constants.Ball.StartSpreadAngle
            let angle = angleBasePart + angleRandomSpread
            let magnitude = CGFloat(0.5)
            breakoutGame.pushView(ballView!, angle: angle, magnitude: magnitude)
        default:
            break
        }
    }

    @IBAction func movePaddle(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .Began: fallthrough
        case .Changed: fallthrough
        case .Ended:
            let translation = panGesture.translationInView(breakoutView)
            breakoutGame.moveView(paddleView!, translation: translation)
            panGesture.setTranslation(CGPointZero, inView: breakoutView)
        default:
            break
        }
    }
    
    // MARK: - Breakout game
    
    func startGame() {
        for view in breakoutView.subviews {
            breakoutGame.removeView(view, animated: false)
        }

        breakoutView.type = BreakoutViewType.Boundary
        breakoutGame.createBoundary(breakoutView)
        
        let ballViewOrigin = CGPoint(x: breakoutView.bounds.midX - Constants.Ball.Size.width / 2,
            y: breakoutView.bounds.maxY - Constants.Ball.BottomOffset - Constants.Ball.Size.height / 2)
        ballView = UIView(frame: CGRect(origin: ballViewOrigin, size: Constants.Ball.Size))
        ballView!.layer.backgroundColor = Constants.Ball.BackgroundColor.CGColor
        ballView!.layer.borderColor = Constants.Ball.BorderColor.CGColor
        ballView!.layer.borderWidth = Constants.Ball.BorderWidth
        ballView!.layer.cornerRadius = Constants.Ball.Size.height / 2.0
        ballView!.type = BreakoutViewType.Ball
        breakoutGame.addView(ballView!)
        
        let paddleViewOrigin = CGPoint(x: breakoutView.bounds.midX - Constants.Paddle.Size.width / 2,
            y: breakoutView.bounds.maxY - Constants.Paddle.BottomOffset)
        paddleView = UIView(frame: CGRect(origin: paddleViewOrigin, size: Constants.Paddle.Size))
        paddleView!.layer.backgroundColor = Constants.Paddle.BackgroundColor.CGColor
        paddleView!.layer.borderColor = Constants.Paddle.BorderColor.CGColor
        paddleView!.layer.borderWidth = Constants.Paddle.BorderWidth
        paddleView!.layer.cornerRadius = Constants.Paddle.Size.height / 2
        paddleView!.type = BreakoutViewType.Paddle
        breakoutGame.addView(paddleView!)
        
        let brickViewSize = CGSize(width: (breakoutView.bounds.width - Constants.Brick.Gap * CGFloat(Constants.Brick.Columns + 1))
            / CGFloat(Constants.Brick.Columns),
            height: Constants.Brick.Height)
        brickViews.reserveCapacity(Constants.Brick.Rows)
        for row in 0 ..< Constants.Brick.Rows {
            var bricksColumn: [UIView] = []
            bricksColumn.reserveCapacity(Constants.Brick.Columns)
            for column in 0 ..< Constants.Brick.Columns {
                let brickViewOrigin = CGPoint(x: Constants.Brick.Gap + (brickViewSize.width + Constants.Brick.Gap) * CGFloat(column),
                    y:  Constants.Brick.TopOffset + (brickViewSize.height + Constants.Brick.Gap) * CGFloat(row))
                let brickView = UIView(frame: CGRect(origin: brickViewOrigin, size: brickViewSize))
                brickView.layer.backgroundColor = Constants.Brick.BackgroundColor.CGColor
                brickView.layer.borderColor = Constants.Brick.BorderColor.CGColor
                brickView.layer.borderWidth = Constants.Brick.BorderWidth
                brickView.layer.cornerRadius = Constants.Brick.Height / 4.0
                brickView.type = BreakoutViewType.Brick
                bricksColumn.insert(brickView, atIndex: column)
                breakoutGame.addView(brickView)
            }
            brickViews.insert(bricksColumn, atIndex: row)
        }
    }
    
    func winGame() {
        let alert = UIAlertController(title: "Victory :)", message: "No more bricks left to hit!", preferredStyle: UIAlertControllerStyle.Alert)
        let newGameAction = UIAlertAction(title: "New Game", style: UIAlertActionStyle.Cancel) {
            (action: UIAlertAction!) -> Void in
                self.startGame()
        }
        alert.addAction(newGameAction)
        breakoutGame.pauseGame()
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func endGame() {
        let alert = UIAlertController(title: "Game Over :(", message: "The ball fell through the bottom of the screen!", preferredStyle: UIAlertControllerStyle.Alert)
        let newGameAction = UIAlertAction(title: "New Game", style: UIAlertActionStyle.Cancel) {
            (action: UIAlertAction!) -> Void in
                self.startGame()
        }
        alert.addAction(newGameAction)
        if AppDelegate.Settings.Game.ContinueAfterGameOver == true {
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                self.breakoutGame.resumeGame()
            }
            alert.addAction(continueAction)
        }
        breakoutGame.pauseGame()
        presentViewController(alert, animated: true, completion: nil)
    }

}
