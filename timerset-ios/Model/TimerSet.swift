//
//  TimerSet.swift
//  timerset-ios
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// A class that manage a group of timers
class TimerSet {
    /// A state of timer set
    enum State {
        case stop
        case start
        case pause
        case end
    }
    
    // MARK: properties
    var timers: [JSTimer] // Timer list
    var state: State // Current state of timer set
    
    private var currentTimer: JSTimer?
    
    // MARK: constructor
    init(timers: [JSTimer]) {
        self.timers = timers
        self.state = .stop
    }
    
    // MARK: public method
    /**
     Add the timer in the timer set
    
     - parameters:
       - timer: the timer object that want to include in the timer set
     */
    func addTimer(_ timer: JSTimer) {
        timers.append(timer)
    }
    
    /**
     Remove the timer in the timer set
     
     - parameters:
       - at: index that want to remove the timer in the timer set
     */
    func removeTimer(at: Int) {
        timers.remove(at: at)
    }
    
    /**
     Update timer info in the timer set
     
     - parameters:
       - info: the data model of timer
       - at: index that want to update the data model of timer in the timer set
     */
    func updateTimer(info: TimerInfo, at: Int) {
        timers[at].info = info
    }
}
