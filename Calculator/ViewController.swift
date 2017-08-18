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
    
    var variables: [String: Double]?
    
    let decimalSymbol = "."
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!

        if self.touchedSequence?.contains(decimalSymbol) == true
            && digit == decimalSymbol
        {
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
                self.display.text = $0.prettyDoubleInString
            }
        }
    }
    
    var displayValue: Double {
        get {            
            guard let value = Double(self.touchedSequence!) else {
                return self.variables?[self.touchedSequence!] ?? 0
            }
            
            return value
        }
        
        set {
            self.touchedSequence = newValue.stringWithoutInsignificantFractionDigits
        }
    }
    
    var isDecimalValue: Bool {
        get {
            return abs(displayValue - floor(displayValue)) > 0
        }
    }
    
    private var brain = CalculatorBrain()
    
    private func process() {
        let expression = self.brain.evaluate(using: self.variables)
        expression.result.do {  self.displayValue = $0  }
        log.text = expression.description
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        sender.currentTitle.do { self.brain.performOperation($0)}
        
        process()
    }
    
    @IBAction func performClean(_ sender: UIButton) {
        self.brain.clearBrain()
        self.userIsInTheMiddleOfTyping = false
        self.displayValue = 0
        self.variables = nil
        log.text = " "
    }
    
    @IBAction func performDelete(_ sender: UIButton) {
        if var text = self.touchedSequence {
            if userIsInTheMiddleOfTyping == false {
                performClean(UIButton())
            }
            
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
    
    @IBAction func touchVariable(_ sender: UIButton) {
        
        self.brain.setOperand(variable: "M")
        
        self.display.text = "M"
    }
    
    @IBAction func inputVariable(_ sender: UIButton) {
        
        self.variables = ["M": self.displayValue]
        
        self.userIsInTheMiddleOfTyping = false
        
        process()
    }
}
