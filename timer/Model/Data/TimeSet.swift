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
        case stateChanged(State)
        case timerChanged(at: Int)
    }
    
    /// The state of timer
    enum State: Int, Codable {
        case stop = 0
        case start
        case pause
        case end
    }
    
    // Event stream of the timer set
    var event: PublishSubject<TimeSet.Event> = PublishSubject()
    
    // MARK: - properties
    var info: TimeSetInfo // The model data of the timer set
    var state: State = .stop {
        didSet { event.onNext(.stateChanged(state)) }
    }
    
    private var timer: TMTimer? // Current timer
    private var currentIndex: Int = 0 {
        didSet { event.onNext(.timerChanged(at: currentIndex)) }
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(info: TimeSetInfo) {
        self.info = info
    }
    
    // MARK: - private method
    private func handleTimerStateChanged(state: TMTimer.State) {
        switch state {
        case .start:
            self.state = .start
        case .pause:
            self.state = .pause
        case .stop:
            self.state = .stop
        case .end:
            if timer?.type == .some(.overtime) {
                // End of overtime timer
                self.state = .end
            } else {
                if currentIndex + 1 < info.timers.count {
                    // Start next timer
                    startTimeSet(at: currentIndex + 1)
                } else {
                    if info.isLoop {
                        // Loop time set
                        startTimeSet(at: 0)
                    } else {
                        // End of time set
                        self.state = .end
                    }
                }
            }
        }
    }
    
    // MARK: - public method
    /// Start the current timer
    func startTimeSet(at index: Int? = nil) {
        if let index = index {
            timer?.stopTimer()
            var timer: TMTimer
            if index < info.timers.count {
                // Restart time set from a specific timer
                currentIndex = index
                timer = TMTimer(info: info.timers[currentIndex])
            } else {
                // Start overtime timer
                info.overtimer = TimerInfo(title: "초과 타이머")
                timer = TMTimer(info: info.overtimer!, type: .overtime)
            }

            // Bind timer event
            timer.event
                .subscribe(onNext: { [weak self] event in
                    switch event {
                    case let .changeState(state):
                        self?.handleTimerStateChanged(state: state)
                    }
                })
                .disposed(by: disposeBag)
            // Start the timer
            timer.startTimer()
            
            self.timer = timer
        } else {
            // Restart timer
            guard let timer = timer else { return }
            timer.startTimer()
        }
    }
    
    /// Pause current executing timer
    func pauseTimeSet() {
        timer?.pauseTimer()
    }
    
    /// Stop timer set
    func stopTimeSet(isFinish: Bool = false) {
        timer?.stopTimer(isFinish: isFinish)
    }
    
    deinit {
        Logger.verbose()
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
