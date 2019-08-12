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
    static let MAX_TIME_INTERVAL = TimeInterval(99 * Constants.Time.hour + 59 * Constants.Time.minute + 59)
    
    enum Action {
        case viewWillAppear
        
        case clearTimeSet                   // Clear data action
        case clearTimer
        
        case updateTime(Int)                // Time input action
        case addTime(base: Int)
        
        case deleteTimeSet                  // Time set operation action
        
        case addTimer                       // Timer operation action
        case deleteTimer
        case moveTimer(at: IndexPath, to: IndexPath)
        case selectTimer(at: IndexPath)
        
        case applyAlarm(String)
    }
    
    enum Mutation {
        case setTimer(TimeInterval)
        case setSumOfTimers(TimeInterval)
        case setTime(Int)
        
        case setTimers([TimerInfo])
        case appendTimer(TimerInfo)
        case removeTimer(at: Int)
        case swapTimer(at: IndexPath, to: IndexPath)
        
        case setSelectedIndexPath(IndexPath)
        
        case setAlertMessage(String)
        case sectionReload
        
        case dismiss
    }
    
    struct State {
        var timer: TimeInterval             // The time of timer
        var sumOfTimers: TimeInterval       // The time that sum of all timers
        var time: Int                       // The time that user inputed
        
        var timers: [TimerInfo]             // The timer list model of timer set
        
        var selectedIndexPath: IndexPath    // Current selected timer index path
        
        var canTimeSetStart: Bool           // Can the time set start
        
        var alertMessage: String?           // Alert message
        var shouldSectionReload: Bool       // Need section reload
        
        var shouldDismiss: Bool             // Need to dismiss view
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    var timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, timeSetInfo: TimeSetInfo? = nil) {
        self.timeSetService = timeSetService
        self.timeSetInfo = timeSetInfo ?? TimeSetInfo()
        
        self.initialState = State(timer: 0,
                                  sumOfTimers: self.timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  time: 0,
                                  timers: self.timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  canTimeSetStart: true,
                                  alertMessage: nil,
                                  shouldSectionReload: true,
                                  shouldDismiss: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
        case .clearTimeSet:
            return actionClearTimeSet()
        case .clearTimer:
            return actionClearTimer()
        case let .updateTime(time):
            return actionUpdateTime(time)
        case let .addTime(base: time):
            return actionAddTime(base: time)
        case .deleteTimeSet:
            return actionDeleteTimeSet()
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
    
    private func mutate(timeSetEvent: TimeSetEvent) -> Observable<Mutation> {
        switch timeSetEvent {
        case .create:
            return actionTimeSetCreate()
        }
    }
    
    func transform(mutation: Observable<TimeSetEditViewReactor.Mutation>) -> Observable<TimeSetEditViewReactor.Mutation> {
        let timeSetEventMutation = timeSetService.event
            .filter { $0 == .create }
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        return .merge(mutation, timeSetEventMutation)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.alertMessage = nil
        
        switch mutation {
        case let .setTimer(timeInterval):
            state.timer = timeInterval
            return state
        case let .setSumOfTimers(timeInterval):
            state.sumOfTimers = timeInterval
            state.canTimeSetStart = state.sumOfTimers > 0
            return state
        case let .setTime(time):
            state.time = time
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
        case let .setAlertMessage(message):
            state.alertMessage = message
            return state
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        case .dismiss:
            state.shouldDismiss = true
            return state
        }
    }

    // MARK: - action method
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
        
        let setTimers: Observable<Mutation> = .just(.setTimers(timeSetInfo.timers))
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(IndexPath(row: 0, section: 0)))
        let setTimer: Observable<Mutation> = .just(.setTimer(0))
        let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(0))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setTimers, setSelectedIndexPath, setTimer, setSumOfTimers, setTime, sectionReload)
    }
    
    private func actionClearTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Clear the timer's end time
        timeSetInfo.timers[state.selectedIndexPath.row].endTime = 0
        
        let setTimer: Observable<Mutation> = .just(.setTimer(0))
        let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(state.sumOfTimers - state.timer))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setTimer, setTime, setSumOfTimers, sectionReload)
    }
    
    private func actionUpdateTime(_ time: Int) -> Observable<Mutation> {
        let state = currentState
        
        guard state.timer + TimeInterval(time) <= TimeSetEditViewReactor.MAX_TIME_INTERVAL else {
            // Set to max time if input value exceeded limit
            return .just(.setTime(Int(TimeSetEditViewReactor.MAX_TIME_INTERVAL - state.timer)))
        }
        return .just(.setTime(time))
    }
    
    private func actionAddTime(base time: Int) -> Observable<Mutation> {
        let state = currentState
        
        let sumOfTimers = state.sumOfTimers - state.timer
        var timeInterval = state.timer + TimeInterval(state.time * time)
        if timeInterval > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
           // Set to max time if timer exceeded limit
           timeInterval = TimeSetEditViewReactor.MAX_TIME_INTERVAL
        }
        
        // Update the timer's end time
        timeSetInfo.timers[state.selectedIndexPath.row].endTime = timeInterval
        
        let setTimer: Observable<Mutation> = .just(.setTimer(timeInterval))
        let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(sumOfTimers + timeInterval))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setTimer, setSumOfTimers, setTime, sectionReload)
    }
    
    private func actionDeleteTimeSet() -> Observable<Mutation> {
        guard let id = timeSetInfo.id else { return .empty() }
        return timeSetService.removeTimeSet(id: id)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in .just(.dismiss) }
    }
    
    private func actionAddTimer() -> Observable<Mutation> {
        // Create default a timer (set 0)
        let index = timeSetInfo.timers.count
        let info = TimerInfo(title: String(format: "timer_default_title".localized, index + 1))
        // Add a timer
        timeSetInfo.timers.append(info)
        
        let appendSectionItem: Observable<Mutation> = .just(.appendTimer(info))
        let setSelectIndexPath = actionSelectTimer(at: IndexPath(row: index, section: 0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(appendSectionItem, sectionReload, setSelectIndexPath)
    }
    
    private func actionDeleteTimer() -> Observable<Mutation> {
        let state = currentState
        
        let index = state.selectedIndexPath.row
        guard index > 0 else {
            // Ignore delete first timer action
            return .empty()
        }
        // Remove a timer
        let timer = timeSetInfo.timers.remove(at: index)
        
        let removeTimer: Observable<Mutation> = .just(.removeTimer(at: index))
        let setSumOfTimers: Observable<Mutation> = .just(.setSumOfTimers(state.sumOfTimers - timer.endTime))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        var indexPath = IndexPath(row: index, section: 0)
        if index >= timeSetInfo.timers.count {
            indexPath = IndexPath(row: index - 1, section: 0)
        }

        let setSelectIndexPath = actionSelectTimer(at: indexPath)
        return .concat(setSelectIndexPath, removeTimer, setSumOfTimers, sectionReload)
    }
    
    private func actionMoveTimer(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Observable<Mutation> {
        let state = currentState
        
        // Swap timer
        timeSetInfo.timers.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        
        let swapTimer: Observable<Mutation> = .just(.swapTimer(at: sourceIndexPath, to: destinationIndexPath))
        // Update selected index path
        var setSelectedIndexPath: Observable<Mutation> = .empty()
        if state.selectedIndexPath == sourceIndexPath {
            setSelectedIndexPath = .just(.setSelectedIndexPath(destinationIndexPath))
        } else if state.selectedIndexPath == destinationIndexPath {
            setSelectedIndexPath = .just(.setSelectedIndexPath(sourceIndexPath))
        }
        
        return .concat(swapTimer, setSelectedIndexPath)
    }
    
    private func actionSelectTimer(at indexPath: IndexPath) -> Observable<Mutation> {
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(indexPath))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[indexPath.row].endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        
        return .concat(setSelectedIndexPath, setTimer, setTime)
    }
    
    private func actionApplyAlarm(_ alarm: String) -> Observable<Mutation> {
        timeSetInfo.timers.forEach { $0.alarm = alarm }
        return .just(.setAlertMessage("alert_alarm_all_apply_description".localized))
    }
    
    private func actionTimeSetCreate() -> Observable<Mutation> {
        guard timeSetInfo.id == nil else { return .empty() }
        // If current time set info doesn't asigned id(It is createing new), clear time set info due to save the time set
        return actionClearTimeSet()
    }
}
