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
    
    var decimalPointButton: XCUIElement!
    var zeroDigitButton: XCUIElement!
    var oneDigitButton: XCUIElement!
    var twoDigitButton: XCUIElement!
    var threeDigitButton: XCUIElement!
    var fourDigitButton: XCUIElement!
    var fiveDigitButton: XCUIElement!
    var sixDigitButton: XCUIElement!
    var sevenDigitButton: XCUIElement!
    var nineDigitButton: XCUIElement!
    var plusOperationButton: XCUIElement!
    var minusOperaionButton: XCUIElement!
    var equalsOperationButton: XCUIElement!
    var squaredRootOperationButton: XCUIElement!
    var piOperationButton: XCUIElement!
    var multiplyOperationButton: XCUIElement!
    var cosinusOperationButton: XCUIElement!
    var backspaceOperationButton: XCUIElement!
    var addVariableOperandButton: XCUIElement!
    var setVariableValueButton: XCUIElement!
    
    var display: String {
        return self.app.staticTexts["display"].label
    }
    
    var desc: String {
        return self.app.staticTexts["description"].label
    }
    
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        self.app = XCUIApplication()
        
        self.app.launchArguments.append("--uitesting")
        
        self.app.launch()
        
        self.decimalPointButton = self.app.buttons["decimalPoint"]
        self.zeroDigitButton = self.app.buttons["zero"]
        self.oneDigitButton = self.app.buttons["one"]
        self.twoDigitButton = self.app.buttons["two"]
        self.threeDigitButton = self.app.buttons["three"]
        self.fourDigitButton = self.app.buttons["four"]
        self.fiveDigitButton = self.app.buttons["five"]
        self.sixDigitButton = self.app.buttons["six"]
        self.sevenDigitButton = self.app.buttons["seven"]
        self.nineDigitButton = self.app.buttons["nine"]
        self.plusOperationButton = self.app.buttons["plus"]
        self.minusOperaionButton = self.app.buttons["minus"]
        self.equalsOperationButton = self.app.buttons["equals"]
        self.squaredRootOperationButton = self.app.buttons["squaredRoot"]
        self.piOperationButton = self.app.buttons["π"]
        self.multiplyOperationButton = self.app.buttons["multiply"]
        self.cosinusOperationButton = self.app.buttons["cosinus"]
        self.backspaceOperationButton = self.app.buttons["backspace"]
        self.addVariableOperandButton = self.app.buttons["addVariableOperand"]
        self.setVariableValueButton = self.app.buttons["setVariableValue"]
        
        self.app.buttons["clearAllInputs"].tap()
    }
    
    override func tearDown() {
        self.app.buttons["clearAllInputs"].tap()
        
        super.tearDown()
    }
    
    // touching . 1 should display .1
    func testCaseDecimalPointCase1() {
        self.decimalPointButton.tap()
        self.oneDigitButton.tap()
        XCTAssert(self.display == "0.1")
    }
    
    // touching . . 1 should display .1
    func testCaseDecimalPointCase2() {
        self.decimalPointButton.tap()
        self.decimalPointButton.tap()
        self.oneDigitButton.tap()
        XCTAssert(self.display == "0.1")
    }
    
    // touching 0 . 1 should display 0.1
    func testCaseDecimalPointCase3() {
        self.zeroDigitButton.tap()
        self.decimalPointButton.tap()
        self.oneDigitButton.tap()
        XCTAssert(self.display == "0.1")
    }
    
    // touching 0 . . 1 should display 0.1
    func testCaseDecimalPointCase4() {
        self.zeroDigitButton.tap()
        self.decimalPointButton.tap()
        self.decimalPointButton.tap()
        self.oneDigitButton.tap()
        XCTAssert(self.display == "0.1")
    }
    
    // a. touching 7 + would show “7 + ...” (with 7 still in the display)
    func testCaseA() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        XCTAssert(self.display == "7")
        XCTAssert(self.desc == "7+...")
    }
    
    // b. 7 + 9 would show “7 + ...” (9 in the display)
    func testCaseB() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        XCTAssert(self.display == "9")
        XCTAssert(self.desc == "7+...")
    }
    
    // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
    func testCaseC() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "16")
        XCTAssert(self.desc == "7+9=")
    }
    
    // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
    func testCaseD() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.equalsOperationButton.tap()
        self.squaredRootOperationButton.tap()
        XCTAssert(self.display == "4")
        XCTAssert(self.desc == "√(7+9)=")
    }
    
    // e. 7 + 9 = √ + 2 = would show “√(7 + 9) + 2 =” (6 in the display)
    func testCaseE() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.equalsOperationButton.tap()
        self.squaredRootOperationButton.tap()
        self.plusOperationButton.tap()
        self.twoDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "6")
        XCTAssert(self.desc == "√(7+9)+2=")
    }
    
    // f. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
    func testCaseF()  {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.squaredRootOperationButton.tap()
        XCTAssert(self.display == "3")
        XCTAssert(self.desc == "7+√(9)...")
    }
    
    // g. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
    func testCaseG() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.squaredRootOperationButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "10")
        XCTAssert(self.desc == "7+√(9)=")
    }
    
    // h. 7 + 9 = + 6 = + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
    func testCaseH() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.equalsOperationButton.tap()
        self.plusOperationButton.tap()
        self.sixDigitButton.tap()
        self.equalsOperationButton.tap()
        self.plusOperationButton.tap()
        self.threeDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "25")
        XCTAssert(self.desc == "7+9+6+3=")
    }
    
    // h.2. 7 + 9 + 6 + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
    func testCaseH2() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.plusOperationButton.tap()
        self.sixDigitButton.tap()
        self.plusOperationButton.tap()
        self.threeDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "25")
        XCTAssert(self.desc == "7+9+6+3=")
    }
    
    // i. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
    func testCaseI() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.nineDigitButton.tap()
        self.equalsOperationButton.tap()
        self.squaredRootOperationButton.tap()
        self.sixDigitButton.tap()
        self.plusOperationButton.tap()
        self.threeDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "9")
        XCTAssert(self.desc == "6+3=")
    }
    
    // j. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
    func testCaseJ() {
        self.fiveDigitButton.tap()
        self.plusOperationButton.tap()
        self.sixDigitButton.tap()
        self.equalsOperationButton.tap()
        self.sevenDigitButton.tap()
        self.threeDigitButton.tap()
        XCTAssert(self.display == "73")
        XCTAssert(self.desc == "5+6=")
    }
    
    // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
    func testCaseK() {
        self.fourDigitButton.tap()
        self.multiplyOperationButton.tap()
        self.piOperationButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert((abs(Double(self.display) ?? 0) - Double.pi * 4.0) < 0.001)
        XCTAssert(self.desc == "4×π=")
    }
    
    // touching backspace should remove one digit from display
    // 7 7 7 ⬅︎ => (display: 77; desc: "") ⬅︎ => (display: 7 desc: "") ⬅︎ => (display: 0; desc: "")
    func testBackspaceCase1() {
        self.sevenDigitButton.tap()
        self.sevenDigitButton.tap()
        self.sevenDigitButton.tap()
        XCTAssert(self.display == "777")
        XCTAssert(self.desc.replacingOccurrences(of: " ", with: "") == "")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "77")
        XCTAssert(self.desc.replacingOccurrences(of: " ", with: "") == "")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "7")
        XCTAssert(self.desc.replacingOccurrences(of: " ", with: "") == "")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "0")
        XCTAssert(self.desc.replacingOccurrences(of: " ", with: "") == "")
    }
    
    // touching backspace in binary operation second operand input
    // 7 + 123 ⬅︎ => (display: 12; desc: "7+...") ⬅︎ => (display: 1; desc: "7+...") ⬅︎ => (display: 0; desc: "7+...")
    // ⬅︎ => (display: 7; desc: "7=")  ⬅︎ => (display: 0; desc: "")
    func testBackspaceCase2() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.oneDigitButton.tap()
        self.twoDigitButton.tap()
        self.threeDigitButton.tap()
        XCTAssert(self.display == "123")
        XCTAssert(self.desc == "7+...")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "12")
        XCTAssert(self.desc == "7+...")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "1")
        XCTAssert(self.desc == "7+...")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "0")
        XCTAssert(self.desc == "7+...")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "7")
        XCTAssert(self.desc == "7=")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "0")
        XCTAssert(self.desc.replacingOccurrences(of: " ", with: "") == "")
    }
    
    // touching backspace after equals is pressed
    // 7 + 123 = ⬅︎ => (display: 12; desc: "7+...") ⬅︎ => (display: 1; desc: "7+...") ⬅︎ => (display: 7; desc: "7+...")
    // ⬅︎ => (display: 7; desc: "7=") ⬅︎ => (display: 0; desc: "")
    func testBackspaceCase3() {
        self.sevenDigitButton.tap()
        self.plusOperationButton.tap()
        self.oneDigitButton.tap()
        self.twoDigitButton.tap()
        self.threeDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "130")
        XCTAssert(self.desc == "7+123=")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "7")
        XCTAssert(self.desc == "7+...")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "7")
        XCTAssert(self.desc == "7=")
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "0")
        XCTAssert(self.desc.replacingOccurrences(of: " ", with: "") == "")
    }
    
    // 9 + M = √ ⇒ description is √(9+M), display is 3 because M is not set (thus 0.0)
    // 7 →M ⇒ display now shows 4 (the square root of 16), description is still √(9+M)
    // + 14 = ⇒ display now shows 18, description is now √(9+M)+14
    func testVariableInjection() {
        self.nineDigitButton.tap()
        self.plusOperationButton.tap()
        self.addVariableOperandButton.tap()
        self.equalsOperationButton.tap()
        self.squaredRootOperationButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "3")
        XCTAssert(self.desc == "√(9+M)=")
        self.sevenDigitButton.tap()
        self.setVariableValueButton.tap()
        XCTAssert(self.display == "4")
        XCTAssert(self.desc == "√(9+M)=")
        self.plusOperationButton.tap()
        self.oneDigitButton.tap()
        self.fourDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "18")
        XCTAssert(self.desc == "√(9+M)+14=")
    }
    
    // M cos π then →M, then ⬅︎ => now your calculator will show the value of cos(M) which should be -1
    func testUndoCase() {
        self.addVariableOperandButton.tap()
        self.cosinusOperationButton.tap()
        self.piOperationButton.tap()
        self.setVariableValueButton.tap()
        self.backspaceOperationButton.tap()
        XCTAssert(self.display == "-1")
        XCTAssert(self.desc == "cos(M)=")
    }
    
    func textAppStartCase1() {
        self.minusOperaionButton.tap()
        self.oneDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "-1")
        XCTAssert(self.desc == "0-1=")
    }
    
    func textAppStartCase2() {
        self.decimalPointButton.tap()
        self.oneDigitButton.tap()
        self.plusOperationButton.tap()
        self.oneDigitButton.tap()
        self.equalsOperationButton.tap()
        XCTAssert(self.display == "1.1")
        XCTAssert(self.desc == "0.1+1=")
    }
}
