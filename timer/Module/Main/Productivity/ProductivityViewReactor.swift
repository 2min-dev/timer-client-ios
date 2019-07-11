//
//  ProductivityViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit
import RxDataSources

class ProductivityViewReactor: Reactor {
    enum Action {
        case updateTime(Int)
        case tapTimeKey(ProductivityView.TimeKey)
        case clearTimer
        case addTimer
        case timerSelected(IndexPath)
    }
    
    enum Mutation {
        case setTime(Int)
        case setTimer(TimeInterval)
        case setSumOfTimers(TimeInterval)
        
        case appendTimer(TimerInfo)
        case setSelectedIndexPath(IndexPath)
    }
    
    struct State {
        var time: Int // The time that user inputed
        var timer: TimeInterval // The time of timer
        var sumOfTimers: TimeInterval // The time that sum of all timers
        
        var timers: [TimerInfo]
        var selectedIndexPath: IndexPath
        
        var canStart: Bool
        var shouldReloadSection: Bool
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimeSetServicePorotocol
    
    let timeSetInfo: TimeSetInfo // Default timer set info
    
    init(timerService: TimeSetServicePorotocol) {
        self.timerService = timerService
        
        // Create default a timer
        let info = TimerInfo(title: "1 번째 타이머")
        
        // Create default timer set and add default a timer
        self.timeSetInfo = TimeSetInfo(name: "", description: "")
        self.timeSetInfo.timers.append(info)
 
        self.initialState = State(time: 0,
                                  timer: 0,
                                  sumOfTimers: 0,
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  canStart: false,
                                  shouldReloadSection: true)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTime(time):
            return .just(Mutation.setTime(time))
        case let .tapTimeKey(key):
            var timeInterval = currentState.timer
            let sumOfTimers = currentState.sumOfTimers - timeInterval
            
            switch key {
            case .hour:
                timeInterval += Double(currentState.time * Constants.Time.hour)
            case .minute:
                timeInterval += Double(currentState.time * Constants.Time.minute)
            case .second:
                timeInterval += Double(currentState.time)
            }
            
            let setTimer = Observable.just(Mutation.setTimer(timeInterval))
            let setSumOfTimers = Observable.just(Mutation.setSumOfTimers(sumOfTimers + timeInterval))
            let setTime = Observable.just(Mutation.setTime(0))
            
            return .concat(setTimer, setSumOfTimers, setTime)
        case .clearTimer:
            let setTimer = Observable.just(Mutation.setTimer(0))
            let setSumOfTimers = Observable.just(Mutation.setSumOfTimers(currentState.sumOfTimers - currentState.timer))
            let setTime = Observable.just(Mutation.setTime(0))
            
            return .concat(setTimer, setTime, setSumOfTimers)
        case .addTimer:
            // Create default a timer (set 0)
            let index = timeSetInfo.timers.count + 1
            let info = TimerInfo(title: "\(index) 번째 타이머")
            // Add timer
            timeSetInfo.timers.append(info)
            
            let appendSectionItem = Observable.just(Mutation.appendTimer(info))
            let setSelectIndexPath = mutate(action: .timerSelected(IndexPath(row: index - 1, section: 0)))
            
            return .concat(appendSectionItem, setSelectIndexPath)
        case let .timerSelected(indexPath):
            let setSelectedIndexPath = Observable.just(Mutation.setSelectedIndexPath(indexPath))
            let setTimer = Observable.just(Mutation.setTimer(timeSetInfo.timers[indexPath.row].endTime))
            let setTime = Observable.just(Mutation.setTime(0))
            
            return .concat(setSelectedIndexPath, setTimer, setTime)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldReloadSection = false
        
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
        case let .setTimer(timeInterval):
            // Update time
            state.timers[state.selectedIndexPath.row].endTime = timeInterval
            state.timer = timeInterval
            
            state.canStart = state.timers.count > 1 || state.timer > 0
            return state
        case let .setSumOfTimers(timeInterval):
            state.sumOfTimers = timeInterval
            return state
        case let .appendTimer(info):
            state.timers.append(info)
            
            state.canStart = true
            state.shouldReloadSection = true
            return state
        case let .setSelectedIndexPath(indexPath):
            state.selectedIndexPath = indexPath
            return state
        }
    }
}
