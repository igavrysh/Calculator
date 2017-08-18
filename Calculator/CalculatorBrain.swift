//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ievgen on 3/22/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

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
    
    private enum Operand {
        case value(Double)
        case variable(String)
        
        func double(with variables: [String: Double]?) -> Double {
            switch self {
            case .value(let value):
                return value
            case .variable(let name):
                return variables?[name] ?? 0
            }
        }
        
        var description: String {
            switch self {
            case .value(let val):
                return "\(val.stringWithoutInsignificantFractionDigits)"
            case .variable(let variable):
                return variable
            }
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
    private var availableOperations = CalculatorBrain.defaultOperations
    private var operands: Queue<Operand> = Queue()
    private var operations: Queue<String> = Queue()
    
    mutating func setOperand(_ operand: Double) {
        addOperand(Operand.value(operand))
    }
    
    mutating func setOperand(variable named: String) {
        addOperand(Operand.variable(named))
    }
    
    var result: Double? {
        return evaluate().result
    }
    
    var description: String? {
        return evaluate().description
    }
    
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    // MARK: -
    // MARK: Public

    mutating func performOperation(_ symbol: String) {
        self.operations.enqueue(symbol)
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        struct PendingBinartyOperaion {
            let function: (Double, Double) -> Double
            let firstPart: (result: Double?, description: String)
            
            func perform(with secondPart: (result: Double?, description: String),
                         variables: [String: Double]?) -> (result: Double?, description: String)
            {
                return lift((firstPart.result, secondPart.result)).map {
                    (result: function($0, $1),
                     description: "\(firstPart.description)\(secondPart.description)")
                    }
                    ??
                    (result:nil,
                     description: "")
            }
        }
        
        var ops = self.operations
        var oprnds = self.operands
        
        var accumulator: (result: Double?, description: String) = (result: nil, description: "")
        var pendingBinaryOperation: PendingBinartyOperaion?
        
        func performPendingBinartyOperation(_ operation: inout PendingBinartyOperaion?) {
            operation.do { pbo in
                accumulator = pbo.perform(with: accumulator, variables: variables)
                
                operation = nil
            }
        }
        
        func fetchOperand() {
            if accumulator.result == nil {
                oprnds.dequeue().do {
                    accumulator = (result:$0.double(with: variables),
                                   description:$0.description)
                }
            }
        }
        
        repeat {
            ops.dequeue().map { (operationSymbol: String) in
                self.availableOperations[operationSymbol].do {
                    switch $0 {
                    case .constant(let value):
                        accumulator = (result: value, description: "\(operationSymbol)")
                        
                    case .genOperation(let function):
                        accumulator = (result: function(), description: "\(operationSymbol)")
                        
                    case .unartyOperation(let function):
                        fetchOperand()
                        
                        lift(accumulator).do {
                            accumulator = (result: function($0), description: "\(operationSymbol)(\($1))")
                        }
                        
                    case .binaryOperation(let function):
                        fetchOperand()
                        
                        performPendingBinartyOperation(&pendingBinaryOperation)
                        
                        pendingBinaryOperation = PendingBinartyOperaion(
                            function: function,
                            firstPart: (result: accumulator.result,
                                        description: accumulator.description + operationSymbol)
                        )
                        
                        accumulator = (result: nil, description: "")
                        
                    case .equals:
                        fetchOperand()
                        
                        performPendingBinartyOperation(&pendingBinaryOperation)
                    }
                }
            }
        } while !ops.isEmpty
        
        if !oprnds.isEmpty {
            fetchOperand()
            
            performPendingBinartyOperation(&pendingBinaryOperation)
        }
        
        return (result: accumulator.result
                    //?? oprnds.dequeue()?.double(with: variables)
                    ?? pendingBinaryOperation?.firstPart.result,
                isPending: pendingBinaryOperation != nil,
                description: (pendingBinaryOperation?.firstPart.description ?? "")
                    + accumulator.description
                    + "\(pendingBinaryOperation != nil ? "..." : "=")"
                    
        )
    }
    
    mutating func clearBrain() {
        self.operands = Queue()
        self.operations = Queue()
    }
    
    mutating func undo() {
        if self.resultIsPending {
            self.operations.removeLast()
            
            return
        }
        
        if self.operations.isEmpty && !self.operands.isEmpty {
            self.operands = Queue()
        }

        self.operations.removeLast().do { operationSymbol in
            self.availableOperations[operationSymbol].do {
                switch $0 {
                case .equals:
                    undo()
                case .binaryOperation(_):
                    self.operations.enqueue(operationSymbol)
                    self.operands.removeLast()
                default: break
                }
            }
        }
    }
    
    // MARK: -
    // MARK: Private
    
    private mutating func addOperand(_ operand: Operand) {
        self.operations.last.do { _ in
            if !evaluate().isPending {
                clearBrain()
            }
        }
        
        self.operands.enqueue(operand)
    }
    
    private mutating func addOperation(_ symbol: String) {
        if self.evaluate().isPending {
            self.operations.removeLast()
        }
        
        self.operations.enqueue(symbol)
    }
}
