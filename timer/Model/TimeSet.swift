//
//  TimeSet.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift

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
    private var currentTimerIndex: Int? // Current executing timer index in the timer set
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(info: TimeSetInfo) {
        self.info = info
        self.timers = info.timers.map { TMTimer(info: $0) }

        // bind timers event
        self.timers.forEach(bind(timer:))
    }
    
    // MARK: - public method
    // MARK: manipulate timer
    /// Create a timer
    func createTimer(info: TimerInfo) -> Observable<TMTimer> {
        let timer = TMTimer(info: info)
        
        self.info.timers.append(info) // Add timer info data
        timers.append(timer) // Add timer object
        
        bind(timer: timer) // Bind timer event
        
        return Observable.just(timer)
    }

    /// Delete the timer
    func deleteTimer(at: Int) -> Observable<TMTimer> {
        self.info.timers.remove(at: at)
        let timer = self.timers.remove(at: at)
        
        return Observable.just(timer)
    }
    
    // MARK: operate timer set
    /// Start the first timer or paused timer
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
    
    /// Stop timer set (initialize)
    func stopTimerSet() {
        timers.forEach { $0.stopTimer() }
        currentTimerIndex = nil
    }
    
    // MARK: - private method
    /// Bind to timer's event stream
    private func bind(timer: TMTimer) {
        timer.event
            .subscribe(onNext: { [weak timer] event in
                switch event {
                case let .changeState(state):
                    // Set timer set state from timer's state
                    switch state {
                    case .start:
                        fallthrough
                    case .pause:
                        fallthrough
                    case .stop:
                        self.info.state = state
                        self.event.onNext(.changeState(self.info.state))
                    case .end:
                        // Stop timer set when the last timer ended
                        if timer === self.timers.last {
                            Logger.debug("the timer set was ended.")
                            self.info.state = .end
                            self.event.onNext(.changeState(self.info.state))
                        } else {
                            // Start next timer when current timer state be `end`
                            guard let index = self.currentTimerIndex, index + 1 < self.timers.count else { return }
                            self.currentTimerIndex = index + 1
                            self.timers[index + 1].startTimer()
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
