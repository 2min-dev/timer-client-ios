//
//  TimeSet.swift
//  timer
//
//  Created by JSilver on 21/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import AVFoundation

/// A class that manage a group of the timers
class TimeSet: EventStreamProtocol {
    enum Event {
        case stateChanged(State)
        case timerChanged(JSTimer, at: Int)
        case timeChanged(TimeInterval, TimeInterval)
    }
    
    /// The state of timer
    enum State {
        case stop
        case run
        case pause
        case end
    }
    
    enum StartType {
        case normal(at: Int)
        case overtime
    }
    
    // MARK: - properties
    // Event stream of the time set
    var event: PublishSubject<TimeSet.Event> = PublishSubject()
    // The time set state
    var state: State = .stop {
        didSet {
            guard oldValue != state else { return }
            
            switch state {
            case .run:
                // Set start date of time set to history
                if history.startDate == nil {
                    history.startDate = Date()
                }
                
            case .end:
                history.endDate = Date()
                
            default:
                break
            }
            
            event.onNext(.stateChanged(state))
        }
    }
    
    private(set) var item: TimeSetItem // The model data of the time set
    private(set) var history: History // History data of the time set
    
    private(set) var timer: JSTimer! {
        didSet { event.onNext(.timerChanged(timer, at: currentIndex)) }
    }
    private(set) var currentIndex: Int
    
    private var disposeBag = DisposeBag()
    
    /// Alarm sound player
    private(set) var audioPlayer: AVAudioPlayer?
    
    // MARK: - constructor
    init(item: TimeSetItem, history: History, index: Int) {
        self.item = item
        self.history = history
        currentIndex = index
        timer = createTimer(at: index)
    }
    
    convenience init(item: TimeSetItem, index: Int) {
        self.init(item: item, history: History(item: item, isSaved: item.id != nil), index: index)
    }
    
    // MARK: - private method
    private func createTimer(at index: Int? = nil) -> JSTimer {
        var timer: JSTimer
        if var index = index {
            // Set default timer index 0
            index = (0 ..< item.timers.count).contains(index) ? index : 0
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
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case let .stateChanged(state, item: item):
                    self?.handleTimerStateChanged(state, item: item)
                    
                case let .timeChanged(current, end, diff: diff):
                    self?.handleTimeChanged(current, end, diff: diff)
                }
            })
            .disposed(by: disposeBag)
        
        return timer
    }
    
    /// Handle the timer event that current running timer state changed
    private func handleTimerStateChanged(_ state: JSTimer.State, item: Recordable) {
        switch state {
        case .stop:
            self.state = .stop
            
        case .pause:
            self.state = .pause
            
        case .run:
            self.state = .run

        case .end:
            guard item as? TimerItem != nil else {
                // End of overtime time set
                history.endState = .overtime
                self.state = .end
                return
            }
            
            guard item.isEnded else {
                // Canceled
                history.endState = .cancel
                self.state = .end
                return
            }
            
            if let alertable = item as? Alertable {
                // Alert if ended timer accept `Alertable`
                alert(alarm: alertable.alarm)
            }
            
            if currentIndex < self.item.timers.count - 1 {
                // Start next timer
                start(.normal(at: currentIndex + 1))
            } else {
                // The last timer ended
                if self.item.isRepeat {
                    // Repeat
                    history.repeatCount += 1
                    stop()
                    start(.normal(at: 0))
                } else {
                    // End of time set
                    history.endState = .normal
                    self.state = .end
                }
            }
        }
    }
    
    /// Handle the timer event that time changed
    private func handleTimeChanged(_ current: TimeInterval, _ end: TimeInterval, diff: TimeInterval) {
        history.runningTime += diff
        event.onNext(.timeChanged(current, end))
    }
    
    /// Alert alarm through `AVAudioPlayer`
    /// - Parameters:
    ///   - alarm: alarm info to play
    ///   - type: alarm sound type
    private func alert(alarm: Alarm, type: Alarm.SoundType = .short) {
        switch alarm {
        case .default:
            guard let fileName = alarm.getFileName(type: type),
                let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
            
            // Alert alarm
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            // Vibrate if device is vibrate mode
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
        case .vibrate:
            // Play vibration on device
            AudioServicesPlaySystemSound(1352) // Always vibrate regardless device mode
            
        case .silence:
            // Nothing
            break
        }
    }
    
    // MARK: - public method
    /// Start the time set
    /// - parameter type: start time set type (`.normal || .overtime`) (default `nil`). if this value `nil`, resume timer at current timer
    func start(_ type: StartType? = nil) {
        if let type = type {
            switch type {
            case let .normal(at: index):
                currentIndex = (0 ..< item.timers.count).contains(index) ? index : 0
                timer = createTimer(at: currentIndex)
                
            case .overtime:
                timer = createTimer()
            }
        }
        
        timer.start()
    }
    
    /// Pause the time set
    func pause() {
        timer.pause()
    }
    
    /// Stop the time set
    func stop() {
        timer.stop()
        // Reset time set data
        item.reset()
    }
    
    /// End the time set
    func end() {
        timer.end()
    }
    
    /// Consume time to the time set
    /// - parameters:
    ///   - time: the time to consume of the time set
    ///   - withRepeat: flag to perform in consideration of repetition (default `false`)
    func consume(time: TimeInterval, withRepeat: Bool = false) {
        if let overtimer = item.overtimer {
            // The time set is running in overtime
            // Consume time to over timer
            let consumedTime = overtimer.consume(time: time)
            history.runningTime += consumedTime
            
            timer = createTimer()
        } else {
            // Set time to mutable value
            var time = time
            
            var index = currentIndex
            while true {
                // Consume time to timer
                let timer = item.timers[index]
                let consumedTime = timer.consume(time: time)
                history.runningTime += consumedTime
                
                // Break loop if spent all time
                time -= consumedTime
                guard time > 0 else { break }
                
                if index < item.timers.count - 1 {
                    index += 1
                } else {
                    // Break loop if timer is last element of the time set. and it isn't repeat
                    guard item.isRepeat else { break }
                    
                    history.repeatCount += 1
                    index = 0
                    item.reset()

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
