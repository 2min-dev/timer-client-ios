//
//  TimeSetInfo.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

class TimeSetInfo: Codable {
    // MARK: properties
    var title: String // Name of the timer set
    var description: String // Description of the timer set
    
    var isLoop: Bool // Is timer loop of the time set
    
    var state: TimerInfo.State // Current state of the timer set
    
    var timers: [TimerInfo] // Timer info list of the timer set
    
    // MARK: constructor
    init(title: String = "", description: String = "", isLoop: Bool = false, state: TimerInfo.State = .stop, timers: [TimerInfo] = []) {
        self.title = title
        self.description = description
        self.state = state
        self.timers = timers
        self.isLoop = isLoop
    }
}
