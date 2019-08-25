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
    // MARK: - properties
    var comment: String             // The comment of the timer
    var alarm: String               // The alarm name of the timer
    var currentTime: TimeInterval   // Current time interval of the timer
    var endTime: TimeInterval       // Target end time interval of the timer
    var extraTime: TimeInterval     // Added extra time of the timer
    
    // MARK: - constructor
    init(comment: String = "",
         alarm: String = "system",
         currentTime: TimeInterval = 0,
         endTime: TimeInterval = 0,
         extraTime: TimeInterval = 0) {
        self.comment = comment
        self.alarm = alarm
        self.currentTime = currentTime
        self.endTime = endTime
        self.extraTime = extraTime
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return TimerInfo(comment: comment,
                         alarm: alarm,
                         currentTime: currentTime,
                         endTime: endTime,
                         extraTime: extraTime)
    }
}
