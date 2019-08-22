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
        case timerChanged(_ timer: TimerInfo, at: Int)
        case timeChanged(current: TimeInterval, end: TimeInterval)
    }
    
    /// The state of timer
    enum State: Equatable {
        case initialize
        case stop
        case run(repeat: Int)
        case pause
        case end(detail: TimeSetInfo.EndState)
    }
    
    // Event stream of the timer set
    var event: PublishSubject<TimeSet.Event> = PublishSubject()
    
    // MARK: - properties
    var info: TimeSetInfo // The model data of the timer set
    var state: State = .initialize {
        didSet {
            if oldValue != state {
                event.onNext(.stateChanged(state))
            }
        }
    }
    
    // Timer
    var timer: TMTimer? // Current timer
    var currentIndex: Int = 0 {
        didSet { event.onNext(.timerChanged(info.timers[currentIndex], at: currentIndex)) }
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(info: TimeSetInfo) {
        self.info = info
    }
    
    // MARK: - private method
    /// Handle the timer event from current running timer
    private func handleTimerStateChanged(state: TMTimer.State) {
        guard case .run(repeat: _) = self.state else { return }
        
        switch state {
        case .end:
            if currentIndex + 1 < info.timers.count {
                // Start next timer
                start(at: currentIndex + 1)
            } else {
                if info.isRepeat {
                    // Repeat time set
                    reset(withState: false)
                    
                    info.repeatCount += 1
                    start(at: 0)
                } else {
                    // End of time set
                    self.state = .end(detail: .normal)
                    
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: - public method
    /// Start the current timer
    func start(at index: Int? = nil) {
        if case .end(detail: _) = state {
            Logger.debug("Can't start time set that state is `.end(detail: _)` before call reset(withState:).")
            return
        }
        
        let timer: TMTimer
        if let index = index {
            // Start new timer
            guard index < info.timers.count else { return }
            
            currentIndex = index
            timer = TMTimer(info: info.timers[index])

            // Bind timer event
            timer.event
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] in
                    switch $0 {
                    case let .stateChanged(state):
                        self?.handleTimerStateChanged(state: state)
                        
                    case let .timeChanged(current: currentTime, end: endTime):
                        self?.event.onNext(.timeChanged(current: currentTime, end: endTime))
                    }
                })
                .disposed(by: disposeBag)
        } else {
            guard let currentTimer = self.timer else { return }
            // Restart timer
            timer = currentTimer
        }
        
        self.state = .run(repeat: self.info.repeatCount)
        timer.start()
        
        self.timer = timer
    }
    
    /// Pause current running timer
    func pause() {
        guard let timer = timer else {
            Logger.debug("Can't pause the time set because the time set isn't running.")
            return
        }
        state = .pause
        timer.pause()
    }
    
    /// Stop the time set
    func stop() {
        state = .end(detail: .cancel)
        timer?.stop()
        timer = nil
    }
    
    /// Reset the time set
    func reset(withState: Bool = true) {
        guard state != .initialize else { return }
        
        // Reset all timer status
        state = withState ? .initialize : .stop
        timer?.reset()
        timer = nil
        
        info.timers.forEach {
            $0.currentTime = 0
            $0.extraTime = 0
        }
        
        if withState {
            // Time set reset to initialization status
            info.repeatCount = 0
            info.endState = nil
        }
    }
    
    deinit {
        Logger.verbose()
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
