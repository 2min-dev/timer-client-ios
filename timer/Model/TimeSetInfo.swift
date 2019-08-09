//
//  TimeSetInfo.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

class TimeSetInfo: Codable, NSCopying {
    // MARK: - properties
    var title: String // Name of the timer set
    var description: String // Description of the timer set
    
    var isLoop: Bool // Is timer loop of the time set
    
    var state: TimerInfo.State // Current state of the timer set
    
    var timers: [TimerInfo] // Timer info list of the timer set
    
    // MARK: - constructor
    init(title: String = "", description: String = "", isLoop: Bool = false, state: TimerInfo.State = .stop, timers: [TimerInfo] = []) {
        self.title = title
        self.description = description
        self.state = state
        self.timers = timers
        self.isLoop = isLoop
        
        if self.timers.isEmpty {
            self.timers.append(TimerInfo(title: String(format: "timer_default_title".localized, 1)))
        }
    }
    
    // MARK: - public method
    func copy(with zone: NSZone? = nil) -> Any {
        return TimeSetInfo(title: title, description: description, isLoop: isLoop, state: state, timers: timers.compactMap { $0.copy() as? TimerInfo })
    }
    
    /// Clear time set info
    func clear() {
        title = ""
        description = ""
        isLoop = false
        state = .stop
        timers = [TimerInfo(title: String(format: "timer_default_title".localized, 1))]
    }
}
