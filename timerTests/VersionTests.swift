//
//  VersionTests.swift
//  timerTests
//
//  Created by JSilver on 2019/11/22.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import XCTest
@testable import timer

class VersionTests: XCTestCase {
    
    override func setUp() {
        
    }

    override func tearDown() {
        
    }
    
    func testCreateVersionFromString() {
        // Success to create
        let major = Version("1")
        XCTAssertEqual(major, Version(major: 1, minor: 0, patch: 0))
        
        let minor = Version("2.2")
        XCTAssertEqual(minor, Version(major: 2, minor: 2, patch: 0))
        
        let patch = Version("3.3.3")
        XCTAssertEqual(patch, Version(major: 3, minor: 3, patch: 3))
        
        // Fail to create
        let wrongFormat1 = Version("0.")
        XCTAssertNil(wrongFormat1)
        
        let wrongFormat2 = Version("0.0.")
        XCTAssertNil(wrongFormat2)
        
        let wrongFormat3 = Version("0.0.0.")
        XCTAssertNil(wrongFormat3)
        
        let wrongFormat4 = Version("0.0.0.0")
        XCTAssertNil(wrongFormat4)
    }
    
    func testVersionCompare() {
        guard let version_1_0_0 = Version("1.0.0"),
            let version_1_0_1 = Version("1.0.1"),
            let version_2_0_0 = Version("2.0.0"),
            let version_1_3_0 = Version("1.3.0") else {
                XCTFail("Couldn't create version")
                return
        }
        
        XCTAssertTrue(version_1_0_0 < version_1_0_1)
        XCTAssertTrue(version_1_0_1 < version_1_3_0)
        XCTAssertTrue(version_1_3_0 < version_2_0_0)
    }
}
