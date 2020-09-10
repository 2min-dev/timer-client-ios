//
//  Collector.swift
//  birdview_hwahaeTests
//
//  Created by JSilver on 2020/01/10.
//  Copyright © 2020 JSilver. All rights reserved.
//

import XCTest
import RxSwift

class Collector<Output> {
    private let observable: Observable<Output>
    private let disposeBag: DisposeBag = DisposeBag()
    
    /// Perform input closure before waiting for observable stream
    var input: (() -> Void)?
    
    init(_ observable: Observable<Output>) {
        self.observable = observable
    }
    
    /// Collect emitted value from observable stream
    /// - parameters:
    ///   - take: How many to collect emitted value from observable.
    ///   - timeout: How long wait for collect value.
    ///   - resultCallback: Compare and assert with passed result.
    func collect(take: Int = 0, timeout: TimeInterval = 1, resultCallback: @escaping ([Output]) -> Void) {
        var result: [Output] = []
        let expectation = XCTestExpectation(description: "waiting for emitted value from observable stream.")
        
        // Take value if passed `take` parameter greater than 0
        let collectObservable = take > 0 ? observable.take(take) : observable
        var isCompleted: Bool = false
        
        // Subscribe observable to collect value
        collectObservable
            .subscribe(onNext: {
                result.append($0)
            }, onCompleted: {
                isCompleted = true
                expectation.fulfill()
                resultCallback(result)
            })
            .disposed(by: disposeBag)
        
        // Inject input
        input?()
        
        // Wait observable
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        if !isCompleted {
            // Test fail if observable stream doesn't compelted
            XCTFail("XCTWaiter timed out for expectations.")
        }
    }
}
