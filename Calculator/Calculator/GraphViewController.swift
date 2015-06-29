//
//  GraphViewController.swift
//  Calculator
//
//  Created by Vojta Molda on 3/10/15.
//  Copyright (c) 2015 Vojta Molda. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            statistics.reset()
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "centerView:")
            tapGestureRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGestureRecognizer)
            let moveGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
            graphView.addGestureRecognizer(moveGestureRecognizer)
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "zoomView:")
            graphView.addGestureRecognizer(pinchGestureRecognizer)
        }
    }

    @IBOutlet weak var navigationHeader: UINavigationItem!

    private var brain = CalculatorBrain()
    
    private class Statistics: CustomStringConvertible {
        var max: Double? = nil
        var avg: Double? = nil
        var min: Double? = nil
        var description: String {
            get { return "Maximal value: \(max ?? 0.0)\n" + "Average value: \(avg ?? 0.0)\n" + "Minimal value: \(min ?? 0.0)" }
        }
        func reset() {
            self.max = nil
            self.avg = nil
            self.min = nil
        }
    }
    private var statistics = Statistics()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private struct Keys {
        static let Scale = "GraphViewController.Scale"
        static let Origin = "GraphViewController.Origin.x"
    }
    
    var scale: CGFloat {
        get { return defaults.objectForKey(Keys.Scale) as? CGFloat ?? 1.0 }
        set { defaults.setObject(newValue, forKey: Keys.Scale) }
    }
    
    private var origin: CGPoint {
        get {
            if let originArray = defaults.objectForKey(Keys.Origin) as? [CGFloat] {
                return CGPoint(x: originArray.first!, y: originArray.last!)
            } else {
                return CGPointZero
            }
        }
        set { defaults.setObject([newValue.x, newValue.y], forKey: Keys.Origin) }
    }
    
    var program: AnyObject {
        get { return brain.program }
        set {
            brain.program = newValue
            navigationHeader.title = brain.descriptionOfLastTerm
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Statistics":
                if let statisticsViewController = segue.destinationViewController as? StatisticsViewController {
                    if let popoverPresentationController = statisticsViewController.popoverPresentationController {
                        popoverPresentationController.delegate = self
                    }
                    statisticsViewController.text = "\(statistics)"
                }
            default: break
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        statistics.reset()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        graphView.origin = view.center
    }
    
    func centerView(gesture: UITapGestureRecognizer) {
        graphView.centerView(gesture)
        statistics.reset()
        if gesture.state == .Ended {
            origin = graphView.origin
        }
    }
    
    func moveView(gesture: UIPanGestureRecognizer) {
        graphView.moveView(gesture)
        statistics.reset()
        if gesture.state == .Ended {
            origin = graphView.origin
        }
    }
    
    func zoomView(gesture: UIPinchGestureRecognizer) {
        graphView.zoomView(gesture)
        statistics.reset()
        if gesture.state == .Ended {
            scale = graphView.scale
            origin = graphView.origin
        }
    }

    func yForX(x: Double) -> Double? {
        brain.variableValues["M"] = x
        if let y = brain.evaluate() {
            statistics.max = statistics.max == nil ? y : max(statistics.max!, y)
            statistics.avg = statistics.avg == nil ? y : (statistics.avg!+y)/2.0
            statistics.min = statistics.min == nil ? y : min(statistics.min!, y)
            return y
        }
        return nil
    }
    
}
