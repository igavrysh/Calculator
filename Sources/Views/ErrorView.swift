//
//  ErrorView.swift
//  Calculator
//
//  Created by Gavrysh on 8/23/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    @IBOutlet var displayError: UILabel!
    @IBOutlet var cancelButton: UIButton!
    
    var stackView: UIStackView?
    var onCloseProcessor: ((_ sender: UIButton) -> Void)?
    
    var text: String? {
        get {
            return self.displayError.text
        }
        
        set {
            self.displayError.text = newValue
            
            self.stackView.do { stackView in
                if let view = stackView.arrangedSubviews.last as? ErrorView{
                    if newValue == nil {
                        view.removeFromSuperview()
                    }
                } else {
                    newValue.do { _ in
                        stackView.addArrangedSubview(self)
                    }
                }
            }
        }
    }
    
    @IBAction func onCloseClicked(_ sender: UIButton) {
        self.onCloseProcessor.do { $0(sender) }
    }
}
