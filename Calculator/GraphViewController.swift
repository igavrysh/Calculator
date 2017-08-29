//
//  GraphViewController.swift
//  Calculator
//
//  Created by Gavrysh on 8/26/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewSource {
    public var function: (Double) -> Double = { _ in 0 }
    weak var graphView: GraphView! {
        return self.view as! GraphView
    }
    
    override func viewDidLoad() {
        self.graphView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.graphView.centerOrigin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func valueForX(_ x: Double) -> Double {
        return function(x)
    }
    
    private var moveOriginWithNewPoint: ((CGPoint) -> ())? = nil
    
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
}
