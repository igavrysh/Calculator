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
        XCTAssert((abs(Double(self.app.staticTexts["display"].label) ?? 0) - 12.566370) < 0.001)
        XCTAssert(self.app.staticTexts["description"].label == "4×π=")
    }
}