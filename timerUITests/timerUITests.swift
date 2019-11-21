//
//  timerUITests.swift
//  timerUITests
//
//  Created by JSilver on 2019/11/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import XCTest

class timerUITests: XCTestCase {
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        
    }

    func testSnapshot() {
        // TODO: Sample snapshot feature of fastlane. Use after first release due to XCode recording issue
        let app = XCUIApplication()
        
        let keypadThreeButton = app.buttons["3"]
        let keypadOneButton = app.buttons["1"]
        let keypadZeroButton = app.buttons["0"]
        
        let timekeySecondButton = app.buttons["s"]
        
        let addTimerCell = app.collectionViews.staticTexts["+"]
        
        // 30 seconds timer
        keypadThreeButton.tap()
        keypadZeroButton.tap()
        
        timekeySecondButton.tap()
        
        // Add new timer
        addTimerCell.tap()
        
        // 10 seconds timer
        keypadOneButton.tap()
        keypadZeroButton.tap()
        timekeySecondButton.tap()
        
        // Add new timer
        addTimerCell.tap()
        
        // 30 seconds timer
        keypadThreeButton.tap()
        keypadZeroButton.tap()
        timekeySecondButton.tap()
        
        // Add new timer
        addTimerCell.tap()
        
        // 10 seconds timer
        keypadOneButton.tap()
        keypadZeroButton.tap()
        timekeySecondButton.tap()
        
        // Snapshot `main`
        snapshot("main")
    }
}
