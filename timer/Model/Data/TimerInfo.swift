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
    @objc dynamic var alarm: String = ""                // The alarm name of the timer
    @objc dynamic var currentTime: TimeInterval = 0     // Current time interval of the timer
    @objc dynamic var endTime: TimeInterval = 0         // Target end time interval of the timer
    @objc dynamic var extraTime: TimeInterval = 0       // Added extra time of the timer
    
    // MARK: - constructor
    convenience init(comment: String, alarm: String, currentTime: TimeInterval, endTime: TimeInterval, extraTime: TimeInterval) {
        self.init()
        
        self.comment = comment
        self.alarm = alarm
        self.currentTime = currentTime
        self.endTime = endTime
        self.extraTime = extraTime
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return TimerInfo(comment: comment, alarm: alarm, currentTime: currentTime, endTime: endTime, extraTime: extraTime)
    }
}
