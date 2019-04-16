//
//  Timer.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 16/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation

class TimerModel {
    var title: String
    var currentTime: TimeInterval
    var endTime: TimeInterval
    var state: TimerState
    
    var timer: Timer?
    
    init(title: String, currentTime: TimeInterval, endTime: TimeInterval, state: TimerState) {
        self.title = title
        self.currentTime = currentTime
        self.endTime = endTime
        self.state = state
    }
    
    convenience init(title: String, endTime: TimeInterval) {
        self.init(title: title, currentTime: 0, endTime: endTime, state: .stop)
    }
    
    @objc private func updateTimer() {
        currentTime += 1
        
        if currentTime == endTime {
            endTimer()
        }
        
        Logger.debug("\(title) - \(currentTime) / \(endTime)")
    }
    
    func startTimer() {
        if let timer = timer {
            timer.fire()
        } else {
            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timer.tolerance = 0.1
            RunLoop.current.add(timer, forMode: .common)
            
            self.timer = timer
        }
        
        state = .process
    }
    
    func pauseTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            
            state = .pause
        }
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            
            currentTime = 0
            state = .stop
        }
    }
    
    func endTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            
            currentTime = endTime
            state = .end
        }
    }
}

enum TimerState {
    case stop
    case process
    case pause
    case end
}
