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
    // MARK: - constants
    private static let MAX_TIME_INTERVAL = TimeInterval(99 * Constants.Time.hour + 59 * Constants.Time.minute + 59)
    
    enum Time: Int {
        case hour = 0
        case minute
        case second
    }
    
    enum Action {
        case clearTimeSet
        case clearTimer
        
        case tapKeyPad(Int)
        case tapTime(Time)
        
        case addTimer
        case deleteTimer
        case moveTimer(at: IndexPath, to: IndexPath)
        case selectTimer(at: IndexPath)
        
        case applyAlarm(String)
    }
    
    enum Mutation {
        case setTime(Int)
        case setTimer(TimeInterval)
        case setSumOfTimers(TimeInterval)
        
        case setTimers([TimerInfo])
        case appendTimer(TimerInfo)
        case removeTimer(at: Int)
        case swapTimer(at: IndexPath, to: IndexPath)
        
        case setSelectedIndexPath(IndexPath)
        
        case setSelectableTime(Time)
        
        case setAlertMessage(String)
        case sectionReload
    }
    
    struct State {
        var time: Int                       // The time that user inputed
        var timer: TimeInterval             // The time of timer
        var sumOfTimers: TimeInterval       // The time that sum of all timers
        
        var timers: [TimerInfo]             // The timer list model of timer set
        
        var selectedIndexPath: IndexPath    // Current selected timer index path
        
        var selectableTime: Time            // Selectable time key based on current time
        var canTimeSetStart: Bool           // Can the time set start
        
        var alertMessage: String?           // Alert message
        var shouldSectionReload: Bool       // Need section reload
    }
    
    // MARK: - properties
    var initialState: State
    private let timerService: TimeSetServicePorotocol
    
    var timeSetInfo: TimeSetInfo // Empty timer set info
    
    // MARK: - constructor
    init(timerService: TimeSetServicePorotocol) {
        self.timerService = timerService
        
        // Create default timer set and add default a timer
        self.timeSetInfo = TimeSetInfo()
        self.timeSetInfo.timers.append(TimerInfo(title: "1 번째 타이머"))
 
        self.initialState = State(time: 0,
                                  timer: 0,
                                  sumOfTimers: 0,
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  selectableTime: .hour,
                                  canTimeSetStart: false,
                                  alertMessage: nil,
                                  shouldSectionReload: true)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .clearTimeSet:
            // Clear time set
            timeSetInfo = TimeSetInfo()
            timeSetInfo.timers.append(TimerInfo(title: "1 번째 타이머"))
            
            let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(IndexPath(row: 0, section: 0)))
            let setTimers: Observable<Mutation> = .just(.setTimers(timeSetInfo.timers))
            let setTimer: Observable<Mutation> = .just(.setTimer(0))
            let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(0))
            let setTime: Observable<Mutation> = .just(.setTime(0))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            return .concat(setSelectedIndexPath, setTimers, setTimer, setSumOfTimers, setTime, sectionReload)
        case .clearTimer:
            // Clear the timer's end time
            timeSetInfo.timers[currentState.selectedIndexPath.row].endTime = 0
            
            let setTimer: Observable<Mutation> = .just(.setTimer(0))
            let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(currentState.sumOfTimers - currentState.timer))
            let setTime: Observable<Mutation> = .just(.setTime(0))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            return .concat(setTimer, setTime, setSumOfTimers, sectionReload)
        case let .tapKeyPad(time):
            return .just(.setTime(time))
        case let .tapTime(key):
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
            
            // Update the timer's end time
            timeSetInfo.timers[currentState.selectedIndexPath.row].endTime = timeInterval
            
            let setTimer: Observable<Mutation> = .just(.setTimer(timeInterval))
            let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(sumOfTimers + timeInterval))
            let setTime: Observable<Mutation> = .just(.setTime(0))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            return .concat(setTimer, setSumOfTimers, setTime, sectionReload)
        case .addTimer:
            // Create default a timer (set 0)
            let index = timeSetInfo.timers.count
            let info = TimerInfo(title: "\(index + 1) 번째 타이머")
            // Add timer
            timeSetInfo.timers.append(info)
            
            let appendSectionItem: Observable<Mutation> = .just(.appendTimer(info))
            let setSelectIndexPath = mutate(action: .selectTimer(at: IndexPath(row: index, section: 0)))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            return .concat(appendSectionItem, sectionReload, setSelectIndexPath)
        case .deleteTimer:
            let index = currentState.selectedIndexPath.row
            guard index > 0 else { return .empty() }

            timeSetInfo.timers.remove(at: index)
            
            let removeTimer: Observable<Mutation> = .just(.removeTimer(at: index))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            guard index < timeSetInfo.timers.count else {
                // Last timer deleted
                let setSelectIndexPath: Observable<Mutation> = mutate(action: .selectTimer(at: IndexPath(row: index - 1, section: 0)))
                return .concat(setSelectIndexPath, removeTimer, sectionReload)
            }
            
            let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[index].endTime))
            let setTime: Observable<Mutation> = .just(.setTime(0))
            
            return .concat(setTimer, setTime, removeTimer, sectionReload)
        case let .moveTimer(at: sourceIndexPath, to: destinationIndexPath):
            // Swap timer
            timeSetInfo.timers.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            
            let swapTimer: Observable<Mutation> = .just(.swapTimer(at: sourceIndexPath, to: destinationIndexPath))
            // Update selected index path
            var setSelectedIndexPath: Observable<Mutation>
            if currentState.selectedIndexPath == sourceIndexPath {
                setSelectedIndexPath = .just(.setSelectedIndexPath(destinationIndexPath))
            } else if currentState.selectedIndexPath == destinationIndexPath {
                setSelectedIndexPath = .just(.setSelectedIndexPath(sourceIndexPath))
            } else {
                setSelectedIndexPath = .empty()
            }
            
            return .concat(swapTimer, setSelectedIndexPath)
        case let .selectTimer(indexPath):
            guard currentState.selectedIndexPath != indexPath else { return .empty() }
            
            let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(indexPath))
            let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[indexPath.row].endTime))
            let setTime: Observable<Mutation> = .just(.setTime(0))
            
            return .concat(setSelectedIndexPath, setTimer, setTime)
        case let .applyAlarm(alarm):
            timeSetInfo.timers.forEach { $0.alarm = alarm }
            return .just(.setAlertMessage("알람이 전체 적용 되었습니다."))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.alertMessage = nil
        
        switch mutation {
        case let .setTime(time):
            if TimeInterval(time) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                state.time = Int(ProductivityViewReactor.MAX_TIME_INTERVAL - state.timer)
            } else {
                state.time = time
            }
            
            if state.timer + TimeInterval(time * Constants.Time.minute) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                state.selectableTime = .second
            } else if state.timer + TimeInterval(time * Constants.Time.hour) > ProductivityViewReactor.MAX_TIME_INTERVAL {
                state.selectableTime = .minute
            } else {
                state.selectableTime = .hour
            }
            
            return state
        case let .setTimer(timeInterval):
            state.timer = timeInterval
            state.canTimeSetStart = state.timers.count > 1 || state.timer > 0
            return state
        case let .setSumOfTimers(timeInterval):
            state.sumOfTimers = timeInterval
            return state
        case let .setTimers(timers):
            state.timers = timers
            return state
        case let .appendTimer(info):
            state.timers.append(info)
            return state
        case let .removeTimer(at: index):
            state.timers.remove(at: index)
            return state
        case let .swapTimer(at: sourceIndexPath, to: destinationIndexPth):
            state.timers.swapAt(sourceIndexPath.row, destinationIndexPth.row)
            return state
        case let .setSelectedIndexPath(indexPath):
            state.selectedIndexPath = indexPath
            return state
        case let .setSelectableTime(time):
            state.selectableTime = time
            return state
        case let .setAlertMessage(message):
            state.alertMessage = message
            return state
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
}
