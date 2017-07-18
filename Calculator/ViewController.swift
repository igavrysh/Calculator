//
//  ViewController.swift
//  Calculator
//
//  Created by Ievgen on 3/22/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var log: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    let decimalSymbol = "."
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!

        if display.text?.contains(decimalSymbol) == true && digit == decimalSymbol {
            return
        }

        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
        
        print("touchDigit was called \(digit)")
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        
        set {
            display.text = String(newValue)
        }
    }
    
    var isDecimalValue: Bool {
        get {
            return abs(displayValue - floor(displayValue)) > 0
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.result {
            displayValue = result
        }
        
        if let description = brain.description {
            log.text = "\(description)\(brain.resultIsPending ? "..." : "=")"
        }
    }

}

