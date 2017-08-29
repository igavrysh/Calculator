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
    var axesDrawer: AxesDrawer?
    weak var dataSource: GraphViewSource?
    
    let sampleGraph = SampleGraph()
    
    @IBInspectable
    public var origin: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var pointsPerUnit: CGFloat = 10
    
    @IBInspectable
    var graphCurveColor: UIColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpAxesDrawer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpAxesDrawer()
        
        centerOrigin()
    }
    
    override func draw(_ rect: CGRect) {
        let context =  UIGraphicsGetCurrentContext()
        context.do { $0.clear(rect) }
        
        if self.axesDrawer == nil {
            setUpAxesDrawer()
        }
        
        self.axesDrawer.do {
            $0.drawAxes(in: rect, origin: self.origin, pointsPerUnit: self.pointsPerUnit)
        }
        
        self.graphCurveColor.setStroke()
        
        let widthInPoints = Double(rect.width)
        
        let delta: Double = 1
        
        self.dataSource.do { dataSource in
            for xOffset in stride(from: 0, to: widthInPoints, by: delta) {
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
            }
        }
    }
    
    // MARK: Public
    
    public func centerOrigin() {
        let rect = self.bounds
        
        self.origin =  CGPoint(x: rect.width / 2, y: rect.height / 2)
    }
    
    // MARK: Private
    
    private func setUpAxesDrawer() {
        self.axesDrawer = AxesDrawer(color: self.graphCurveColor, contentScaleFactor: 50)
    }
    

    private func pointForScreenX(_ x: Double) -> CGPoint? {
        return self.dataSource
            .map { dataSource in
                return self.calculateFor(CGPoint(x: x, y: 0)) { dataSource.valueForX($0) }
            }
            .flatMap { point in
                return point.x.isFinite && point .y.isFinite ? point : nil
        }
    }
    
    private func transformFromScreenToOrigin() -> CGAffineTransform {
        return CGAffineTransform
            .init(a: 1 / self.pointsPerUnit,
                  b: 0,
                  c: 0,
                  d: -1 / self.pointsPerUnit,
                  tx: -self.origin.x / self.pointsPerUnit,
                  ty: self.origin.y / self.pointsPerUnit)
    }
    
    private func transformFromOriginToStreen() -> CGAffineTransform {
        return self.transformFromScreenToOrigin().inverted()
    }
    
    private func calculateFor(_ screenPoint: CGPoint, function: (Double) -> Double) -> CGPoint {
        var point = screenPoint.applying(self.transformFromScreenToOrigin().scaledBy(x: self.pointsPerUnit, y: self.pointsPerUnit))
        point.y = CGFloat(function(Double(point.x)))
        
        return point.applying(self.transformFromOriginToStreen())
    }
}
