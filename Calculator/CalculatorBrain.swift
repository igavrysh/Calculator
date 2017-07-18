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

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, "\(symbol)")
                
            case .unartyOperation(let function):
                lift(accumulator).do {
                    accumulator = (function($0.0), "\(symbol)(\($0.1))")
                }
                
            case .binaryOperation(let function):
                performPendingBinartyOperation()
                
                lift(accumulator).do {
                    pendingBinaryOperation = PendingBinartyOperaion(function: function,
                                                                    firstOperand: $0.0,
                                                                    firstPartDescription: "\($0.1)\(symbol)")
                    accumulator = (nil, nil)
                }
                
                break;
                
            case .equals:
                performPendingBinartyOperation();
            }
        }
    }
    
    mutating private func performPendingBinartyOperation() {
        lift((pendingBinaryOperation, accumulator.0, accumulator.1)).do {
            accumulator = ($0.0.perform(with: $0.1),
                           "\($0.0.firstPartDescription)\($0.2)")
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
            var desc: String?
            
            pendingBinaryOperation.do {
                desc = $0.firstPartDescription
            }
            
            return desc != nil ? desc : accumulator.1
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
}
