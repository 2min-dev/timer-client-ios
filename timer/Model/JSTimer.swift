//
//  Timer.swift
//  timer
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// the timer process object
class JSTimer: EventStreamProtocol {
    enum Event {
        case changeState(TimerInfo.State)
    }
    
    // Event stream of the timer
    var event: PublishSubject<Event> = PublishSubject()
    
    // MARK: - properties
    var info: TimerInfo // The model data of the timer
    private var timer: Timer? // A object of the timer
    
    // MARK: - constructor
    init(info: TimerInfo) {
        self.info = info
    }
    
    // MARK: - selector
    /// Update timer info when received timer tick
    private func updateTimer(_ timer: Timer) {
        info.currentTime += 1
        
        Logger.debug(#"the timer updated. "\#(info.title)" - \#(info.currentTime) / \#(info.endTime)"#)
        // End timer when current time interval of the timer is equal end time interval
        if info.currentTime == info.endTime {
            endTimer()
        }
    }
    
    // MARK: - public method
    /// Fire the timer
    func startTimer() {
        // Invalidate timer
        timer?.invalidate()
        // Scheduled timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: updateTimer(_ :))
        timer?.tolerance = 0.1
        
        info.state = .start
        // Send state changed event
        event.onNext(.changeState(info.state))
    }
    
    /// Pause the timer
    func pauseTimer() {
        if let timer = timer {
            // Remove timer
            // Invalidate timer to remove from run loop
            timer.invalidate()
            self.timer = nil
            
            info.state = .pause
            
            // Send state changed event
            event.onNext(.changeState(info.state))
        } else {
            Logger.error("Can't pause the timer because the timer object is nil.")
        }
    }
    
    /// Stop the timer
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    
        info.currentTime = 0
        info.state = .stop
        
        // Send state changed event
        event.onNext(.changeState(info.state))
    }
    
    /// End the timer
    private func endTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        
            info.currentTime = info.endTime
            info.state = .end
            
            // Send state changed event
            event.onNext(.changeState(info.state))
        } else {
            Logger.error("Can't end the timer because the timer object is nil.")
        }
    }
    
    deinit {
        // dispose event stream when timer deinited
        event.on(.completed)
    }
}
