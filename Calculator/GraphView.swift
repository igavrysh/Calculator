//
//  GraphView.swift
//  Calculator
//
//  Created by Gavrysh on 8/25/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    lazy var axesDrawer = AxesDrawer(color: .black, contentScaleFactor: 50)
    
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxes(in: rect, origin: CGPoint(x :rect.width/2, y: rect.height/2), pointsPerUnit: 50)
    }
    
}
