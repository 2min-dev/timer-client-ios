//
//  Recordable.swift
//  timer
//
//  Created by JSilver on 2019/10/29.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

protocol Recordable {
    /// Current time interval of the timer
    var current: TimeInterval { get }
    /// Target end time interval of the timer
    var end: TimeInterval { get }
    /// Is timer process ended
    var isEnded: Bool { get }
    
    /// Consume time to timer
    /// - parameter time: the time to consume
    /// - returns: consumed time
    @discardableResult
    func consume(time: TimeInterval) -> TimeInterval
    
    /// Reset time data
    func reset()
}
