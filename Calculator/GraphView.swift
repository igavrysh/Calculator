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
                
                let path = UIBezierPath()
                path.move(to: calculatePoint(xOffset))
                path.addCurve(to: calculatePoint(xOffset + 1 * delta),
                              controlPoint1: calculatePoint(xOffset + 0.33 * delta),
                              controlPoint2: calculatePoint(xOffset + 0.66 * delta))
                path.stroke()
            }
        }
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
