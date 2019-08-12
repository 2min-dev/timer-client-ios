//
//  TMTimer.swift
//  timer
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// the timer process object
class TMTimer: EventStreamProtocol {
    enum Event {
        case changeState(State)
    }
    
    /// The state of timer
    enum State: Int, Codable {
        case stop = 0
        case start
        case pause
        case end
    }
    
    enum RecordType: Int, Codable {
        case regular = 0
        case overtime
    }
    
    // Event stream of the timer
    var event: PublishSubject<Event> = PublishSubject()
    
    // MARK: - properties
    var info: TimerInfo // The model data of the timer
    let type: RecordType // Recode type of the timer
    // The timer state
    var state: State = .stop {
        didSet { event.onNext(.changeState(state)) }
    }
    
    private var disposeTimer: Disposable?
    
    // MARK: - constructor
    init(info: TimerInfo, type: RecordType = .regular) {
        self.info = info
        self.type = type
    }
    
    // MARK: - private method
    /// Update timer info when received timer tick
    private func updateTimer() {
        info.currentTime += 0.5
        
        Logger.debug(#"the timer updated. "\#(info.title)" - \#(info.currentTime) / \#(info.endTime)"#)
        // End timer when current time interval of the timer is equal end time interval
        if type != .overtime && info.currentTime >= info.endTime {
            stopTimer(isFinish: true)
        }
    }
    
    // MARK: - public method
    /// Fire the timer
    func startTimer() {
        disposeTimer?.dispose()
        disposeTimer = Observable<Int>.timer(.milliseconds(500),
                                             period: .milliseconds(500),
                                             scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] _ in self?.updateTimer() })
        
        state = .start
    }
    
    /// Pause the timer
    func pauseTimer() {
        guard let disposeTimer = disposeTimer else {
            Logger.debug("Can't pause the timer because the timer not running.")
            return
        }
        
        // Dispose timer subscription
        disposeTimer.dispose()
        self.disposeTimer = nil
    
        state = .pause
    }
    
    /// Stop the timer
    func stopTimer(isFinish: Bool = false) {
        guard let disposeTimer = disposeTimer else {
            Logger.debug("Can't stop the timer because the timer not running.")
            return
        }
        
        // Dispose timer subscription
        disposeTimer.dispose()
        self.disposeTimer = nil
    
        state = isFinish ? .end : .stop
    }
    
    deinit {
        Logger.verbose()
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
