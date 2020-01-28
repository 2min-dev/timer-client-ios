//
//  ArrayExtensionTests.swift
//  timerTests
//
//  Created by JSilver on 2020/01/16.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import XCTest
@testable import timer

class ArrayExtensionTests: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    func testRangeInBounds() {
        // Given
        let array: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] // (0 ... 10)
        
        // When
        let result = array.range(3 ..< 6)
        
        // Then
        XCTAssertEqual(result, [3, 4, 5])
    }

    func testRangeOutOfUpperBounds() {
        // Given
        let array: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] // (0 ... 10)
        
        // When
        let result = array.range(6 ..< 12)
        
        // Then
        XCTAssertEqual(result, [6, 7, 8, 9])
    }
    
    func testRangeOutOfLowerBounds() {
        // Given
        let array: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] // (0 ... 10)
        
        // When
        let result = array.range(-3 ..< 4)
        
        // Then
        XCTAssertEqual(result, [0, 1, 2, 3])
    }
}
