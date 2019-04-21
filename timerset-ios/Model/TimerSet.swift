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
        guard info.timers.count > at else {
            Logger.debug("The timer set is empty.")
            return
        }
        
        currentTimerIndex = at
        
        let currentTimer = timers[at]
        currentTimer.startTimer()
        
        currentTimer.stateSubject
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                switch $0 {
                case .end:
                    self.startTimerSet(at: at + 1)
                default:
                    Logger.debug("Timer state is \($0)")
                }
            })
            .disposed(by: disposeBag)
    }
}
