//
//  GraphViewController.swift
//  Calculator
//
//  Created by Gavrysh on 8/26/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewSource, UIGestureRecognizerDelegate {
    
    @IBOutlet var pinchGestureRecogniser: UIPinchGestureRecognizer!
    @IBOutlet var tapGestureRecogniser: UITapGestureRecognizer!
    
    private var moveOriginWithNewPoint: ((CGPoint) -> ())? = nil
    private var scaleWithValue: ((CGFloat) -> Void)? = nil
    
    
    public var function: (Double) -> Double = { _ in 0 }
    weak var graphView: GraphView! {
        return self.view as! GraphView
    }
    
    override func viewDidLoad() {
        self.graphView.dataSource = self
        
        self.graphView.centerOrigin()
        
        /*
        if (self.splitViewController?.viewControllers.count)! > 1 {
            
            if let masterController = self.splitViewController?.viewControllers[0] as? UIViewController,
                let detailController = self.splitViewController?.viewControllers[1] as? UIViewController
            {
                let detailBounds = detailController.view.bounds
                let masterBounds = masterController.view.bounds
                
                self.graphView.origin = CGPoint(x: (detailBounds.width - masterBounds.width ) / 2,
                                                y: detailBounds.width / 2)
            }
        } else {
            self.graphView.centerOrigin()
        }
         */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func valueForX(_ x: Double) -> Double {
        return function(x)
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.graphView)
        
        self.graphView.origin = CGPoint(
            x: graphView.origin.x + translation.x,
            y: graphView.origin.y + translation.y)
        
    }
    
    private func graphTouchPoint(_ touches: Set<UITouch>, with event: UIEvent?) -> CGPoint? {
        return touches.first.flatMap { [weak self] touch in
            let touchPoint = touch.location(in: self?.view)
                
            return self?.graphView == self?.view.hitTest(touchPoint, with: event)
                ? touchPoint
                : nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.graphTouchPoint(touches, with: event).do { [weak self] initialTouchPoint in
            self.do {
                let initialOriginPoint = $0.graphView.origin
                
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
