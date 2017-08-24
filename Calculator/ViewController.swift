//
//  ViewController.swift
//  Calculator
//
//  Created by Ievgen on 3/22/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

let variableName = "M"
let decimalSymbol = "."

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var log: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    var errorView: ErrorView!
    
    var userIsInTheMiddleOfTyping = false
    
    var variables: [String: Double]?
    
    override func viewDidLoad() {
        self.displayValue = 0
        
        addErrorView()
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let isDecimalSymbol = digit == decimalSymbol
        
        if isDecimalSymbol && (self.touchedSequence.map { $0.contains(decimalSymbol) }) == true {
            return
        }

        if userIsInTheMiddleOfTyping {
            self.touchedSequence = self.touchedSequence! + digit
        } else if isDecimalSymbol {
            self.touchedSequence = self.touchedSequence! + digit
            userIsInTheMiddleOfTyping = true
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
        return abs(displayValue - floor(displayValue)) > 0
    }
    
    private var brain = CalculatorBrain()
    
    private func process() {
        let expression = self.brain.evaluateWithLogging(using: self.variables)
        
        guard let result = expression.result else {
            self.touchedSequence = "0"
            self.log.text  = " "
            self.userIsInTheMiddleOfTyping = false
            
            return
        }
        
        self.displayValue = result
        self.log.text = expression.description
        self.errorView.text = expression.error.map { "Error: " + $0 }
    }
    
    private func addVariable(name: String, value: Double) {
        if (self.variables == nil) {
            self.variables = [:]
        }
        
        self.variables?[name] = value
        
        self.userIsInTheMiddleOfTyping = false
        
        process()
    }
    
    private func addErrorView() {
        let errorView = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)?.last as? ErrorView
        
        errorView.do { [weak self] errorView in
            self.do {
                $0.errorView = errorView
                $0.errorView.stackView = $0.stackView
                $0.errorView.onCloseProcessor  = { [weak self] button in
                    self.do { $0.performClean(button) }
                }
            }
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping || self.displayValue == 0 {
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
        self.errorView.text = nil
        log.text = " "
    }
    
    @IBAction func performDelete(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping == false {
            self.brain.undo()
            
            process()
            
            return
        }
        
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
    
    @IBAction func touchVariable(_ sender: UIButton) {
        
        self.brain.setOperand(variable: variableName)
        
        self.display.text = variableName
    }
    
    @IBAction func inputVariable(_ sender: UIButton) {
        addVariable(name: variableName, value: self.displayValue)
    }
    
    @IBAction func varaiblesListLongPress(_ sender: UILongPressGestureRecognizer) {
        print("varaibles list long press")
        
        sender.view.do { view in
            let alertController = UIAlertController(
                title: "Variable",
                message: variableName + "=",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect =  view.bounds
            
            let okAction = UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: { (alert :UIAlertAction!) in
                    alertController.textFields?[0].text.do { [weak self] textValue in
                        self.do { $0.addVariable(name: variableName, value: Double(textValue) ?? 0.0) }
                    }
            }
            )
            
            alertController.addTextField(configurationHandler: { textField in
                textField.text = String(self.variables?[variableName] ?? 0.0)
                textField.textAlignment = .center
            })
            
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
