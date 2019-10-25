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
    
    /// The state of time set running
    enum RunState {
        case normal
        case overtime
    }
    
    /// The state of timer
    enum State: Equatable {
        case initialize
        case stop(repeat: Int)
        case run(detail: RunState)
        case pause
        case end(detail: TimeSetInfo.EndState)
    }
    
    // Event stream of the timer set
    var event: PublishSubject<TimeSet.Event> = PublishSubject()
    
    // MARK: - properties
    var info: TimeSetInfo // The model data of the timer set
    var state: State = .initialize {
        didSet {
            if case let .end(detail: detail) = state {
                info.endState = detail
            }
            
            if oldValue != state {
                event.onNext(.stateChanged(state))
            }
        }
    }
    
    // Timer
    var timer: TMTimer? {
        didSet {
            // Add current time of timer into time set for record all running time
            info.runningTime += oldValue?.info.currentTime ?? 0
        }
    }
    private(set) var currentIndex: Int {
        didSet { event.onNext(.timerChanged(info.timers[currentIndex], at: currentIndex)) }
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(info: TimeSetInfo, index: Int = 0) {
        self.info = info
        self.currentIndex = index
    }
    
    // MARK: - private method
    private func createTimer(at index: Int? = nil) -> TMTimer {
        var timer: TMTimer
        if let index = index {
            // Create normal timer
            timer = TMTimer(info: info.timers[index])
        } else {
            // Create overtimer
            let overtimer = TimerInfo()
            info.overtimer = overtimer
            
            timer = TMTimer(info: overtimer, type: .overtime)
        }

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
        
        return timer
    }
    
    /// Handle the timer event from current running timer
    private func handleTimerStateChanged(state: TMTimer.State) {
        switch state {
        case .end:
            // Process time set if it is running
            guard self.state == .run(detail: .normal) else { return }
            if currentIndex + 1 < info.timers.count {
                // Start next timer
                start(at: currentIndex + 1)
            } else {
                if info.isRepeat {
                    // Repeat time set
                    info.repeatCount += 1
                    reset(withState: false)
                    start(at: 0)
                } else {
                    // End of time set
                    self.timer = nil
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
        
        if let index = index {
            // Start new timer
            guard (0 ..< info.timers.count).contains(index) else { return }
            currentIndex = index
            
            // Set timer's current time that before index to end time
            info.timers[0 ..< index].forEach { $0.currentTime = $0.endTime + $0.extraTime }
            timer = createTimer(at: index)
        }
        
        // Create new timer at current index
        if timer == nil {
            timer = createTimer(at: currentIndex)
        }
        
        state = .run(detail: info.overtimer == nil ? .normal : .overtime)
        timer?.start()
    }
    
    /// Start overtime timer and start record
    func startOvertime() {
        guard state == .end(detail: .normal) else { return }
        
        // Create overtime timer
        timer = createTimer()
        timer?.start()
        
        state = .run(detail: .overtime)
    }
    
    /// Pause current running timer
    func pause() {
        guard let timer = timer else {
            Logger.debug("Can't pause the time set because the time set isn't running.")
            return
        }
        timer.pause()
        
        state = .pause
    }
    
    /// Stop the time set
    func stop() {
        timer?.stop()
        timer = nil
        
        state = .end(detail: info.overtimer == nil ? .cancel : .overtime)
    }
    
    /// Reset the time set
    func reset(withState: Bool = true) {
        guard state != .initialize else { return }
        
        // Reset all timer status
        timer?.reset(withState: false)
        timer = nil
        
        state = withState ? .initialize : .stop(repeat: self.info.repeatCount)
        
        info.timers.forEach {
            $0.currentTime = 0
            $0.extraTime = 0
        }
        
        if withState {
            // Time set reset to initialization status
            info.repeatCount = 0
            info.endState = .none
        }
    }
    
    /// Consume time of the time set
    /// - parameters:
    ///   - time: the time to consume of the time set
    ///   - withRepeat: flag to perform in consideration of repetition (default `false`)
    func consume(time: TimeInterval, withRepeat: Bool = false) {
        // Set time to mutable value
        var time = time
        
        var index = currentIndex
        while time > 0 {
            let timer = info.timers[index]
            let remainedTime: TimeInterval = timer.endTime + timer.extraTime - timer.currentTime
            
            if time >= remainedTime {
                timer.currentTime += remainedTime
            } else {
                timer.currentTime += time
                break
            }
            
            if index == info.timers.count - 1 {
                // Break out if index is last index of the time set and time set doesn't perform repeat
                guard info.isRepeat else { break }
                
                // Reset time set state to repeat
                info.repeatCount += 1
                reset(withState: false)
                index = 0
                
                // Break out loop if consume isn't with repeat
                guard withRepeat else { break }
            }
            
            index += 1
            time = max(0, time - remainedTime)
        }
        
        currentIndex = index
        timer = createTimer(at: index)
    }
    
    deinit {
        Logger.verbose()
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
