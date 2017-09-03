//
//  CalculatorButton.swift
//  Calculator
//
//  Created by Gavrysh on 9/3/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class CalculatorButton : UIButton {
    
    override var isEnabled: Bool {
        didSet {
            let color = isEnabled ? UIColor.black : UIColor.lightGray
            self.setTitleColor(color, for: UIControlState.normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        touchStylingSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        touchStylingSetup()
    }
    
    private func touchStylingSetup() {
        self.addTarget(self,
                       action:#selector(CalculatorButton.onTouchUpInside(_:)),
                       for: UIControlEvents.touchUpInside)
        
        self.addTarget(self,
                       action:#selector(CalculatorButton.onTouchDown(_:)),
                       for: UIControlEvents.touchDown)
    }
    
    @objc private func onTouchUpInside(_ sender: UIButton!) {
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(1);
    }
    
    @objc private func onTouchDown(_ sender: UIButton!) {
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.9);
    }
}
