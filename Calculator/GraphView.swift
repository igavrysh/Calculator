//
//  GraphView.swift
//  Calculator
//
//  Created by Gavrysh on 8/25/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

protocol GraphViewSource : class {
    func valueForX(_ x: Double) -> Double
}

class SampleGraph: GraphViewSource {
    private var function = {(x: Double) -> Double in
        return pow(x, 2.0)
    }
    
    func valueForX(_ x: Double) -> Double {
        return self.function(x)
    }
}

@IBDesignable
class GraphView: UIView {
    lazy var axesDrawer = AxesDrawer(color: .black, contentScaleFactor: 50)
    weak var dataSource: GraphViewSource?
    
    let sampleGraph = SampleGraph()
    
    @IBInspectable
    var origin: CGPoint = CGPoint(x: 0, y: 0)
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 10
    
    @IBInspectable
    var graphCurveColor: UIColor = UIColor.black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
       // self.dataSource = self.sampleGraph
    }
    
    override func draw(_ rect: CGRect) {
        self.origin =  CGPoint(x :rect.width / 2, y: rect.height / 2)
        
        axesDrawer.drawAxes(in: rect, origin: self.origin, pointsPerUnit: self.pointsPerUnit)
        
        self.graphCurveColor.setStroke()
        
        let widthInPoints = Double(rect.width)
        
        let delta: Double = 1
        
        self.dataSource.do { dataSource in
            for xOffset in stride(from: 0, to: widthInPoints, by: delta) {
                let function = { (x: Double) -> Double in
                    return dataSource.valueForX(x)
                }
                
                let calculatePoint = { (x: Double) in
                    return self.calculateScreenPointForX(x, function: function)
                }
                
                lift((self.pointForScreenX(xOffset),
                     self.pointForScreenX(xOffset + 1 * delta),
                     self.pointForScreenX(xOffset + 0.33 * delta),
                     self.pointForScreenX(xOffset + 0.66 * delta)))
                    .map { tuple in
                        let path = UIBezierPath()
                        path.move(to: tuple.0)
                        path.addCurve(to: tuple.1, controlPoint1: tuple.2, controlPoint2: tuple.3)
                        path.stroke()
                }
                
                
                /*
                let path = UIBezierPath()
                let start = calculatePoint(xOffset)
                let end = calculatePoint(xOffset + 1 * delta)
                let interim1 = calculatePoint(xOffset + 0.33 * delta)
                let interim2 = calculatePoint(xOffset + 0.66 * delta)
                
                if start.y.isFinite && end.y.isFinite && interim1.y.isFinite && interim2.y.isFinite {
                    path.move(to: start)
                    path.addCurve(
                        to: end,
                        controlPoint1: interim1,
                        controlPoint2: interim2)
                    path.stroke()
                }
                 */
            }
        }
    }
    
    private func pointForScreenX(_ x: Double) -> CGPoint? {
        return self.dataSource
            .map { dataSource in
                return self.calculateFor(screenPoint: CGPoint(x: x, y: 0)) { dataSource.valueForX($0) }
            }
            .flatMap { point in
                return point.x.isFinite && point .y.isFinite ? point : nil
        }
    }
    
    private func transformFromScreenToOrigin() -> CGAffineTransform {
        return CGAffineTransform
            .init(a: 1, b: 0, c: 0, d: -1, tx: -self.origin.x, ty: self.origin.y)
            .scaledBy(x: 1/self.pointsPerUnit, y: 1/self.pointsPerUnit)
    }
    
    private func transformFromOriginToStreen() -> CGAffineTransform {
        return self.transformFromScreenToOrigin().inverted()
    }
    
    private func calculateFor(screenPoint: CGPoint, function: (Double) -> Double) -> CGPoint {
        var point = screenPoint.applying(self.transformFromScreenToOrigin().scaledBy(x: self.pointsPerUnit, y: self.pointsPerUnit))
        point.y = CGFloat(function(Double(point.x)))
        
        return point.applying(self.transformFromOriginToStreen())
    }
    
    private func calculateScreenPointForX(_ x: Double,  function: (Double) -> Double) -> CGPoint {
        let pointOnXAxis =  screenToDecard(CGPoint(x: CGFloat(x), y: origin.y))
        let xDecard = Double(pointOnXAxis.x)
        let yDecard = function(xDecard)
        let decardPoint = CGPoint(x: xDecard, y: yDecard)
        
        return decardToScreen(decardPoint)
    }
    
    private func screenToDecard(_ point: CGPoint) -> CGPoint {
        return CGPoint.init(x: (point.x - self.origin.x) / self.pointsPerUnit,
                            y: (self.origin.y - point.y) / self.pointsPerUnit)
    }
    
    private func decardToScreen(_ point: CGPoint) -> CGPoint {
        return CGPoint.init(x: point.x * self.pointsPerUnit + self.origin.x,
                            y: self.origin.y - point.y * self.pointsPerUnit)
    }
    
}
