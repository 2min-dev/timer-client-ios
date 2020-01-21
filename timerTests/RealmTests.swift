//
//  RealmTests.swift
//  timerTests
//
//  Created by JSilver on 2020/01/21.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import XCTest
import RxSwift
@testable import timer

class RealmTests: XCTestCase {
    private var realmService: RealmService!
    private var disposeBag: DisposeBag!

    override func setUp() {
        let provider = ServiceProvider()
        realmService = RealmService(provider: provider)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        realmService = nil
        disposeBag = nil
    }

    func test() {
        
    }
}
