//
//  TimerItem.swift
//  timer
//
//  Created by JSilver on 20/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RealmSwift

/// The timer data present object
class TimerItem: Object, Codable, NSCopying, Recordable, Alertable {
    // MARK: - properties
    /// The comment of the timer
    @objc dynamic var comment: String = ""
    @objc dynamic var alarm: Alarm = .silence
    @objc dynamic var current: TimeInterval = 0
    @objc dynamic var target: TimeInterval = 0
    @objc dynamic var extra: TimeInterval = 0
    
    var end: TimeInterval {
        target + extra
    }
    var isEnded: Bool {
        current >= end + extra
    }
    
    // MARK: - constructor
    convenience init(comment: String, alarm: Alarm, current: TimeInterval, target: TimeInterval, extra: TimeInterval) {
        self.init()
        self.comment = comment
        self.alarm = alarm
        self.current = current
        self.target = target
        self.extra = extra
    }
    
    convenience init(target: TimeInterval) {
        self.init()
        self.target = target
    }
    
    convenience init(alarm: Alarm) {
        self.init()
        self.alarm = alarm
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return TimerItem(comment: comment, alarm: alarm, current: current, target: target, extra: extra)
    }

    @discardableResult
    func consume(time: TimeInterval) -> TimeInterval {
        let remained = end - current
        current += time >= remained ? remained : time
        
        return time >= remained ? remained : time
    }
    
    func reset() {
        current = 0
        extra = 0
    }
}
