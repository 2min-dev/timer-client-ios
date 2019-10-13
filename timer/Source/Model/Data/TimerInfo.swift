//
//  TimerInfo.swift
//  timer
//
//  Created by JSilver on 20/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RealmSwift

/// The timer data present object
class TimerInfo: Object, Codable, NSCopying {
    // MARK: - properties
    @objc dynamic var comment: String = ""              // The comment of the timer
    @objc dynamic var alarm: Alarm = .silence           // The alarm of the timer
    @objc dynamic var currentTime: TimeInterval = 0     // Current time interval of the timer
    @objc dynamic var endTime: TimeInterval = 0         // Target end time interval of the timer
    @objc dynamic var extraTime: TimeInterval = 0       // Added extra time of the timer
    
    // MARK: - constructor
    convenience init(comment: String, alarm: Alarm, currentTime: TimeInterval, endTime: TimeInterval, extraTime: TimeInterval) {
        self.init()
        self.comment = comment
        self.alarm = alarm
        self.currentTime = currentTime
        self.endTime = endTime
        self.extraTime = extraTime
    }
    
    convenience init(endTime: TimeInterval) {
        self.init()
        self.endTime = endTime
    }
    
    convenience init(alarm: Alarm) {
        self.init()
        self.alarm = alarm
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return TimerInfo(comment: comment, alarm: alarm, currentTime: currentTime, endTime: endTime, extraTime: extraTime)
    }
}
