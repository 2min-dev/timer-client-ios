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
import AVFoundation

/// the timer process object
class TMTimer: EventStreamProtocol {
    enum Event {
        case stateChanged(State)
        case timeChanged(current: TimeInterval, end: TimeInterval)
    }
    
    /// The state of timer
    enum State: Int, Codable {
        case stop = 0
        case run
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
        didSet { event.onNext(.stateChanged(state)) }
    }
    
    private var disposableTimer: Disposable?
    
    // MARK: - constructor
    init(info: TimerInfo, type: RecordType = .regular) {
        self.info = info
        self.type = type
    }
    
    // MARK: - private method
    /// Update timer info when received timer tick
    private func update() {
        info.currentTime += 0.1
        event.onNext(.timeChanged(current: info.currentTime, end: info.endTime + info.extraTime))
        
        // End timer when current time interval of the timer is equal end time interval
        if type != .overtime && info.currentTime >= info.endTime + info.extraTime {
            end()
        }
    }
    
    /// Transfer state to `End`
    private func end() {
        disposableTimer?.dispose()
        disposableTimer = nil
        
        info.currentTime = info.endTime + info.extraTime
        state = .end
        
        playAlarm()
    }
    
    private func playAlarm() {
        AudioServicesPlaySystemSound(1005)
    }
    
    // MARK: - public method
    /// Fire the timer
    func start() {
        disposableTimer?.dispose()
        disposableTimer = Observable<Int>.interval(.milliseconds(100),
                                                scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] _ in self?.update() })
        
        state = .run
    }
    
    /// Pause the timer
    func pause() {
        guard let disposableTimer = disposableTimer else {
            Logger.debug("Can't pause the timer because the timer isn't running.")
            return
        }
        // Dispose timer subscription
        disposableTimer.dispose()
        self.disposableTimer = nil
    
        state = .pause
    }
    
    /// Stop the timer
    func stop() {
        // Dispose timer subscription
        disposableTimer?.dispose()
        disposableTimer = nil
        
        state = .end
    }
    
    /// Reset the timer
    func reset() {
        // Dispose timer subscription
        disposableTimer?.dispose()
        disposableTimer = nil
        
        state = .stop
        
        info.currentTime = 0
        info.extraTime = 0
    }
    
    deinit {
        Logger.verbose()
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
