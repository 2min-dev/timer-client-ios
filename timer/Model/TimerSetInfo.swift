//
//  TimerSetInfo.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

class TimerSetInfo: Codable {
    // MARK: properties
    var name: String // Name of the timer set
    var description: String // Description of the timer set
    var state: TimerInfo.State // Current state of the timer set
    
    var timers: [TimerInfo] // Timer info list of the timer set
    
    // MARK: constructor
    init(name: String, description: String, state: TimerInfo.State, timers: [TimerInfo]) {
        self.name = name
        self.description = description
        self.state = state
        self.timers = timers
    }
    
    convenience init(name: String, description: String) {
        self.init(name: name, description: description, state: .stop, timers: [])
    }
}
