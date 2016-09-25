//
//  GraphView.swift
//  Calculator
//
//  Created by Vojta Molda on 3/10/15.
//  Copyright (c) 2015 Vojta Molda. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yForX(_ x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {


    @IBInspectable
    var color: UIColor = UIColor.blue {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable
    var scale: CGFloat = 1.0 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable
    var origin: CGPoint = CGPoint.zero {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable
    var lineWidth: CGFloat = 2.0 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable
    var axesColor: UIColor = UIColor.black {
        didSet { setNeedsDisplay() }
    }
    
    var snapshot: UIView? = nil
    
    weak var dataSource: GraphViewDataSource?
    
    override func draw(_ rect: CGRect) {
        let graphCurve = UIBezierPath()
        var graphStart = true
        for rectX in Int(rect.minX)...Int(rect.maxX) {
            let graphX = (Double(rectX)-Double(origin.x))/Double(scale)
            if let graphY = dataSource?.yForX(graphX) {
                let rectY = origin.y-CGFloat(graphY)*scale
                let graphPoint = CGPoint(x: CGFloat(rectX), y: CGFloat(rectY))
                if graphStart == true {
                    graphCurve.move(to: graphPoint)
                    graphStart = false
                } else {
                    graphCurve.addLine(to: graphPoint)
                }
            } else {
                graphStart = true
            }
        }
        color.set()
        graphCurve.lineWidth = lineWidth
        graphCurve.stroke()
        
        let axesDrawer = AxesDrawer(color: axesColor, contentScaleFactor: super.contentScaleFactor)
        axesDrawer.drawAxesInRect(self.bounds, origin: origin, pointsPerUnit: scale)
    }
    
    func centerView(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let translation = gesture.location(in: self)
            origin.x = translation.x
            origin.y = translation.y
        default:
            break
        }
    }
    
    func moveView(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            snapshot = snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.7
            self.addSubview(snapshot!)
        case .changed:
            let translation = gesture.translation(in: self)
            snapshot!.center.x += translation.x
            snapshot!.center.y += translation.y
            gesture.setTranslation(CGPoint.zero, in: self)
        case .ended:
            origin.x += snapshot!.frame.origin.x
            origin.y += snapshot!.frame.origin.y
            snapshot!.removeFromSuperview()
            snapshot = nil
        default:
            break
        }
    }
    
    func zoomView(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            snapshot = snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.7
            snapshot!.center = origin
            self.addSubview(snapshot!)
        case .changed:
            let center = snapshot!.center
            snapshot!.bounds.size.width *= gesture.scale
            snapshot!.bounds.size.height *= gesture.scale
            snapshot!.center = center
            gesture.scale = 1.0
        case .ended:
            let scaleFactor = snapshot!.bounds.size.height / self.bounds.size.height
            scale *= scaleFactor
            snapshot!.removeFromSuperview()
            snapshot = nil
        default:
            break
        }
    }


}
