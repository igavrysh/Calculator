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
    @IBOutlet weak var graphView: GraphView!
    
    override func viewDidLoad() {
        self.graphView.dataSource = self
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
}
