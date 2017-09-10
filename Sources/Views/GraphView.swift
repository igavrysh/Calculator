//
//  GraphView.swift
//  Calculator
//
//  Created by Gavrysh on 8/25/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    var axesDrawer: AxesDrawer?
    
    private var moveOriginWithNewPoint: ((CGPoint) -> ())? = nil
    private var scaleWithValue: ((CGFloat) -> Void)? = nil
    
    private var drawRect: CGRect?
    
    public var function: ((Double) -> Double)? {
        didSet {
            var valuesCache: [Double: Double] = [:]
            
            func round(value: Double, precision: Double) -> Double {
                return floor(value * precision) / precision
            }
            
            function.map { newFunction in
                self.ifunction = { (x: Double, pointsPerUnit: Double) in
                    let xDash = round(value: x, precision: pointsPerUnit)
                    
                    if let y = valuesCache[xDash] {
                        return y
                    }
                    
                    let y = newFunction(xDash)
                    
                    valuesCache[xDash] = y
                    
                    return y
                }
            }
        }
    }
    
    private var ifunction: ((_ x: Double, _ pointsPerUnit: Double) -> Double)?
    
    @IBInspectable
    public var origin: CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var pointsPerUnit: CGFloat = 10 {
        didSet {
            setupAxesDrawer()
            
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var graphCurveColor: UIColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupGraphView()
        setupAxesDrawer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGraphView()
        setupAxesDrawer()
    }
    
    override func draw(_ rect: CGRect) {
        self.drawRect = rect
        
        let context =  UIGraphicsGetCurrentContext()
        
        context.do { $0.clear(rect) }
        
        if self.axesDrawer == nil {
            setupAxesDrawer()
        }
        
        if self.origin == nil {
            centerOrigin()
        }
        
        lift((self.axesDrawer, self.origin)).do { drawer, origin in
            drawer.drawAxes(in: rect, origin: origin, pointsPerUnit: self.pointsPerUnit)
        }
        
        self.graphCurveColor.setStroke()
        
        let widthInPoints = Double(rect.width)
        
        let delta: Double = 1
        
        self.ifunction.do { ifunction in
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
    
    public func moveOrigin(to point: CGPoint) {
        self.origin = point
    }
    
    public func touchBegan(at initialTouchPoint: CGPoint) {
        self.origin.do { (initialOriginPoint: CGPoint) in
            
            self.moveOriginWithNewPoint = { [weak self] point in
                self.do {
                    $0.origin = CGPoint(
                        x: initialOriginPoint.x + (point.x - initialTouchPoint.x),
                        y: initialOriginPoint.y + (point.y - initialTouchPoint.y)
                    )
                }
            }
        }
    }
    
    public func touchMove(to point: CGPoint) {
        self.moveOriginWithNewPoint.do { originMover in
            originMover(point)
        }
    }
    
    public func touchEnd() {
        self.moveOriginWithNewPoint = nil
    }
    
    public func pinchStart(at scale: CGFloat) {
        let initialPointsPerUnit = self.pointsPerUnit
        
        self.scaleWithValue = { [weak self] scale in
            self.do {
                $0.pointsPerUnit = initialPointsPerUnit * scale
            }
        }
    }
    
    public func pinchZoom(with scale: CGFloat) {
        self.scaleWithValue.do { scaler in
            scaler(scale)
        }
    }
    
    public func pinchEnd() {
        self.scaleWithValue = nil
    }
    
    // MARK: Private
    
    private func setupAxesDrawer() {
        self.axesDrawer = AxesDrawer(color: self.graphCurveColor,
                                     contentScaleFactor: self.pointsPerUnit)
    }
    
    private func setupGraphView() {
        NotificationCenter.default.removeObserver(
            self
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil,
            queue: nil,
            using: deviceDidRotate
        )
    }
    
    private func deviceDidRotate(notification: Notification) {
        guard let origin = self.origin else {
            return
        }
        
        guard let drawRect = self.drawRect else {
            return
        }
        
        let screenCenter = CGPoint(
            x: drawRect.origin.x + drawRect.size.width / 2 ,
            y: drawRect.origin.y + drawRect.size.height / 2
        )
        
        let dx = screenCenter.x - origin.x
        let dy = screenCenter.y - origin.y
        
        self.origin = CGPoint(
            x: self.bounds.origin.x + self.bounds.width / 2 + dy,
            y: self.bounds.origin.y + self.bounds.height / 2 + dx
        )
    }

    private func pointForScreenX(_ x: Double) -> CGPoint? {
        let scale = Double(self.pointsPerUnit)
        
        return self.ifunction
            .map { ifunction in
                return self.calculateFor(CGPoint(x: x, y: 0)) { x in
                    ifunction(x, scale)
                }
            }
            .flatMap { point in
                return point.x.isFinite && point .y.isFinite ? point : nil
        }
    }
    
    private func transformFromScreenToOrigin() -> CGAffineTransform {
        guard let origin = self.origin else {
            return CGAffineTransform.identity
        }
        
        return CGAffineTransform
            .init(a: 1 / self.pointsPerUnit,
                  b: 0,
                  c: 0,
                  d: -1 / self.pointsPerUnit,
                  tx: -origin.x / self.pointsPerUnit,
                  ty: origin.y / self.pointsPerUnit)
    }
    
    private func transformFromOriginToStreen() -> CGAffineTransform {
        return self.transformFromScreenToOrigin().inverted()
    }
    
    private func calculateFor(_ screenPoint: CGPoint, function: (Double) -> Double) -> CGPoint {
        var point = screenPoint.applying(self.transformFromScreenToOrigin())
        point.y = CGFloat(function(Double(point.x)))
        
        return point.applying(self.transformFromOriginToStreen())
    }
}

extension GraphView {
    private static let pointsPerUnitPropertiesKey = "pointsPerUnitPropertiesKey"
    private static let originPropertiesKey = "originPropertiesKey"
    private static let originXPropertiesKey = "originXPropertiesKey"
    private static let originYPropertiesKey = "originYPropertiesKey"
    
    func save() {
        let storage = UserDefaults.standard
        
        self.origin.do { origin in
            let originDict = [
                GraphView.originXPropertiesKey: origin.x,
                GraphView.originYPropertiesKey: origin.y
            ]
            
            storage.set(originDict, forKey: GraphView.originPropertiesKey)
        }
        
        storage.set(Double(self.pointsPerUnit), forKey: GraphView.pointsPerUnitPropertiesKey)
    }
    
    func load() {
        let storage = UserDefaults.standard
        
        (storage.object(forKey: GraphView.originPropertiesKey) as? [String: CGFloat])
            .do { [weak self] originDictionary in
                if let x = originDictionary[GraphView.originXPropertiesKey],
                    let y = originDictionary[GraphView.originYPropertiesKey]
                {
                    self.do {
                        $0.origin = CGPoint(x: x, y: y)
                    }
                }
        }
        
        (storage.value(forKey: GraphView.pointsPerUnitPropertiesKey) as? Double)
            .do { pointsPerUnit in
                self.pointsPerUnit = CGFloat(pointsPerUnit)
        }
    }
}
