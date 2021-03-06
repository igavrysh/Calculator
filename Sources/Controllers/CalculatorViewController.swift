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

class CalculatorViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet var log: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var graphButton: CalculatorButton!
    
    @IBOutlet weak var graphViewController: GraphViewController?
    
    var errorView: ErrorView!
    
    var userIsInTheMiddleOfTyping = false
    
    var variables: [String: Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayValue = 0
        
        addErrorView()
        
        addLogLabel()
        
        self.brain.load()
        self.variables = self.brain.loadVariables()
        
        process()
        
        self.splitViewController.do { [weak self] splitViewController in
            if splitViewController.viewControllers.count > 1 {
                self.do {
                    $0.graphViewController = splitViewController.viewControllers[1] as? GraphViewController
                    
                    $0.reloadGraphViewController()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.brain.save()
        self.brain.save(variables: variables)
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let isDecimalSymbol = digit == decimalSymbol
        
        if isDecimalSymbol && (self.touchedSequence.map { $0.contains(decimalSymbol) }) == true {
            return
        }
        
        if self.isVariableAdded {
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
    
    var isVariableAdded: Bool {
        get {
            return self.touchedSequence.map {
               $0.range(of: "[^a-zA-Z]", options: .regularExpression) == nil
            } ?? false
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
        
        self.graphButton.isEnabled = !expression.isPending
        
        guard let result = expression.result else {
            self.touchedSequence = "0"
            self.log.text  = " "
            self.userIsInTheMiddleOfTyping = false
            
            return
        }
        
        self.displayValue = result
        self.log.text = expression.description
        self.errorView.text = expression.error.map {
            "Error: " + $0
        }
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
    
    private func presentVariablesView(sourceView: UIView?) {
        sourceView.do { sourceView in
            
            let onOkHandler: (_ sender: UIAlertController) -> Void = { alertController in
                alertController.textFields?[0].text.do { [weak self] textValue in
                    self.do {
                        $0.addVariable(name: variableName, value: Double(textValue) ?? 0.0)
                    }
                }
            }
            
            let variablesViewController
                = VariablesViewGenerator.variablesView(withTitle: "Variable",
                                                       message: variableName + " = ",
                                                       sourceView: sourceView,
                                                       value: variables?[variableName] ?? 0.0,
                                                       onOkHandler: onOkHandler)
            
            present(variablesViewController, animated: true)
        }
    }
    
    private func addLogLabel() {
        let log = AdaptiveLabel.init(frame: CGRect(x:0, y:0, width: 800, height: 40))
        log.accessibilityIdentifier = "description"
        //log.backgroundColor = UIColor.black
        log.textAlignment = .right
        //log.textColor = UIColor.white
        log.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightUltraLight)
        log.minimumScaleFactor = 0.5
        log.lineBreakMode = .byTruncatingHead
        log.adjustsFontSizeToFitWidth = true
        log.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        log.numberOfLines = 1
        log.text = ""
        
        self.log = log
        
        self.navigationController.do {
            $0.navigationBar.topItem.do {
                $0.titleView = log
            }
        }
    }
    
    private func reloadGraphViewController() {
        self.graphViewController.do { [weak self] controller in
            self.map {
                let brain = $0.brain
                
                controller.function = { x in
                    brain.evaluate(using: [variableName: x]).result ?? 0
                }
            }
            
            controller.graphView.setNeedsDisplay()
            
            //let evalResult = self.brain.evaluate()
            //controller.titleDescription = evalResult.description
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping || self.displayValue == 0 {
            if isVariableAdded {
                self.touchedSequence.do {
                    brain.setOperand(variable: $0)
                }
            } else {
                brain.setOperand(displayValue)
            }
            
            userIsInTheMiddleOfTyping = false
        }

        sender.currentTitle.do { self.brain.performOperation($0) }
        
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
    
    @IBAction func inputVariable(_ sender: UIButton) {
        addVariable(name: variableName, value: self.displayValue)
    }
    
    @IBAction func varaiblesListLongPress(_ sender: UILongPressGestureRecognizer) {
        self.presentVariablesView(sourceView: sender.view)
    }
    
    @IBAction func onGraphTouch(_ sender: UIButton) {
        let evalResult = self.brain.evaluate()
        if evalResult.isPending {
            return
        }
        
        if self.graphViewController == nil {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            self.graphViewController = storyBoard.instantiateViewController(withIdentifier: "GraphViewController") as? GraphViewController
        }
        
        reloadGraphViewController()
        
        self.graphViewController.do { [weak self] controller in
            self?.splitViewController.do {
                $0.showDetailViewController(controller, sender: self)
            }
        }
    }
}
