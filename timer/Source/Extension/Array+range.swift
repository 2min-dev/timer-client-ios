//
//  Array+range.swift
//  timer
//
//  Created by JSilver on 2020/01/16.
//  Copyright © 2020 Jeong Jin Eun. All rights reserved.
//

extension Array {
    func range(_ range: Range<Int>) -> Self {
        Range(uncheckedBounds: (
            lower: Swift.max(range.lowerBound, 0),
            upper: Swift.min(range.upperBound, count))
        ).map { self[$0] }
    }
}
