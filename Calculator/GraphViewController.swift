//
//  GraphViewController.swift
//  Calculator
//
//  Created by Gavrysh on 8/26/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewSource, UIGestureRecognizerDelegate {
    
    @IBOutlet var log: UILabel?
    @IBOutlet var pinchGestureRecogniser: UIPinchGestureRecognizer!
    @IBOutlet var tapGestureRecogniser: UITapGestureRecognizer!
    
    public var function: (Double) -> Double = { _ in 0 }
    public var titleDescription: String? {
        didSet {
            self.log.do {
                $0.text = oldValue
            }
        }
    }
    
    private var moveOriginWithNewPoint: ((CGPoint) -> ())? = nil
    private var scaleWithValue: ((CGFloat) -> Void)? = nil
    
    weak var graphView: GraphView! {
        return self.view as! GraphView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.graphView.dataSource = self
        
        addLogLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func valueForX(_ x: Double) -> Double {
        return function(x)
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.graphView)
        
        graphView.origin.do { origin in
            self.graphView.origin = CGPoint(
                x: origin.x + translation.x,
                y: origin.y + translation.y)
        }
    }
    
    private func graphTouchPoint(_ touches: Set<UITouch>, with event: UIEvent?) -> CGPoint? {
        return touches.first.flatMap { [weak self] touch in
            let touchPoint = touch.location(in: self?.view)
                
            return self?.graphView == self?.view.hitTest(touchPoint, with: event)
                ? touchPoint
                : nil
        }
    }
    
    private func addLogLabel() {
        /*
        let log = AdaptiveLabel.init(frame: CGRect(x:0, y:0, width: 800, height: 40))
        log.accessibilityIdentifier = "lala"
        log.backgroundColor = UIColor.black
        log.textAlignment = .right
        log.textColor = UIColor.white
        log.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightUltraLight)
        log.minimumScaleFactor = 0.5
        log.lineBreakMode = .byTruncatingHead
        log.adjustsFontSizeToFitWidth = true
        log.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        log.numberOfLines = 1
        log.text = self.titleDescription
        
        self.log = log
        */
        self.navigationController.do {
            $0.navigationBar.topItem.do { _ in
                //$0.titleView = log
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.graphTouchPoint(touches, with: event).do { [weak self] initialTouchPoint in
            self.do {
                guard let initialOriginPoint = $0.graphView.origin else {
                    return
                }
                
                $0.moveOriginWithNewPoint = { [weak self] point in
                    self.do {
                        $0.graphView.origin = CGPoint(
                            x: initialOriginPoint.x + (point.x - initialTouchPoint.x),
                            y: initialOriginPoint.y + (point.y - initialTouchPoint.y)
                        )
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lift((self.graphTouchPoint(touches, with: event), self.moveOriginWithNewPoint))
            .do { touchPoint, functor in
                functor(touchPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.moveOriginWithNewPoint = nil
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    @IBAction func onDoubleTapGesture(_ sender: UITapGestureRecognizer) {
        self.graphView.origin = sender.location(in: self.graphView)
    }
    
    @IBAction func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let initialPointsPerUnit = self.graphView.pointsPerUnit
            
            self.scaleWithValue = { [weak self] scale in
                self.do {
                    $0.graphView.pointsPerUnit = initialPointsPerUnit * scale
                }
            }
        } else if sender.state == UIGestureRecognizerState.changed {
            self.scaleWithValue.do { scale in
                scale(sender.scale)
            }
        } else {
            self.scaleWithValue = nil
        }
    }
}
