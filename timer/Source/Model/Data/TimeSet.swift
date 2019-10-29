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
        case timerChanged(TimerItem, at: Int)
        case timeChanged(current: TimeInterval, end: TimeInterval)
    }
    
    /// The state of timer
    enum State {
        case stop
        case run
        case pause
        case end
    }
    
    // MARK: - properties
    // Event stream of the time set
    var event: PublishSubject<TimeSet.Event> = PublishSubject()
    // The time set state
    var state: State = .stop {
        didSet {
            guard oldValue != state else { return }
            event.onNext(.stateChanged(state))
        }
    }
    
    var item: TimeSetItem // The model data of the time set
    var history: History // History data of the time set
    
    var timer: JSTimer? // The current running timer
    private(set) var currentIndex: Int {
        didSet { event.onNext(.timerChanged(item.timers[currentIndex], at: currentIndex)) }
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(item: TimeSetItem, index: Int = 0) {
        self.item = item
        history = History(item: item)
        currentIndex = index
    }
    
    // MARK: - private method
    private func createTimer(at index: Int? = nil) -> JSTimer? {
        var timer: JSTimer
        if let index = index {
            guard (0 ..< item.timers.count).contains(index) else { return nil }
            
            // Create normal timer
            timer = JSTimer(item: item.timers[index])
        } else {
            // Create overtimer
            let overtimer = item.overtimer ?? StopwatchItem()
            item.overtimer = overtimer
            
            timer = JSTimer(item: overtimer)
        }
        
        // Bind timer event
        timer.event
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case let .stateChanged(state, item: item):
                    self?.handleTimerStateChanged(state, item: item)
                    
                case let .timeChanged(current: currentTime, end: endTime):
                    self?.event.onNext(.timeChanged(current: currentTime, end: endTime))
                }
            })
            .disposed(by: disposeBag)
        
        return timer
    }
    
    /// Handle the timer event from current running timer
    private func handleTimerStateChanged(_ state: JSTimer.State, item: Recordable) {
        switch state {
        case .stop:
            break
            
        case .pause:
            self.state = .pause
            
        case .run:
            self.state = .run

        case .end:
            // Add ran timer's current time
            history.runningTime += item.current
            
            guard item as? TimerItem != nil else {
                // End of overtime time set
                history.endState = .overtime
                end()
                return
            }
            
            guard item.isEnded else {
                // Canceled
                history.endState = .cancel
                end()
                return
            }
            
            if currentIndex < self.item.timers.count - 1 {
                // Start next timer
                start(at: currentIndex + 1)
            } else {
                // The last timer ended
                if self.item.isRepeat {
                    // Repeat
                    history.repeatCount += 1
                    stop()
                    start(at: 0)
                } else {
                    // End of time set
                    history.endState = .normal
                    end()
                }
            }
        }
    }
    
    // MARK: - public method
    /// Start the time set
    /// - parameter index: start index of the time set's timers. (default `nil`). if this value `nil`, start timer at current index
    func start(at index: Int? = nil) {
        var timer: JSTimer
        if let index = index {
            // Start the timer at specific index
            guard let newTimer = createTimer(at: index) else {
                Logger.warning("Can't start timer at \(index).", tag: "TIME SET")
                return
            }
            
            currentIndex = index
            timer = newTimer
        } else if let currentTimer = self.timer {
            // Start current timer
            timer = currentTimer
        } else {
            // Create timer at current index if not exist
            guard let newTimer = createTimer(at: currentIndex) else {
                Logger.warning("Can't start timer at current index (\(currentIndex)).", tag: "TIME SET")
                return
            }
            timer = newTimer
        }
        
        // Start the timer
        timer.start()
        self.timer = timer
    }
    
    /// Pause the time set
    func pause() {
        guard let timer = timer else {
            Logger.warning("Can't pause the timer. because timer isn't running", tag: "TIME SET")
            return
        }
        timer.pause()
    }
    
    /// Stop the time set
    func stop() {
        timer?.stop()
        item.timers.forEach { $0.reset() }
    }
    
    /// End the time set
    func end() {
        timer?.end(isMute: true)
    }
    
    /// Consume time to the time set
    /// - parameters:
    ///   - time: the time to consume of the time set
    ///   - withRepeat: flag to perform in consideration of repetition (default `false`)
    func consume(time: TimeInterval, withRepeat: Bool = false) {
        if let overtimer = item.overtimer {
            // The time set is running in overtime
            // Consume time to over timer
            overtimer.consume(time: time)
            timer = createTimer()
        } else {
            // Set time to mutable value
            var time = time
            
            var index = currentIndex
            while true {
                // Consume time to timer
                let timer = item.timers[index]
                time = timer.consume(time: time)
                // Break loop if spent all time
                guard time > 0 else { break }

                if index < item.timers.count - 1 {
                    index += 1
                    history.runningTime += timer.current
                } else {
                    // Break loop if timer is last element of the time set. and it isn't repeat
                    guard item.isRepeat else { break }

                    index = 0
                    history.runningTime += timer.current
                    history.repeatCount += 1
                    item.timers.forEach { $0.reset() }

                    guard withRepeat else { break }
                }
            }

            currentIndex = index
            timer = createTimer(at: index)
        }
    }
    
    deinit {
        Logger.verbose()
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
