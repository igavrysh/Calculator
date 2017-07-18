//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ievgen on 3/22/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private var accumulator: (Double?, String?)
    
    private enum Operation {
        case constant(Double)
        case unartyOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unartyOperation(sqrt),
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

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch (operation, accumulator) {
            case (.constant(let value), _):
                accumulator = (value, "\(symbol)")
                break
            case (.unartyOperation(let function), (let v, let description)):
                if v != nil && description != nil {
                    accumulator = (function(v!), "\(symbol)(\(description!))")
                }
            case (.binaryOperation(let function), (let v, var description)):
                if v != nil && description != nil {
                    if pendingBinaryOperation != nil {
                        performPendingBinartyOperation()
                        description = accumulator.1!
                    }
                    
                    pendingBinaryOperation = PendingBinartyOperaion(function: function,
                                                                    firstOperand: v!,
                                                                    firstPartDescription: "\(description!)\(symbol)")
                    accumulator = (nil, nil)
                }
                
                break;
            case (.equals, _):
                performPendingBinartyOperation();
            }
        }
    }
    
    mutating private func performPendingBinartyOperation() {
        let (v, description) = accumulator
        
        if pendingBinaryOperation != nil && v != nil && description != nil {
            accumulator = (pendingBinaryOperation!.perform(with: v!),
                           "\(pendingBinaryOperation!.firstPartDescription)\(description!)")
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinartyOperaion?
    
    private struct PendingBinartyOperaion {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        let firstPartDescription: String
        
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, "\(operand)")
    }
    
    var result: Double? {
        get {
            let (v, _) = accumulator
            return v
        }
    }
    
    var description: String? {
        get {
            if pendingBinaryOperation != nil {
                return "\(pendingBinaryOperation!.firstPartDescription)..."
            }
            
            let (_, description) = accumulator
            return "\(description ?? "")="
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
}
