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

struct CalculatorBrain {
    
    // MARK: -
    // MARK: Subtypes
    
    private enum Operation {
        case constant(Double)
        case unartyOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
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
        "=" : Operation.equals
    ]
    
    // MARK: -
    // MARK: Properties
    
    private var accumulator: (value: Double?, desc: String?)
    private var operations = CalculatorBrain.defaultOperations
    private var pendingBinaryOperation: PendingBinartyOperaion?
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, "\(operand)")
    }
    
    var result: Double? {
        return self.accumulator.value
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
            case .constant(let value): self.accumulator = (value, "\(symbol)")
                
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
            self.accumulator = ($0.0.perform(with: $0.1),
                                "\($0.0.firstPartDescription)\($0.2)")
            pendingBinaryOperation = nil
        }
    }
}
