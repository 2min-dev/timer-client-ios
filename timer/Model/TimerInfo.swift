//
//  TimerInfo.swift
//  timer
//
//  Created by JSilver on 20/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

/// The timer data present object
class TimerInfo: Codable, NSCopying {
    /// The state of timer
    enum State: Int, Codable {
        case stop = 0
        case start
        case pause
        case end
    }
    
    // MARK: - properties
    var title: String // The title of the timer
    var comment: String // The comment of the timer
    var alarm: String // The alarm name of the timer
    var currentTime: TimeInterval // Current time interval of the timer
    var endTime: TimeInterval // Target end time interval of the timer
    var state: State // Current state of the timer
    
    // MARK: - constructor
    init(title: String, comment: String = "", alarm: String = "system", currentTime: TimeInterval = 0, endTime: TimeInterval = 0, state: State = .stop) {
        self.title = title
        self.comment = comment
        self.alarm = alarm
        self.currentTime = currentTime
        self.endTime = endTime
        self.state = state
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return TimerInfo(title: title, comment: comment, alarm: alarm, currentTime: currentTime, endTime: endTime, state: state)
    }
}
