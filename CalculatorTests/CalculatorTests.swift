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
        XCTAssert(abs((self.brain.result ?? 0) - 12.5663706143592) < 0.01)
    }
}
