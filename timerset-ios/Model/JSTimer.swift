//
//  Timer.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift

/// the timer process object
class JSTimer {
    // MARK: properties
    private var info: TimerInfo // The model data of the timer
    private var timer: Timer? // A object of the timer
    
    let stateSubject: BehaviorSubject<TimerInfo.State>
    
    // MARK: constructor
    init(info: TimerInfo) {
        self.info = info
        self.stateSubject = BehaviorSubject(value: info.state)
    }
    
    // MARK: selector
    
    /// Update timer info when received timer tick
    @objc private func updateTimer() {
        info.currentTime += 1
        // End timer when current time interval of timer is equal end time interval
        if info.currentTime == info.endTime {
            endTimer()
        }
        
        Logger.debug(#"the timer updated. "\#(info.title)" - \#(info.currentTime) / \#(info.endTime)"#)
    }
    
    // MARK: public method
    /// Fire the timer
    func startTimer() {
        if timer == nil {
            // Create timer
            timer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timer?.tolerance = 0.1
            
            // Add timer in run loop
            RunLoop.current.add(timer!, forMode: .common)
        }
        
        info.state = .start
        timer?.fire()
    }
    
    /// Pause the timer
    func pauseTimer() {
        if let timer = timer {
            // Remove timer
            // Invalidate timer to remove from run loop
            timer.invalidate()
            self.timer = nil
            
            info.state = .pause
        } else {
            Logger.error("Can't pause the timer because the timer object is nil.")
        }
    }
    
    /// Stop the timer
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            
            info.currentTime = 0
            info.state = .stop
        } else {
            Logger.error("Can't stop the timer because the timer object is nil.")
        }
    }
    
    /// End the timer
    private func endTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        
            info.currentTime = info.endTime
            info.state = .end
            
            stateSubject.onNext(info.state)
        } else {
            Logger.error("Can't end the timer because the timer object is nil.")
        }
    }
}
