//
//  JSTimer.swift
//  timer
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift

/// the timer process object
class JSTimer: EventStreamProtocol {
    // MARK: - constants
    private let TIME_INTERVAL: TimeInterval = 0.1 // Seconds
    
    enum Event {
        case stateChanged(State, item: Recordable)
        case timeChanged(TimeInterval, TimeInterval, diff: TimeInterval)
    }
    
    /// The state of timer
    enum State {
        case stop
        case run
        case pause
        case end
    }
    
    // MARK: - properties
    // Event stream of the timer
    var event: PublishSubject<Event> = PublishSubject()
    // The timer state
    var state: State = .stop {
        didSet {
            guard oldValue != state else { return }
            event.onNext(.stateChanged(state, item: item))
        }
    }
    
    // The model data of the timer
    var item: Recordable
    private var disposableTimer: Disposable? {
        didSet {
            guard let previousDisposable = oldValue, disposableTimer == nil else { return }
            // Disposes timer if new value is `nil`
            previousDisposable.dispose()
        }
    }
    
    // MARK: - constructor
    init(item: Recordable) {
        self.item = item
    }
    
    // MARK: - private method
    /// Update timer item when received timer tick
    private func update() {
        // Consume time interval
        item.consume(time: TIME_INTERVAL)
        // Emit time changed event
        event.onNext(.timeChanged(item.current, item.end, diff: TIME_INTERVAL))

        if item.isEnded {
            end()
        }
    }
    
    // MARK: - public method
    /// Fire the timer. timer state be `run` after call
    func start() {
        disposableTimer?.dispose()
        disposableTimer = Observable<Int>.interval(.milliseconds(Int(TIME_INTERVAL * 1000)),
                                                   scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.update() })
        
        state = .run
    }
    
    /// Pause the timer. timer state be `pause` after call
    func pause() {
        guard disposableTimer != nil else {
            Logger.warning("Can't pause the timer because the timer isn't running.", tag: "TIMER")
            return
        }
        // Dispose timer subscription
        disposableTimer = nil
    
        state = .pause
    }
    
    /// Stop the timer and reset to initial data. timer state be `stop` after call
    func stop() {
        // Dispose timer subscription
        disposableTimer = nil
        
        // Reset recordable item data
        item.reset()
        
        state = .stop
    }
    
    /// End the timer. timer state be `end` after call
    func end() {
        disposableTimer = nil
        
        state = .end
    }
    
    deinit {
        Logger.verbose()
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
