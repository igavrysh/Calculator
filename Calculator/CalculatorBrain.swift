//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ievgen on 3/22/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

func lift<A, B>(_ value: (A?, B?)) -> (A, B)? {
    return value.0.flatMap { lhs in
        value.1.flatMap { (lhs, $0) }
    }
}

func lift<A, B, C>(_ value: (A?, B?, C?)) -> (A, B, C)? {
    return value.0.flatMap { lhs in
        value.1.flatMap { mhs in
            value.2.flatMap { (lhs, mhs, $0) }
        }
    }
}

extension Optional {
    func `do`(execute: (Wrapped) -> ()) {
        self.map(execute)
    }
}

extension NumberFormatter {
    static var prettyFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        return formatter
    }
}

extension Double {    
    var prettyDescString: String {
        let formatter = NumberFormatter.prettyFormat
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 6
    
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    var prettyDisplayString: String {
        let formatter = NumberFormatter.prettyFormat
        formatter.maximumFractionDigits = 20;
        
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    var stringWithoutInsignificantFractionDigits: String {
        let formatter = NumberFormatter()
        var string: String;
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
            string = formatter.string(from: NSNumber(value: self)) ?? ""
        } else {
            string = String(self)
        }
        
        return string
    }
}

extension String {
    var prettyDoubleInString: String {
        let components = self.components(separatedBy: ".")
        let firstPart = components[0]
        let reversedCharacters = firstPart.characters.reversed()
        var prettyDouble = ""
        for (n, c) in reversedCharacters.enumerated() {
            prettyDouble = String(c) + prettyDouble
            if (n + 1) % 3 == 0 && n != reversedCharacters.count - 1  {
                prettyDouble = "," + prettyDouble
            }
        }
        
        if (components.count == 2) {
            prettyDouble = "\(prettyDouble).\(components[1])"
        }
        
        return prettyDouble
    }
    
    var prettyDouble: Double {
        let formatter = NumberFormatter.prettyFormat
        
        var formattedDouble: Double = 0
        formatter.number(from: self).do { formattedDouble = $0.doubleValue }
        
        return formattedDouble
    }
}

struct CalculatorBrain {
    
    // MARK: -
    // MARK: Subtypes
    
    private enum Operation {
        case constant(Double)
        case unartyOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case genOperation(() -> Double)
        case equals
    }
    
    private struct PendingBinartyOperaion {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        let firstPartDescription: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    // MARK: -
    // MARK: Static
    
    private static let defaultOperations: [String: Operation] = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unartyOperation(sqrt),
        "1/" : Operation.unartyOperation({ 1 / $0}),
        "cos" : Operation.unartyOperation(cos),
        "sin" : Operation.unartyOperation(sin),
        "±" : Operation.unartyOperation({ -$0 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "^" : Operation.binaryOperation(pow),
        "rand" : Operation.genOperation({ Double(arc4random())/Double(UInt32.max) }),
        "=" : Operation.equals
    ]
    
    // MARK: -
    // MARK: Properties
    
    private var accumulator: (value: Double?, desc: String?)
    private var operations = CalculatorBrain.defaultOperations
    private var pendingBinaryOperation: PendingBinartyOperaion?
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, "\(operand.prettyDescString)")
    }
    
    var result: Double? {
        return self.accumulator.value ?? self.pendingBinaryOperation?.firstOperand;
    }
    
    var description: String? {
        return self.pendingBinaryOperation?.firstPartDescription ?? self.accumulator.desc
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    // MARK: -
    // MARK: Public

    mutating func performOperation(_ symbol: String) {
        var lifted = lift(self.accumulator).do
        
        self.operations[symbol].do {
            switch $0 {
            case .constant(let value):
                self.accumulator = (value, "\(symbol)")
            
            case .genOperation(let function):
                self.accumulator = (function(), "\(symbol)")
            
            case .unartyOperation(let function):
                lifted {
                    self.accumulator = (function($0), "\(symbol)(\($1))")
                }
                
            case .binaryOperation(let function):
                self.performPendingBinartyOperation()
                
                lifted = lift(self.accumulator).do
                
                lifted {
                    self.pendingBinaryOperation = PendingBinartyOperaion(
                        function: function,
                        firstOperand: $0,
                        firstPartDescription: "\($1)\(symbol)"
                    )
                    
                    self.accumulator = (nil, nil)
                }
                
            case .equals: self.performPendingBinartyOperation();
                
            }
        }
    }
    
    mutating func clearBrain() {
        self.accumulator = (nil, nil)
        self.pendingBinaryOperation = nil
    }
    
    // MARK: -
    // MARK: Private
    
    mutating private func performPendingBinartyOperation() {
        lift((self.pendingBinaryOperation, self.accumulator.value, self.accumulator.desc)).do {
            self.accumulator = ($0.perform(with: $1),
                                "\($0.firstPartDescription)\($2)")
            pendingBinaryOperation = nil
        }
    }
}
