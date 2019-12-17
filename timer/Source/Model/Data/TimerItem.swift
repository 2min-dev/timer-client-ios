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
        current >= end
    }
    
    enum CodingKeys: String, CodingKey {
        case comment
        case alarm
        case current
        case target = "end"
        case extra
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
    
    // MARK: - decoable
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        comment = try container.decode(String.self, forKey: .comment)
        alarm = try container.decode(Alarm.self, forKey: .alarm)
        current = (try? container.decode(TimeInterval.self, forKey: .current)) ?? 0
        target = try container.decode(TimeInterval.self, forKey: .target)
        extra = (try? container.decode(TimeInterval.self, forKey: .extra)) ?? 0
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
