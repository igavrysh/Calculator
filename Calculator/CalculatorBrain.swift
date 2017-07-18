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

struct CalculatorBrain {

    private var accumulator: (value: Double?, desc: String?)
    
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
            switch operation {
            case .constant(let value):
                accumulator = (value, "\(symbol)")
                break
            case .unartyOperation(let function):
                if let acc = lift(accumulator) {
                    accumulator = (function(acc.0), "\(symbol)(\(acc.1))")
                }
            case .binaryOperation(let function):
                performPendingBinartyOperation()
                
                if let acc = lift(accumulator) {
                    pendingBinaryOperation = PendingBinartyOperaion(function: function,
                                                                    firstOperand: acc.0,
                                                                    firstPartDescription: "\(acc.1)\(symbol)")
                    accumulator = (nil, nil)
                }
                
                break;
            case .equals:
                performPendingBinartyOperation();
            }
        }
    }
    
    mutating private func performPendingBinartyOperation() {
        if let pbo = pendingBinaryOperation, let acc = lift(accumulator)
        {
            accumulator = (pbo.perform(with: acc.0),
                           "\(pbo.firstPartDescription)\(acc.1)")
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
            if let pbo = pendingBinaryOperation {
                return "\(pbo.firstPartDescription)..."
            }
            
            return accumulator.1
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
}
