//
//  GraphViewController.swift
//  Calculator
//
//  Created by Gavrysh on 8/26/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    var function: (Double) -> Double = { _ in 0 }
    @IBOutlet weak var graphView: GraphView!
    

}
