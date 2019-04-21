//
//  TimerSet.swift
//  timerset-ios
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

/// A class that manage a group of timers
class TimerSet {
    // MARK: properties
    var info: TimerSetInfo
    var timers: [JSTimer] // Timer list
    
    private var currentTimer: JSTimer?
    
    init(info: TimerSetInfo, timers: [JSTimer]) {
        self.info = info
        self.timers = timers
    }
    
    convenience init(info: TimerSetInfo) {
        self.init(info: info, timers: [])
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
