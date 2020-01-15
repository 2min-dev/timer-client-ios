//
//  RealmServiceTests.swift
//  timerTests
//
//  Created by JSilver on 2020/01/15.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

import XCTest
import RxSwift
@testable import timer

class RealmServiceTests: XCTestCase {
    private var realmService: RealmService!
    private var disposeBag: DisposeBag!
    
    override func setUp() {
        let serviceProvider = ServiceProvider()
        realmService = RealmService(provider: serviceProvider)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        realmService = nil
        disposeBag = DisposeBag()
    }
}
