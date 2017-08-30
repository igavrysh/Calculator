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
        case constant (Double)
        case unaryOperation ((Double) -> Double)
        case binaryOperation ((Double, Double) -> Double)
        case genOperation (() -> Double)
        case equals
    }
    
    private enum ArgCheck {
        case unaryOperationCheck((Double) -> String?)
        case binaryOperationCheck((Double, Double) -> String?)
    }
    
    fileprivate enum Operand {
        case value (Double)
        case variable (String)
        
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
        "√" : Operation.unaryOperation(sqrt),
        "1/" : Operation.unaryOperation({ 1 / $0}),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "±" : Operation.unaryOperation({ -$0 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "-" : Operation.binaryOperation({ $0 - $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "^" : Operation.binaryOperation(pow),
        "rand" : Operation.genOperation({ Double(arc4random())/Double(UInt32.max) }),
        "=" : Operation.equals
    ]
    
    private static let argCheckFor: [String: ArgCheck] = [
        "√" : ArgCheck.unaryOperationCheck({ $0 < 0 ? "Complex result" : nil }),
        "1/" : ArgCheck.unaryOperationCheck({ $0 == 0 ? "Not a finite result, one over zero" : nil }),
        "÷" : ArgCheck.binaryOperationCheck({ $1 == 0 ? "Not a finite result, division by zero" : nil })
    ]
    
    // MARK: -
    // MARK: Properties
    
    private var availableOperations = CalculatorBrain.defaultOperations
    fileprivate var operands: Queue<Operand> = Queue()
    fileprivate var operations: Queue<String> = Queue()
    
    mutating func setOperand(_ operand: Double) {
        addOperand(Operand.value(operand))
    }
    
    mutating func setOperand(variable named: String) {
        addOperand(Operand.variable(named))
    }
    
    @available(iOS, deprecated, message: "Depreciated, use evaluate(using:) for getting results")
    var result: Double? {
        return evaluate().result
    }
    
    @available(iOS, deprecated, message: "Depreciated, use evaluate(using:) for getting results")
    var description: String? {
        return evaluate().description
    }
    
    @available(iOS, deprecated, message: "Depreciated, use evaluate(using:) for getting results")
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    // MARK: -
    // MARK: Public

    mutating func performOperation(_ symbol: String) {
        addOperation(symbol)
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String)
    {
        let evalResult = evaluateWithLogging(using: variables)
        
        return (result: evalResult.result,
                isPending: evalResult.isPending,
                description: evalResult.description)
    }
    
    typealias Accumulator = (result: Double?, description: String, error: String?)
    private static let AccumulatorEmpty = Accumulator(result: nil, description: "", error:nil)
    private static let isAccumulatorEmpty = { (acc: Accumulator) -> Bool in acc.result == nil }
    
    func evaluateWithLogging(using variables: Dictionary<String, Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String, error: String?)
    {
        var ops = self.operations
        var oprnds = self.operands
        
        var accumulator: Accumulator = CalculatorBrain.AccumulatorEmpty
        var pendingBinaryOperation: PendingBinartyOperaion?
        
        struct PendingBinartyOperaion {
            let function: (Double, Double) -> Double
            let functionDesc: String
            let firstPart: Accumulator
            
            func perform(with secondPart: Accumulator, variables: [String: Double]?) -> Accumulator {
                let liftedArgs = lift((firstPart.result, secondPart.result))
                
                let performedOperation = liftedArgs.map { arg1, arg2 -> Accumulator in
                    
                    let error = CalculatorBrain.argCheckFor[functionDesc].flatMap { (argCheck: ArgCheck) -> String? in
                        if case ArgCheck.binaryOperationCheck(let function) = argCheck {
                            return function(arg1, arg2)
                        }
                        
                        return nil
                    }
                    
                    return Accumulator(
                        result: function(arg1, arg2),
                        description: "\(firstPart.description)\(secondPart.description)",
                        error: firstPart.error ?? error
                    )
                }
                
                return performedOperation ?? (result:nil, description: "", error: nil)
            }
        }
        
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
                                   description:$0.description,
                                   error: nil)
                }
            }
        }
        
        repeat {
            ops.dequeue().map { (operationSymbol: String) in
                self.availableOperations[operationSymbol].do {
                    switch $0 {
                    case .constant(let value):
                        accumulator = Accumulator(result: value, description: "\(operationSymbol)", error: nil)
                        
                    case .genOperation(let function):
                        accumulator = Accumulator(result: function(), description: "\(operationSymbol)", error: nil)
                        
                    case .unaryOperation(let function):
                        fetchOperand()
                        
                        lift(accumulator).do { arg, dsc, error in
                            accumulator
                                = Accumulator(
                                    result: function(arg),
                                    description: "\(operationSymbol)(\(dsc))",
                                    error: error
                                        ?? CalculatorBrain.argCheckFor[operationSymbol]
                                            .flatMap { (argCheck: ArgCheck) in
                                                if case ArgCheck.unaryOperationCheck(let function) = argCheck {
                                                    return function(arg)
                                                }
                                                
                                                return nil
                                    }
                            )
                        }
                        
                    case .binaryOperation(let function):
                        fetchOperand()
                        
                        performPendingBinartyOperation(&pendingBinaryOperation)
                        
                        pendingBinaryOperation = PendingBinartyOperaion(
                            function: function,
                            functionDesc: operationSymbol,
                            firstPart: Accumulator(
                                result: accumulator.result,
                                description: accumulator.description + operationSymbol,
                                error: accumulator.error)
                        )
                        
                        accumulator = (result: nil, description: "", error: nil)
                        
                    case .equals:
                        fetchOperand()
                        
                        performPendingBinartyOperation(&pendingBinaryOperation)
                    }
                }
            }
        } while !ops.isEmpty
        
        // Required for correct undo() functionality
        if !oprnds.isEmpty {
            fetchOperand()
            
            performPendingBinartyOperation(&pendingBinaryOperation)
        }
        
        return (
            result: accumulator.result ?? pendingBinaryOperation?.firstPart.result,
            isPending: pendingBinaryOperation != nil,
            description: (pendingBinaryOperation?.firstPart.description ?? "")
                + accumulator.description
                + "\(pendingBinaryOperation != nil ? "..." : "=")",
            error: accumulator.error ?? pendingBinaryOperation?.firstPart.error
        )
    }
    
    mutating func clearBrain() {
        self.operands = Queue()
        self.operations = Queue()
    }
    
    mutating func undo() {
        if self.evaluate().isPending {
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
        let isPending = self.evaluate().isPending
        if isPending,
            let operation = self.availableOperations[symbol],
            let lastOperatinon = self.availableOperations[self.operations.last ?? ""]
        {
            if case .binaryOperation(_) = operation, case .binaryOperation(_) = lastOperatinon {
                self.operations.removeLast()
            }
        }
        
        if self.availableOperations[symbol] != nil {
            self.operations.enqueue(symbol)
        }
    }
}

extension CalculatorBrain {
    func save() {
        for var operation in self.operations {
            print("\(operation)")
        }
        
        for var operand in self.operands {
            print("\(operand)")
        }
    }
    
    func load() {
        
    }
}
