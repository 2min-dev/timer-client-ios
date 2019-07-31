//
//  TimeSet.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

// TODO: Check time set operation (190712)
/// A class that manage a group of the timers
class TimeSet: EventStreamProtocol {
    enum Event {
        case changeState(TimerInfo.State)
    }
    // Event stream of the timer set
    var event: PublishSubject<TimeSet.Event> = PublishSubject()
    
    // MARK: - properties
    var info: TimeSetInfo // The model data of the timer set
    
    private var timers: [TMTimer] // Timer list
    private var currentTimerIndex: Int // Current executing timer index in the timer set
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(info: TimeSetInfo) {
        self.info = info

        self.timers = info.timers.map { TMTimer(info: $0) }
        self.currentTimerIndex = 0

        // bind timers event
        self.timers.forEach(bind(timer:))
    }
    
    // MARK: - public method
    /// Start the current timer
    func startTimeSet(index: Int?) {
        // Stop current executed timer
        timers[currentTimerIndex].stopTimer()
        if let index = index {
            // Start specific timer of time set
            currentTimerIndex = index
            timers[index].startTimer()
        } else {
            // Restart current timer
            timers[currentTimerIndex].startTimer()
        }
    }
    
    /// Pause current executing timer
    func pauseTimeSet() {
        timers[currentTimerIndex].pauseTimer()
    }
    
    /// Stop timer set (initialize)
    func stopTimeSet() {
        // Stop all timers (init)
        timers.forEach { $0.stopTimer() }
        currentTimerIndex = 0
    }
    
    // MARK: - private method
    /// Bind to timer's event stream
    private func bind(timer: TMTimer) {
        timer.event
            .subscribe(onNext: { [weak self] event in  self?.receiveTimerEvent(event)})
            .disposed(by: disposeBag)
    }
    
    /// Process timer evenet when timer event received
    private func receiveTimerEvent(_ event: TMTimer.Event) {
        switch event {
        case let .changeState(state):
            // Set timer set state from timer's state
            switch state {
            case .start:
                fallthrough
            case .pause:
                fallthrough
            case .stop:
                info.state = state
                self.event.onNext(.changeState(info.state))
            case .end:
                if currentTimerIndex + 1 < timers.count {
                    // Start next timer when current timer state be `end`
                    Logger.debug("the next timer(\(currentTimerIndex + 1)) is starting.")
                    currentTimerIndex += 1
                    timers[currentTimerIndex].startTimer()
                } else {
                    // Receive the last timer was ended
                    if info.isLoop {
                        // Restart first timer of time set
                        Logger.debug("the first timer is starting.")
                        currentTimerIndex = 0
                        timers.first?.startTimer()
                    } else {
                        // Stop timer set when the last timer ended
                        Logger.debug("the timer set was ended.")
                        info.state = .end
                        self.event.onNext(.changeState(info.state))
                    }
                }
            }
        }
    }
    
    deinit {
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
