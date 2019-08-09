//
//  TimeSetEditViewReactor.swift
//  timer
//
//  Created by JSilver on 09/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetEditViewReactor: Reactor {
    // MARK: - constants
    private static let MAX_TIME_INTERVAL = TimeInterval(99 * Constants.Time.hour + 59 * Constants.Time.minute + 59)
    
    enum Time: Int {
        case hour = 0
        case minute
        case second
    }
    
    enum Action {
        case viewWillAppear
        
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
        var canTimeSetSave: Bool            // Can the time set save
        
        var alertMessage: String?           // Alert message
        var shouldSectionReload: Bool       // Need section reload
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        self.timeSetInfo = timeSetInfo
        
        self.initialState = State(time: 0,
                                  timer: 0,
                                  sumOfTimers: timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  selectableTime: .hour,
                                  canTimeSetSave: false,
                                  alertMessage: nil,
                                  shouldSectionReload: true)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
        case .clearTimeSet:
            return actionClearTimeSet()
        case .clearTimer:
            return actionClearTimer()
        case let .tapKeyPad(time):
            return actionTapKeyPad(time)
        case let .tapTime(key):
            return actionTapTime(key: key)
        case .addTimer:
            return actionAddTimer()
        case .deleteTimer:
            return actionDeleteTimer()
        case let .moveTimer(at: sourceIndexPath, to: destinationIndexPath):
            return actionMoveTimer(at: sourceIndexPath, to: destinationIndexPath)
        case let .selectTimer(indexPath):
            return actionSelectTimer(at: indexPath)
        case let .applyAlarm(alarm):
            return actionApplyAlarm(alarm)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.alertMessage = nil
        
        switch mutation {
        case let .setTime(time):
            if TimeInterval(time) > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
                state.time = Int(TimeSetEditViewReactor.MAX_TIME_INTERVAL - state.timer)
            } else {
                state.time = time
            }
            
            if state.timer + TimeInterval(time * Constants.Time.minute) > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
                state.selectableTime = .second
            } else if state.timer + TimeInterval(time * Constants.Time.hour) > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
                state.selectableTime = .minute
            } else {
                state.selectableTime = .hour
            }
            
            return state
        case let .setTimer(timeInterval):
            state.timer = timeInterval
            state.canTimeSetSave = state.timers.count > 1 || state.timer > 0
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
    
    // MARK: - private method
    private func actionViewWillAppear() -> Observable<Mutation> {
        var indexPath = currentState.selectedIndexPath
        if  indexPath.row > timeSetInfo.timers.count - 1 {
            // Reset index path if timer count less than current selected index path's row
            indexPath = IndexPath(row: timeSetInfo.timers.count - 1, section: 0)
        }
        
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(indexPath))
        let setTimers: Observable<Mutation> = .just(.setTimers(timeSetInfo.timers))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[indexPath.row].endTime))
        let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(timeSetInfo.timers.reduce(0) { $0 + $1.endTime }))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSelectedIndexPath, setTimers, setTimer, setSumOfTimers, setTime, sectionReload)
    }
    
    private func actionClearTimeSet() -> Observable<Mutation> {
        // Clear time set
        timeSetInfo = TimeSetInfo()
        
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(IndexPath(row: 0, section: 0)))
        let setTimers: Observable<Mutation> = .just(.setTimers(timeSetInfo.timers))
        let setTimer: Observable<Mutation> = .just(.setTimer(0))
        let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(0))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSelectedIndexPath, setTimers, setTimer, setSumOfTimers, setTime, sectionReload)
    }
    
    private func actionClearTimer() -> Observable<Mutation> {
        // Clear the timer's end time
        timeSetInfo.timers[currentState.selectedIndexPath.row].endTime = 0
        
        let setTimer: Observable<Mutation> = .just(.setTimer(0))
        let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(currentState.sumOfTimers - currentState.timer))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setTimer, setTime, setSumOfTimers, sectionReload)
    }
    
    private func actionTapKeyPad(_ time: Int) -> Observable<Mutation> {
        return .just(.setTime(time))
    }
    
    private func actionTapTime(key: Time) -> Observable<Mutation> {
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
    }
    
    private func actionAddTimer() -> Observable<Mutation> {
        // Create default a timer (set 0)
        let index = timeSetInfo.timers.count
        let info = TimerInfo(title: String(format: "timer_default_title".localized, index + 1))
        // Add timer
        timeSetInfo.timers.append(info)
        
        let appendSectionItem: Observable<Mutation> = .just(.appendTimer(info))
        let setSelectIndexPath = mutate(action: .selectTimer(at: IndexPath(row: index, section: 0)))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(appendSectionItem, sectionReload, setSelectIndexPath)
    }
    
    private func actionDeleteTimer() -> Observable<Mutation> {
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
    }
    
    private func actionMoveTimer(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Observable<Mutation> {
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
    }
    
    private func actionSelectTimer(at indexPath: IndexPath) -> Observable<Mutation> {
        guard currentState.selectedIndexPath != indexPath else { return .empty() }
        
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(indexPath))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[indexPath.row].endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        
        return .concat(setSelectedIndexPath, setTimer, setTime)
    }
    
    private func actionApplyAlarm(_ alarm: String) -> Observable<Mutation> {
        timeSetInfo.timers.forEach { $0.alarm = alarm }
        return .just(.setAlertMessage("alert_alarm_all_apply_description".localized))
    }
}
