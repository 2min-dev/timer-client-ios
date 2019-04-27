//
//  TimerInfo.swift
//  timerset-ios
//
//  Created by JSilver on 20/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

/// The timer data present object
class TimerInfo: Codable {
    /// The state of timer
    enum State: Int, Codable {
        case stop = 0
        case start
        case pause
        case end
    }
    
    // MARK: properties
    var title: String // The title of the timer
    var currentTime: TimeInterval // Current time interval of the timer
    var endTime: TimeInterval // Target end time interval of the timer
    var state: State // Current state of the timer
    
    // MARK: constructor
    init(title: String, currentTime: TimeInterval, endTime: TimeInterval, state: State) {
        self.title = title
        self.currentTime = currentTime
        self.endTime = endTime
        self.state = state
    }
    
    convenience init(title: String, endTime: TimeInterval) {
        self.init(title: title, currentTime: 0, endTime: endTime, state: .stop)
    }
}
