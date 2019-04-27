//
//  TimerSet.swift
//  timerset-ios
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

/// A class that manage a group of the timers
class TimerSet: EventStreamProtocol {
    enum Event {
        case changeState(TimerInfo.State)
    }
    // Event stream of the timer set
    var event: PublishSubject<TimerSet.Event> = PublishSubject()
    
    // MARK: - properties
    var info: TimerSetInfo // The model data of the timer set
    
    private var timers: [JSTimer] // Timer list
    private var currentTimerIndex: Int? // Current executing timer index in the timer set
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(info: TimerSetInfo) {
        self.info = info
        self.timers = info.timers.map { JSTimer(info: $0) }
        // bind timers event
        self.timers.forEach(bind(timer:))
    }
    
    // MARK: - public method
    // MARK: manipulate timer
    /**
     Create a timer and add in the timer set
     
     - parameters:
        - info: The timer info to create JSTimer
     */
    func createTimer(info: TimerInfo) -> Observable<JSTimer> {
        let timer = JSTimer(info: info)
        
        self.info.timers.append(info) // Add timer info data
        timers.append(timer) // Add timer object
        
        bind(timer: timer) // Bind timer event
        
        return Observable.just(timer)
    }
    
    /**
     Delete the timer in the timer set
     
     - parameters:
        - at: Index that want to remove the timer in the timer set
     */
    func deleteTimer(at: Int) {
        info.timers.remove(at: at)
        timers.remove(at: at)
    }
    
    /**
     Update timer info in the timer set
     
     - parameters:
         - info: The data model of timer
         - at: Index that want to update the data model of timer in the timer set
     */
    func updateTimer(info: TimerInfo, at: Int) {
        self.info.timers[at] = info
    }
    
    // MARK: operate timer set
    /**
     Start the first timer or paused timer
     
     - parameters:
         - at: Index of the timer to start
     */
    func startTimerSet() {
        if let index = currentTimerIndex {
            timers[index].startTimer()
        } else {
            guard let timer = timers.first else { return }
            timer.startTimer()
            currentTimerIndex = 0
        }
    }
    
    /// Pause current executing timer
    func pauseTimerSet() {
        guard let index = currentTimerIndex else { return }
        timers[index].pauseTimer()
    }
    
    /// Stop current executing timer
    func stopTimerSet() {
        guard let index = currentTimerIndex else { return }
        timers[index].stopTimer()
    }
    
    // MARK: - private method
    /**
     Bind timer event
     
     - parameters:
         - timer: The timer to bind event
     */
    private func bind(timer: JSTimer) {
        timer.event
            .debug()
            .subscribe(onNext: {
                switch $0 {
                case let .changeState(state):
                    // Set timer set state from timer's state
                    switch state {
                    case .start:
                        fallthrough
                    case .pause:
                        fallthrough
                    case .stop:
                        self.info.state = state
                    case .end:
                        // Stop timer set when the last timer ended
                        if timer === self.timers.last {
                            Logger.debug("the timer set was ended.")
                            self.info.state = .end
                        } else {
                            // Start next timer when current timer state be `end`
                            guard let index = self.currentTimerIndex, index < self.timers.count else { return }
                            self.timers[index].startTimer()
                        }
                    }
                }
            }, onDisposed: {
                Logger.debug("a timer disposed.")
            })
            .disposed(by: disposeBag)
    }
}
