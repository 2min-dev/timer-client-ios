//
//  TimerSet.swift
//  timerset-ios
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

/// A class that manage a group of the timers
class TimerSet {
    // MARK: properties
    var info: TimerSetInfo // The model data of the timer set
    
    private var timers: [JSTimer] // Timer list
    private var currentTimerIndex: Int? // Current executing timer index in the timer set
    
    private var disposeBag = DisposeBag()
    
    // MARK: constructor
    init(info: TimerSetInfo) {
        self.info = info
        self.timers = info.timers.map { JSTimer(info: $0) }
    }
    
    // MARK: public method
    /**
     Add the timer in the timer set
    
     - parameters:
       - timer: the timer object that want to include in the timer set
     */
    func addTimer(info: TimerInfo) {
        self.info.timers.append(info)
        timers.append(JSTimer(info: info))
    }
    
    /**
     Remove the timer in the timer set
     
     - parameters:
       - at: index that want to remove the timer in the timer set
     */
    func removeTimer(at: Int) {
        info.timers.remove(at: at)
        timers.remove(at: at)
    }
    
    /**
     Update timer info in the timer set
     
     - parameters:
       - info: the data model of timer
       - at: index that want to update the data model of timer in the timer set
     */
    func updateTimer(info: TimerInfo, at: Int) {
        self.info.timers[at] = info
    }
    
    func startTimerSet(at: Int = 0) {
        // Guard unexpected exception about out of range
        guard info.timers.count > at else {
            Logger.error("The timer not exist at \(at) in the timer set.")
            return
        }
        
        // Store timer index to start
        currentTimerIndex = at
        
        let currentTimer = timers[at]
        // Subscribe timer event
        currentTimer.event
            .take(1) // Take just one event that timer state changed. But need to think other way for more complex sequence building
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                switch $0 {
                case let .changeState(state):
                    if state == .end {
                        // Start next timer when current timer state be `end`
                        self.startTimerSet(at: self.currentTimerIndex! + 1)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // Start current timer
        currentTimer.startTimer()
    }
}
