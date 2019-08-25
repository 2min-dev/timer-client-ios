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
        /// Update time set info when view will appear. because time set info can change other view
        case viewWillAppear
        
        /// Clear time set
        case clearTimeSet
        
        /// Clear timer
        case clearTimer
        
        /// Update time input value
        case updateTime(Int)
        
        /// Add time into current selected timer
        case addTime(base: TimeInterval)
        
        /// Delete time set
        case deleteTimeSet
        
        /// Add a timer into time set
        case addTimer
        
        /// Delete a timer from time set
        case deleteTimer
        
        /// Change timer position
        case moveTimer(at: IndexPath, to: IndexPath)
        
        /// Select the timer
        case selectTimer(at: IndexPath)
        
        /// Apply alarm to all timers
        case applyAlarm(String)
    }
    
    enum Mutation {
        /// Set end time
        case setEndTime(TimeInterval)
        
        /// Set all time of time set
        case setAllTime(TimeInterval)
        
        /// Set input time
        case setTime(Int)
        
        /// Set timers of time set
        case setTimers([TimerInfo])
        
        /// Set current timer
        case setTimer(TimerInfo)
        
        /// Append a timer into time set
        case appendTimer(TimerInfo)
        
        /// Remove a timer from time set
        case removeTimer(at: Int)
        
        /// Swap the position of two timers
        case swapTimer(at: IndexPath, to: IndexPath)
        
        /// Set seected index path
        case setSelectedIndexPath(IndexPath)
        
        /// Set alert message
        case setAlertMessage(String)
        
        /// Set should section reload `true`
        case sectionReload
        
        /// Set should dismiss `true`
        case dismiss
    }
    
    struct State {
        /// The time of timer
        var endTime: TimeInterval
        
        /// All time of time set
        var allTime: TimeInterval
        
        /// The time that user inputed
        var time: Int
        
        /// The timer list model of timer set
        var timers: [TimerInfo]

        /// Current selected timer
        var timer: TimerInfo
        
        /// Current selected timer index path
        var selectedIndexPath: IndexPath
        
        /// Can the time set start
        var canTimeSetStart: Bool
        
        /// Alert message
        var alertMessage: String?
        
        /// Need section reload
        var shouldSectionReload: Bool
        
        /// Need to dismiss view
        var shouldDismiss: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    private let id: String?
    var timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, timeSetInfo: TimeSetInfo? = nil) {
        self.timeSetService = timeSetService
        
        self.id = timeSetInfo?.id
        self.timeSetInfo = timeSetInfo ?? TimeSetInfo()
        
        self.initialState = State(endTime: 0,
                                  allTime: self.timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  time: 0,
                                  timers: self.timeSetInfo.timers,
                                  timer: self.timeSetInfo.timers.first!,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  canTimeSetStart: false,
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
        default:
            return .empty()
        }
    }
    
    func transform(mutation: Observable<TimeSetEditViewReactor.Mutation>) -> Observable<TimeSetEditViewReactor.Mutation> {
        let timeSetEventMutation = timeSetService.event
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        return .merge(mutation, timeSetEventMutation)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.alertMessage = nil
        
        switch mutation {
        case let .setEndTime(time):
            state.endTime = time
            return state
            
        case let .setAllTime(timeInterval):
            state.allTime = timeInterval
            state.canTimeSetStart = state.allTime > 0
            return state
            
        case let .setTime(time):
            state.time = time
            return state
            
        case let .setTimers(timers):
            state.timers = timers
            return state
            
        case let .setTimer(timer):
            state.timer = timer
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
        let setTimers: Observable<Mutation> = .just(.setTimers(timeSetInfo.timers))
        
        var indexPath = currentState.selectedIndexPath
        if  indexPath.row + 1 > timeSetInfo.timers.count {
            // Reset index path if timer count less than current selected index path's row
            indexPath = IndexPath(row: timeSetInfo.timers.count - 1, section: 0)
        }
        let setSelectedIndexPath: Observable<Mutation> = actionSelectTimer(at: indexPath)
        
        let allTime = timeSetInfo.timers.reduce(0) { $0 + $1.endTime }
        let setAllTime: Observable<Mutation> = .just(.setAllTime(allTime))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setTimers, setSelectedIndexPath, setAllTime, sectionReload)
    }
    
    private func actionClearTimeSet() -> Observable<Mutation> {
        // Clear time set
        timeSetInfo = TimeSetInfo()
        
        let setTimers: Observable<Mutation> = .just(.setTimers(timeSetInfo.timers))
        let setSelectedIndexPath: Observable<Mutation> = actionSelectTimer(at: IndexPath(row: 0, section: 0))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setTimers, setSelectedIndexPath, setAllTime, sectionReload)
    }
    
    private func actionClearTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Clear the timer's end time
        timeSetInfo.timers[state.selectedIndexPath.row].endTime = 0
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(0))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - state.endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setAllTime, setTime, sectionReload)
    }
    
    private func actionUpdateTime(_ time: Int) -> Observable<Mutation> {
        let state = currentState
        
        if state.endTime + TimeInterval(time) > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
            // Set to max time if input value exceeded limit
            return .just(.setTime(Int(TimeSetEditViewReactor.MAX_TIME_INTERVAL - state.endTime)))
        } else {
            return .just(.setTime(time))
        }
    }
    
    private func actionAddTime(base time: TimeInterval) -> Observable<Mutation> {
        let state = currentState
        
        let allTime = state.allTime - state.endTime
        var timeInterval = state.endTime + TimeInterval(state.time) * time
        if timeInterval > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
           // Set to max time if timer exceeded limit
           timeInterval = TimeSetEditViewReactor.MAX_TIME_INTERVAL
        }
        
        // Update the timer's end time
        timeSetInfo.timers[state.selectedIndexPath.row].endTime = timeInterval
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeInterval))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(allTime + timeInterval))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setTime, setAllTime, sectionReload)
    }
    
    private func actionDeleteTimeSet() -> Observable<Mutation> {
        guard let id = id else { return .empty() }
        return timeSetService.removeTimeSet(id: id).asObservable()
            .flatMap { _ -> Observable<Mutation> in .just(.dismiss) }
    }
    
    private func actionAddTimer() -> Observable<Mutation> {
        // Create default a timer (set 0)
        let index = timeSetInfo.timers.count
        let info = TimerInfo()
        
        // Add a timer
        timeSetInfo.timers.append(info)
        
        let appendSectionItem: Observable<Mutation> = .just(.appendTimer(info))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        let setSelectIndexPath = actionSelectTimer(at: IndexPath(row: index, section: 0))
        
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
        // Set index path
        let indexPath = IndexPath(row: index < timeSetInfo.timers.count ? index : index - 1, section: 0)
        let setSelectIndexPath = actionSelectTimer(at: indexPath)
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - timer.endTime))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(removeTimer, setSelectIndexPath, setAllTime, sectionReload)
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
        guard indexPath.row < timeSetInfo.timers.count else { return .empty() }
        
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(indexPath))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[indexPath.row]))
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeSetInfo.timers[indexPath.row].endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        
        return .concat(setSelectedIndexPath, setTimer, setEndTime, setTime)
    }
    
    private func actionApplyAlarm(_ alarm: String) -> Observable<Mutation> {
        timeSetInfo.timers.forEach { $0.alarm = alarm }
        return .just(.setAlertMessage("alert_alarm_all_apply_description".localized))
    }
    
    private func actionTimeSetCreate() -> Observable<Mutation> {       guard id == nil else { return .empty() }
        // If current time set info doesn't asigned id(It is createing new), clear time set info due to save the time set
        return actionClearTimeSet()
    }
    
    deinit {
        Logger.verbose()
    }
}
