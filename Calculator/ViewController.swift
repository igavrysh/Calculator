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

        if self.touchedSequence?.contains(decimalSymbol) == true && digit == decimalSymbol {
            return
        }

        if userIsInTheMiddleOfTyping {
            self.touchedSequence = self.touchedSequence! + digit
        } else {
            self.touchedSequence = digit
            userIsInTheMiddleOfTyping = true
        }
        
        print("touchDigit was called \(digit)")
    }
    
    var sequence: String?
    
    var touchedSequence: String? {
        get {
            return self.sequence
        }
        
        set {
            self.sequence = newValue
            self.sequence.do {
                Double($0).do {
                    self.display.text = $0.prettyString
                }
            }
        }
    }
    
    var displayValue: Double {
        get {
            return Double(self.touchedSequence!)!
        }
        
        set {
            self.touchedSequence = String(newValue)
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
    
    @IBAction func performClean(_ sender: UIButton) {
        self.brain.clearBrain()
        self.userIsInTheMiddleOfTyping = false
        self.displayValue = 0
        log.text = " "
    }
    
    @IBAction func performDelete(_ sender: UIButton) {
        if var text = self.touchedSequence {
            text.remove(at: text.index(before: text.endIndex))
            if (text.characters.last == ".") {
                text.remove(at: text.index(before: text.endIndex))
            }
            
            if (text.isEmpty) {
                text = "0"
                userIsInTheMiddleOfTyping = false
            }
            
            self.touchedSequence = text
        }
    }
}

