//
//  RevisionValueTests.swift
//  timerTests
//
//  Created by JSilver on 2019/12/20.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import XCTest
@testable import timer

class RevisionValueTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    func testNext() {
        // Given
        let revisionValue = RevisionValue(10)
        
        // When
        let nextRevisionValue = revisionValue.next()
        
        // Then
        XCTAssertEqual(revisionValue.value, nextRevisionValue.value)
        XCTAssertNotEqual(revisionValue, nextRevisionValue)
    }
    
    func testNextWithValue() {
        // Given
        let revisionValue = RevisionValue(10)
        
        // When
        let nextRevisionValue = revisionValue.next(20)
        
        // Then
        XCTAssertNotEqual(revisionValue.value, nextRevisionValue.value)
        XCTAssertNotEqual(revisionValue, nextRevisionValue)
    }
    
    func testChangeValue() {
        // Given
        var revisionValue = RevisionValue(10)
        
        // When
        revisionValue.value = 20
        
        // Then
        XCTAssertEqual(revisionValue.value, 20)
    }
}
