//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Gavrysh on 8/13/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import XCTest

class CalculatorTests: XCTestCase {
    
    var brain = CalculatorBrain()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // a. touching 7 + would show “7 + ...” (with 7 still in the display)
    func testCaseA() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        XCTAssert(self.brain.description == "7+...")
    }
    
    // b. 7 + 9 would show “7 + ...” (9 in the display)
    func testCaseB() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        // entered but not pushed to the model
        //self.brain.setOperand(9)
        XCTAssert(self.brain.description == "7+...")
    }
    
    // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
    func testCaseC() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "7+9=")
        XCTAssert(self.brain.result == 16)
    }
    
    // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
    func testCaseD() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("=")
        self.brain.performOperation("√")
        XCTAssert(self.brain.description == "√(7+9)=")
        XCTAssert(self.brain.result == 4)
    }
    
    // e. 7 + 9 = √ + 2 = would show “√(7 + 9) + 2 =” (6 in the display)
    func testCaseE() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("=")
        self.brain.performOperation("√")
        self.brain.performOperation("+")
        self.brain.setOperand(2)
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "√(7+9)+2=")
        XCTAssert(self.brain.result == 6)
    }
    
    // f. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
    func testCaseF()  {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("√")
        XCTAssert(self.brain.description == "7+√(9)...")
    }
    
    // g. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
    func testCaseG() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("√")
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "7+√(9)=")
        XCTAssert(self.brain.result == 10)
    }
    
    // h. 7 + 9 = + 6 = + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
    func testCaseH() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("=")
        self.brain.performOperation("+")
        self.brain.setOperand(6)
        self.brain.performOperation("=")
        self.brain.performOperation("+")
        self.brain.setOperand(3)
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "7+9+6+3=")
        XCTAssert(self.brain.result == 25)
    }
    
    // h.2. 7 + 9 + 6 + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
    func testCaseH2() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("+")
        self.brain.setOperand(6)
        self.brain.performOperation("+")
        self.brain.setOperand(3)
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "7+9+6+3=")
        XCTAssert(self.brain.result == 25)
    }
    
    // i. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
    func testCaseI() {
        self.brain.setOperand(7)
        self.brain.performOperation("+")
        self.brain.setOperand(9)
        self.brain.performOperation("√")
        self.brain.performOperation("=")
        self.brain.setOperand(6)
        self.brain.performOperation("+")
        self.brain.setOperand(3)
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "6+3=")
        XCTAssert(self.brain.result == 9)
    }
    
    // j. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
    func testCaseJ() {
        self.brain.setOperand(5)
        self.brain.performOperation("+")
        self.brain.setOperand(6)
        self.brain.performOperation("=")
        // set but not pushed to the model
        //self.brain.setOperand(73)
        XCTAssert(self.brain.description == "5+6=")
    }
    
    // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
    func testCaseK() {
        self.brain.setOperand(4)
        self.brain.performOperation("×")
        self.brain.performOperation("π")
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "4×π=")
        XCTAssert(abs((self.brain.result ?? 0) - 4 * Double.pi) < 0.01)
    }
    
    // l. 5 × e = would show “5×e=“ (5 * .e)
    func testCaseExponent() {
        self.brain.setOperand(5)
        self.brain.performOperation("×")
        self.brain.performOperation("e")
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "5×e=")
        XCTAssert(abs((self.brain.result ?? 0) - (5.0 * M_E)) < 0.01)
    }
    
    // o. 5 ^ 0 = would show “5^0=“ =0
    func testCasePower1() {
        self.brain.setOperand(5)
        self.brain.performOperation("^")
        self.brain.setOperand(0)
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "5^0=")
        XCTAssert(self.brain.result == 1)
    }
    
    // r. 5 ^ 5 = would show “5^5=“ =125
    func testCasePower2() {
        self.brain.setOperand(5)
        self.brain.performOperation("^")
        self.brain.setOperand(5)
        self.brain.performOperation("=")
        XCTAssert(self.brain.description == "5^5=")
        XCTAssert(self.brain.result == pow(5.0, 5.0))
    }
    
    // 9 + M = √ ⇒ description is √(9+M), display is 3 because M is not set (thus 0.0).
    func testCaseAddVariableOperand() {
        self.brain.setOperand(9)
        self.brain.performOperation("+")
        self.brain.setOperand(variable: "M")
        self.brain.performOperation("=")
        self.brain.performOperation("√")
        XCTAssert(self.brain.description == "√(9+M)=")
        XCTAssert(self.brain.result == 3)
    }
    
    // 9 + M = √ , 7 →M, ⇒ description is √(9+M), display is 4 because M is set now to 7.
    func testCaseSetVariableValue() {
        self.brain.setOperand(9)
        self.brain.performOperation("+")
        self.brain.setOperand(variable: "M")
        self.brain.performOperation("=")
        self.brain.performOperation("√")
        let evalResult = self.brain.evaluate(using: ["M": Double(7.0)])
        XCTAssert(evalResult.description == "√(9+M)=")
        XCTAssert(evalResult.result == 4)
    }
    
    // 9 + M = √ , 7 →M, + 14 ⇒ display now shows 18, description is now √(9+M)+14
    func testCaseAddConstToVariableExpression() {
        self.brain.setOperand(9)
        self.brain.performOperation("+")
        self.brain.setOperand(variable: "M")
        self.brain.performOperation("=")
        self.brain.performOperation("√")
        _ = self.brain.evaluate(using: ["M": Double(7.0)])
        self.brain.performOperation("+")
        self.brain.setOperand(14)
        self.brain.performOperation("=")
        let finalEvalResult = self.brain.evaluate(using: ["M": Double(7.0)])
        XCTAssert(finalEvalResult.description == "√(9+M)+14=")
        XCTAssert(finalEvalResult.result == 18)
    }
    
    // 9 + - × 2 = ⇒ display now shows 18, description is now 9×2=
    func testCase1ChangingInputOperations() {
        self.brain.setOperand(9)
        self.brain.performOperation("+")
        self.brain.performOperation("-")
        self.brain.performOperation("×")
        self.brain.setOperand(2)
        self.brain.performOperation("=")
        let evalResult = self.brain.evaluate()
        XCTAssert(evalResult.description == "9×2=")
        XCTAssert(evalResult.result == 18)
    }
    
    // 9 + 2 = + - × 3 ⇒ display now shows 33, description is now 9+2×3=
    func testCase2ChangingInputOperations() {
        self.brain.setOperand(9)
        self.brain.performOperation("+")
        self.brain.setOperand(2)
        self.brain.performOperation("+")
        self.brain.performOperation("-")
        self.brain.performOperation("×")
        self.brain.setOperand(3)
        self.brain.performOperation("=")
        let evalResult = self.brain.evaluate()
        XCTAssert(evalResult.description == "9+2×3=")
        XCTAssert(evalResult.result == 33)
    }
    
    // 9 + 2 = + - × 4 = ÷ 2 ⇒ display now shows 33, description is now 9+2×4÷2=22
    func testCase3ChangingInputOperations() {
        self.brain.setOperand(9)
        self.brain.performOperation("+")
        self.brain.setOperand(2)
        self.brain.performOperation("+")
        self.brain.performOperation("-")
        self.brain.performOperation("×")
        self.brain.setOperand(4)
        self.brain.performOperation("=")
        self.brain.performOperation("÷")
        self.brain.setOperand(2)
        self.brain.performOperation("=")
        let evalResult = self.brain.evaluate()
        XCTAssert(evalResult.description == "9+2×4÷2=")
        XCTAssert(evalResult.result == 22)
    }
    
    func testCasePlus() {
        self.brain.setOperand(1)
        self.brain.performOperation("+")
        self.brain.setOperand(2)
        self.brain.performOperation("=")
        let evalResult = self.brain.evaluate()
        XCTAssert(evalResult.description == "1+2=")
        XCTAssert(evalResult.result == 3)
    }
    
    func testCaseMinus() {
        self.brain.setOperand(1)
        self.brain.performOperation("-")
        self.brain.setOperand(2)
        self.brain.performOperation("=")
        let evalResult = self.brain.evaluate()
        XCTAssert(evalResult.description == "1-2=")
        XCTAssert(evalResult.result == -1)
    }
    
    func testCaseMultiply() {
        self.brain.setOperand(2)
        self.brain.performOperation("×")
        self.brain.setOperand(3)
        self.brain.performOperation("=")
        let evalResult = self.brain.evaluate()
        XCTAssert(evalResult.description == "2×3=")
        XCTAssert(evalResult.result == 6)
    }
    
    func testCaseDivide() {
        self.brain.setOperand(1.8)
        self.brain.performOperation("÷")
        self.brain.setOperand(3)
        self.brain.performOperation("=")
        let evalResult = self.brain.evaluate()
        XCTAssert(evalResult.description == "1.8÷3=")
        XCTAssert(evalResult.result == 0.6)
    }
    
    // touching 25 ± ± should display -25 and next 25
    func testCaseChangeSign() {
        self.brain.setOperand(25)
        self.brain.performOperation("±")
        XCTAssert(self.brain.result == -25)
        XCTAssert(self.brain.description == "±(25)=")
        self.brain.performOperation("±")
        XCTAssert(self.brain.result == 25)
        XCTAssert(self.brain.description == "±(±(25))=")
    }
    
    // touching 25 √ should display 5
    func testCaseSquaredRoot() {
        self.brain.setOperand(25)
        self.brain.performOperation("√")
        XCTAssert(self.brain.description == "√(25)=")
        XCTAssert(self.brain.result == 5)
    }
    
    // touching 5 and 1/ should display 0.2 as a result and 1/(5)
    func testCaseOneOver() {
        self.brain.setOperand(5)
        self.brain.performOperation("1/")
        XCTAssert(self.brain.description == "1/(5)=")
        XCTAssert(self.brain.result == 0.2)
    }
    
    func testCasePower() {
        self.brain.setOperand(2)
        self.brain.performOperation("^")
        self.brain.setOperand(3)
        XCTAssert(self.brain.description == "2^3=")
        XCTAssert(self.brain.result == 8)
    }
    
    // 5 * π sin = would show “sin(5×π)=“ (5 * .e)
    func testCaseSin() {
        self.brain.setOperand(5)
        self.brain.performOperation("×")
        self.brain.performOperation("π")
        self.brain.performOperation("=")
        self.brain.performOperation("sin")
        XCTAssert(self.brain.description == "sin(5×π)=")
        XCTAssert(abs((self.brain.result ?? 0) - sin(5 * Double.pi)) < 0.01)
    }
    
    // 5 * π cos = would show “cos(5×π)=“ (5 * .e)
    func testCaseCos() {
        self.brain.setOperand(5)
        self.brain.performOperation("×")
        self.brain.performOperation("π")
        self.brain.performOperation("=")
        self.brain.performOperation("cos")
        XCTAssert(self.brain.description == "cos(5×π)=")
        XCTAssert(abs((self.brain.result ?? 0) - cos(5 * Double.pi)) < 0.01)
    }
    
}
