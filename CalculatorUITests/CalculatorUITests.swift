//
//  CalculatorUITests.swift
//  CalculatorUITests
//
//  Created by Gavrysh on 8/14/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import XCTest

class CalculatorUITests: XCTestCase {
    
    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        self.app = XCUIApplication()
        
        self.app.launchArguments.append("--uitesting")
        
        self.app.launch()
    }
    
    override func tearDown() {
        self.app.buttons["clearAllInputs"].tap()
        
        super.tearDown()
    }
    
    // touching . 1 should display .1
    func testCaseDecimalPointCase1() {
        self.app.buttons["decimalPoint"].tap()
        self.app.buttons["one"].tap()
        XCTAssert(self.app.staticTexts["display"].label == ".1")
    }
    
    // touching . . 1 should display .1
    func testCaseDecimalPointCase2() {
        self.app.buttons["decimalPoint"].tap()
        self.app.buttons["decimalPoint"].tap()
        self.app.buttons["one"].tap()
        XCTAssert(self.app.staticTexts["display"].label == ".1")
    }
    
    // touching 0 . 1 should display 0.1
    func testCaseDecimalPointCase3() {
        self.app.buttons["zero"].tap()
        self.app.buttons["decimalPoint"].tap()
        self.app.buttons["one"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "0.1")
    }
    
    // touching 0 . . 1 should display 0.1
    func testCaseDecimalPointCase4() {
        self.app.buttons["zero"].tap()
        self.app.buttons["decimalPoint"].tap()
        self.app.buttons["decimalPoint"].tap()
        self.app.buttons["one"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "0.1")
    }
    
    // a. touching 7 + would show “7 + ...” (with 7 still in the display)
    func testCaseA() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "7")
        XCTAssert(self.app.staticTexts["description"].label == "7+...")
    }
    
    // b. 7 + 9 would show “7 + ...” (9 in the display)
    func testCaseB() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "9")
        XCTAssert(self.app.staticTexts["description"].label == "7+...")
    }
    
    // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
    func testCaseC() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "16")
        XCTAssert(self.app.staticTexts["description"].label == "7+9=")
    }
    
    // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
    func testCaseD() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["equals"].tap()
        self.app.buttons["squaredRoot"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "4")
        XCTAssert(self.app.staticTexts["description"].label == "√(7+9)=")
    }
    
    // e. 7 + 9 = √ + 2 = would show “√(7 + 9) + 2 =” (6 in the display)
    func testCaseE() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["equals"].tap()
        self.app.buttons["squaredRoot"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["two"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "6")
        XCTAssert(self.app.staticTexts["description"].label == "√(7+9)+2=")
    }
    
    // f. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
    func testCaseF()  {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["squaredRoot"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "3")
        XCTAssert(self.app.staticTexts["description"].label == "7+√(9)...")
    }
    
    // g. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
    func testCaseG() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["squaredRoot"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "10")
        XCTAssert(self.app.staticTexts["description"].label == "7+√(9)=")
    }
    
    // h. 7 + 9 = + 6 = + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
    func testCaseH() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["equals"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["six"].tap()
        self.app.buttons["equals"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["three"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "25")
        XCTAssert(self.app.staticTexts["description"].label == "7+9+6+3=")
    }
    
    // h.2. 7 + 9 + 6 + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
    func testCaseH2() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["six"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["three"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "25")
        XCTAssert(self.app.staticTexts["description"].label == "7+9+6+3=")
    }
    
    // i. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
    func testCaseI() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["nine"].tap()
        self.app.buttons["equals"].tap()
        self.app.buttons["squaredRoot"].tap()
        self.app.buttons["six"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["three"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "9")
        XCTAssert(self.app.staticTexts["description"].label == "6+3=")
    }
    
    // j. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
    func testCaseJ() {
        self.app.buttons["five"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["six"].tap()
        self.app.buttons["equals"].tap()
        self.app.buttons["seven"].tap()
        self.app.buttons["three"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "73")
        XCTAssert(self.app.staticTexts["description"].label == "5+6=")
    }
    
    // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
    func testCaseK() {
        self.app.buttons["four"].tap()
        self.app.buttons["multiply"].tap()
        self.app.buttons["π"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert((abs(Double(self.app.staticTexts["display"].label) ?? 0) - Double.pi * 4.0) < 0.001)
        XCTAssert(self.app.staticTexts["description"].label == "4×π=")
    }
    
    // touching backspace should remove one digit from display
    // 7 7 7 ⬅︎ => (display: 77; desc: "") ⬅︎ => (display: 7 desc: "") ⬅︎ => (display: 0; desc: "")
    func testBackspaceCase1() {
        self.app.buttons["seven"].tap()
        self.app.buttons["seven"].tap()
        self.app.buttons["seven"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "777")
        XCTAssert(self.app.staticTexts["description"].label.replacingOccurrences(of: " ", with: "") == "")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "77")
        XCTAssert(self.app.staticTexts["description"].label.replacingOccurrences(of: " ", with: "") == "")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "7")
        XCTAssert(self.app.staticTexts["description"].label.replacingOccurrences(of: " ", with: "") == "")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "0")
        XCTAssert(self.app.staticTexts["description"].label.replacingOccurrences(of: " ", with: "") == "")
    }
    
    // touching backspace in binary operation second operand input
    // 7 + 123 ⬅︎ => (display: 12; desc: "7+...") ⬅︎ => (display: 1; desc: "7+...") ⬅︎ => (display: 0; desc: "7+...")
    // ⬅︎ => (display: 7; desc: "7=")  ⬅︎ => (display: 0; desc: "")
    func testBackspaceCase2() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["one"].tap()
        self.app.buttons["two"].tap()
        self.app.buttons["three"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "123")
        XCTAssert(self.app.staticTexts["description"].label == "7+...")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "12")
        XCTAssert(self.app.staticTexts["description"].label == "7+...")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "1")
        XCTAssert(self.app.staticTexts["description"].label == "7+...")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "0")
        XCTAssert(self.app.staticTexts["description"].label == "7+...")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "7")
        XCTAssert(self.app.staticTexts["description"].label == "7=")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "0")
        XCTAssert(self.app.staticTexts["description"].label.replacingOccurrences(of: " ", with: "") == "")
    }
    
    // touching backspace after equals is pressed
    // 7 + 123 = ⬅︎ => (display: 12; desc: "7+...") ⬅︎ => (display: 1; desc: "7+...") ⬅︎ => (display: 7; desc: "7+...")
    // ⬅︎ => (display: 7; desc: "7=") ⬅︎ => (display: 0; desc: "")
    func testBackspaceCase3() {
        self.app.buttons["seven"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["one"].tap()
        self.app.buttons["two"].tap()
        self.app.buttons["three"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "130")
        XCTAssert(self.app.staticTexts["description"].label == "7+123=")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "7")
        XCTAssert(self.app.staticTexts["description"].label == "7+...")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "7")
        XCTAssert(self.app.staticTexts["description"].label == "7=")
        self.app.buttons["backspace"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "0")
        XCTAssert(self.app.staticTexts["description"].label.replacingOccurrences(of: " ", with: "") == "")
    }
    
    // 9 + M = √ ⇒ description is √(9+M), display is 3 because M is not set (thus 0.0)
    // 7 →M ⇒ display now shows 4 (the square root of 16), description is still √(9+M)
    // + 14 = ⇒ display now shows 18, description is now √(9+M)+14
    func testVariableInjection() {
        self.app.buttons["nine"].tap()
        self.app.buttons["plus"].tap()
        self.app.buttons["addVariableOperand"].tap()
        self.app.buttons["equals"].tap()
        self.app.buttons["squaredRoot"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "3")
        XCTAssert(self.app.staticTexts["description"].label == "√(9+M)=")
        self.app.buttons["seven"].tap()
        self.app.buttons["setVariableValue"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "4")
        XCTAssert(self.app.staticTexts["description"].label == "√(9+M)=")
        self.app.buttons["plus"].tap()
        self.app.buttons["one"].tap()
        self.app.buttons["four"].tap()
        self.app.buttons["equals"].tap()
        XCTAssert(self.app.staticTexts["display"].label == "18")
        XCTAssert(self.app.staticTexts["description"].label == "√(9+M)+14=")
    }
}
