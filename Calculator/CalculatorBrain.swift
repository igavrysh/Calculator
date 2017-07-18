//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ievgen on 3/22/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

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
                if accumulator.value != nil && accumulator.desc != nil {
                    accumulator = (function(accumulator.value!), "\(symbol)(\(accumulator.desc!))")
                }
            case .binaryOperation(let function):
                if accumulator.value != nil && accumulator.desc != nil {
                    if pendingBinaryOperation != nil {
                        performPendingBinartyOperation()
                    }
                    
                    pendingBinaryOperation = PendingBinartyOperaion(function: function,
                                                                    firstOperand: accumulator.value!,
                                                                    firstPartDescription: "\(accumulator.desc!)\(symbol)")
                    accumulator = (nil, nil)
                }
                
                break;
            case .equals:
                performPendingBinartyOperation();
            }
        }
    }
    
    mutating private func performPendingBinartyOperation() {
        if pendingBinaryOperation != nil
            && accumulator.value != nil
            && accumulator.desc != nil
        {
            accumulator = (pendingBinaryOperation!.perform(with: accumulator.value!),
                           "\(pendingBinaryOperation!.firstPartDescription)\(accumulator.desc!)")
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
            
            return "\(accumulator.desc ?? "")="
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
}
