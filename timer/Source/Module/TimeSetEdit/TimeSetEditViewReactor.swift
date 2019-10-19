//
//  TimeSetEditViewReactor.swift
//  timer
//
//  Created by JSilver on 09/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RealmSwift

class TimeSetEditViewReactor: Reactor {
    // MARK: - constants
    static let MAX_TIME_INTERVAL = TimeInterval(99 * Constants.Time.hour + 59 * Constants.Time.minute + 59)
    static let MAX_TIMER_COUNT: Int = 10
    
    enum Action {
        /// Clear time set info
        case clearTimeSet
        
        /// Clear all created timers
        case clearTimers
        
        /// Clear timer
        case clearTimer
        
        /// Update time input value
        case updateTime(Int)
        
        /// Add time into current selected timer
        case addTime(base: TimeInterval)
        
        /// Toggle the state of time set repeat
        case toggleRepeat
        
        /// Add a timer into time set
        case addTimer
        
        /// Delete a timer from time set
        case deleteTimer
        
        /// Change timer position
        case moveTimer(at: Int, to: Int)
        
        /// Select the timer
        case selectTimer(at: Int)
        
        /// Delete time set
        case deleteTimeSet
        
        /// vaildate time set data
        case validate
    }
    
    enum Mutation {
        /// Set end time
        case setEndTime(TimeInterval)
        
        /// Set all time of time set
        case setAllTime(TimeInterval)
        
        /// Set input time
        case setTime(Int)
        
        /// Set selected index
        case setSelectedIndex(Int)
        
        /// Set should section reload `true`
        case sectionReload
        
        /// Set should dismiss `true`
        case dismiss
        
        /// Set is validated `true`
        case validated
    }
    
    struct State {
        /// The time of timer
        var endTime: TimeInterval
        
        /// All time of time set
        var allTime: TimeInterval
        
        /// The time that user inputed
        var time: Int
        
        /// Section datasource to make sections
        let sectionDataSource: TimerBadgeDataSource
        
        /// The timer list badge sections
        var sections: [TimerBadgeSectionModel] {
            sectionDataSource.makeSections { reactors, type -> Bool in
                switch type {
                case .add:
                    return reactors.count < TimeSetEditViewReactor.MAX_TIMER_COUNT && endTime > 0
                    
                case .repeat:
                    return true
                }
            }
        }
        
        /// Current selected timer index path
        var selectedIndex: Int
        
        /// Need section reload
        var shouldSectionReload: Bool
        
        /// Need to dismiss view
        var shouldDismiss: Bool
        
        /// The time set data is vaildated
        var isValidated: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    private let timeSetService: TimeSetServiceProtocol
    
    var timeSetInfo: TimeSetInfo
    
    // Sub reactor
    let timerOptionViewReactor: TimerOptionViewReactor
    
    // MARK: - constructor
    init(appService: AppServiceProtocol, timeSetService: TimeSetServiceProtocol, timeSetInfo: TimeSetInfo? = nil) {
        self.appService = appService
        self.timeSetService = timeSetService
        
        if let timeSetInfo = timeSetInfo {
            self.timeSetInfo = timeSetInfo
        } else {
            // Create new time set info
            let timeSetInfo = TimeSetInfo(id: nil)
            timeSetInfo.timers.append(TimerInfo(alarm: appService.getAlarm()))
            
            self.timeSetInfo = timeSetInfo
        }
        
        // Create sub reactor
        timerOptionViewReactor = TimerOptionViewReactor()
        
        let timers = self.timeSetInfo.timers.toArray()
        let timer = timers.first
        
        // Create section datasource
        let dataSource = TimerBadgeDataSource(
            timers: self.timeSetInfo.timers.toArray(),
            extras: [
                .add: .add,
                .repeat: .repeat(TimerBadgeRepeatCellReactor(isRepeat: self.timeSetInfo.isRepeat))
            ],
            leftExtras: [.repeat],
            rightExtras: [.add],
            index: 0
        )
        
        initialState = State(endTime: timer?.endTime ?? 0,
                             allTime: self.timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                             time: 0,
                             sectionDataSource: dataSource,
                             selectedIndex: 0,
                             shouldSectionReload: true,
                             shouldDismiss: false,
                             isValidated: false)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .clearTimeSet:
            return actionClearTimeSet()
            
        case .clearTimers:
            return actionClearTimers()
            
        case .clearTimer:
            return actionClearTimer()
            
        case let .updateTime(time):
            return actionUpdateTime(time)
            
        case let .addTime(base: time):
            return actionAddTime(base: time)
            
        case .toggleRepeat:
            return actionToggleRepeat()
            
        case .addTimer:
            return actionAddTimer()
            
        case .deleteTimer:
            return actionDeleteTimer()
            
        case let .moveTimer(at: sourceIndex, to: destinationIndex):
            return actionMoveTimer(at: sourceIndex, to: destinationIndex)
            
        case let .selectTimer(index):
            return actionSelectTimer(at: index)
            
        case .deleteTimeSet:
            return actionDeleteTimeSet()
            
        case .validate:
            return actionValidateTimeSet()
        }
    }
    
    private func mutate(timeSetEvent: TimeSetEvent) -> Observable<Mutation> {
        switch timeSetEvent {
        case .created:
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
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.isValidated = false
        
        switch mutation {
        case let .setEndTime(time):
            state.endTime = time
            return state
            
        case let .setAllTime(timeInterval):
            state.allTime = timeInterval
            return state
            
        case let .setTime(time):
            state.time = time
            return state
            
        case let .setSelectedIndex(index):
            let section: Int = TimerBadgeSectionType.regular.rawValue
            guard index >= 0 && index < state.sections[section].items.count else { return state }
            
            state.selectedIndex = index
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
            
        case .dismiss:
            state.shouldDismiss = true
            return state
            
        case .validated:
            state.isValidated = true
            return state
        }
    }

    // MARK: - action method
    private func actionClearTimeSet() -> Observable<Mutation> {
        let state = currentState
        
        // Clear time set
        timeSetInfo = TimeSetInfo(id: nil)
        timeSetInfo.timers.append(TimerInfo(alarm: appService.getAlarm()))
        
        // Clear timer items
        state.sectionDataSource.clear()
        
        // Clear time set repeat item
        if case let .repeat(reactor) = state.sectionDataSource.extras[.repeat] {
            reactor.action.onNext(.updateRepeat(false))
        }
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(0))
        let setSelectedIndex: Observable<Mutation> = actionSelectTimer(at: 0)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setAllTime, setSelectedIndex, sectionReload)
    }
    
    private func actionClearTimers() -> Observable<Mutation> {
        // Clear default timers
        let timers = List<TimerInfo>()
        timers.append(TimerInfo(alarm: appService.getAlarm()))
        timeSetInfo.timers = timers
        
        // Clear timer items
        currentState.sectionDataSource.clear()
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(0))
        let setSelectedIndex: Observable<Mutation> = actionSelectTimer(at: 0)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setAllTime, setSelectedIndex, sectionReload)
    }
    
    private func actionClearTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Clear the timer's end time
        timeSetInfo.timers[state.selectedIndex].endTime = 0
        
        // Update badge time
        state.sectionDataSource.regulars[state.selectedIndex].action.onNext(.updateTime(0))
        
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
        
        var timeInterval = state.endTime + TimeInterval(state.time) * time
        if timeInterval > TimeSetEditViewReactor.MAX_TIME_INTERVAL {
           // Set to max time if timer exceeded limit
           timeInterval = TimeSetEditViewReactor.MAX_TIME_INTERVAL
        }
        
        // Update the timer's end time
        timeSetInfo.timers[state.selectedIndex].endTime = timeInterval
        
        // Update badge time
        state.sectionDataSource.regulars[state.selectedIndex].action.onNext(.updateTime(timeInterval))
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeInterval))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - state.endTime + timeInterval))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setAllTime, setTime, sectionReload)
    }
    
    private func actionToggleRepeat() -> Observable<Mutation> {
        // Toggle time set repeat
        timeSetInfo.isRepeat.toggle()
        
        if case let .repeat(reactor) = currentState.sectionDataSource.extras[.repeat] {
            reactor.action.onNext(.updateRepeat(timeSetInfo.isRepeat))
        }
        
        return .empty()
    }
    
    private func actionAddTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Create timer and append into time set info
        let info = TimerInfo(alarm: appService.getAlarm())
        timeSetInfo.timers.append(info)
        
        // Create timer item and append into regular items
        state.sectionDataSource.append(item: info)
        
        let setSelectIndex = actionSelectTimer(at: state.sectionDataSource.regulars.count - 1)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(sectionReload, setSelectIndex)
    }
    
    private func actionDeleteTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Get will remove timer
        let index = state.selectedIndex
        let removedTimer = timeSetInfo.timers[index]
        
        // Remove a timer
        timeSetInfo.timers.remove(at: index)
        
        // Remove a timer item
        state.sectionDataSource.remove(at: index)
        
        // Calculate selected index
        // If selected index is last index, adjust index to last index of removed list
        let selectIndex = index < timeSetInfo.timers.count ? index : index - 1
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - removedTimer.endTime))
        let setSelectIndex = actionSelectTimer(at: selectIndex)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setAllTime, setSelectIndex, sectionReload)
    }
    
    private func actionMoveTimer(at sourceIndex: Int, to destinationIndex: Int) -> Observable<Mutation> {
        let state = currentState
        
        // Swap timer
        timeSetInfo.timers.swapAt(sourceIndex, destinationIndex)
        
        // Swap timer item & update index
        state.sectionDataSource.swap(at: sourceIndex, to: destinationIndex)
        
        state.sectionDataSource.regulars[sourceIndex].action.onNext(.updateIndex(sourceIndex))
        state.sectionDataSource.regulars[destinationIndex].action.onNext(.updateIndex(destinationIndex))
        
        // Update selected index
        var setSelectedIndex: Observable<Mutation>
        if state.selectedIndex == sourceIndex {
            setSelectedIndex = .just(.setSelectedIndex(destinationIndex))
        } else if state.selectedIndex == destinationIndex {
            setSelectedIndex = .just(.setSelectedIndex(sourceIndex))
        } else {
            // Moved timer is not selected timer
            setSelectedIndex = .empty()
        }
        
        return setSelectedIndex
    }
    
    private func actionSelectTimer(at index: Int) -> Observable<Mutation> {
        guard index >= 0 && index < timeSetInfo.timers.count else { return .empty() }
        
        let state = currentState
        let previousIndex = state.selectedIndex
        
        var index = index
        if index != previousIndex && previousIndex < timeSetInfo.timers.count {
            // Update to previous item state
            if timeSetInfo.timers[previousIndex].endTime == 0 {
                // If current selected timer's end time is 0
                // Remove previous selected timer
                timeSetInfo.timers.remove(at: previousIndex)
                state.sectionDataSource.remove(at: previousIndex)
                
                // Adjust index
                index = index > previousIndex ? index - 1 : index
            } else {
                // Deselect previous item
                state.sectionDataSource.regulars[previousIndex].action.onNext(.select(false))
            }
        }
        
        // Select current item
        state.sectionDataSource.regulars[index].action.onNext(.select(true))
        
        // Update timer of timer option reactor
        let timer = timeSetInfo.timers[index]
        timerOptionViewReactor.action.onNext(.updateTimer(timer, at: index))
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeSetInfo.timers[index].endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(index))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setTime, sectionReload, setSelectedIndex)
    }
    
    private func actionDeleteTimeSet() -> Observable<Mutation> {
        guard let id = timeSetInfo.id else { return .empty() }
        return timeSetService.removeTimeSet(id: id).asObservable()
            .flatMap { _ -> Observable<Mutation> in .just(.dismiss) }
    }
    
    private func actionValidateTimeSet() -> Observable<Mutation> {
        let index = currentState.selectedIndex
        guard index >= 0 && index < timeSetInfo.timers.count else { return .empty() }
        
        // Create validate mutation concatenate process
        let validated: Observable<Mutation> = .concat(.just(.validated), .just(.sectionReload))
        
        let timer = timeSetInfo.timers[index]
        // Guard timer has time over zero
        if timer.endTime > 0 {
            return validated
        }
        
        let selectIndex = index > 0 ? index - 1 : index + 1
        let selectTimer: Observable<Mutation> = actionSelectTimer(at: selectIndex)
        
        return .concat(selectTimer, validated)
    }
    
    /// If current time set info doesn't asigned id(It is createing new), clear time set info due to save the time set
    private func actionTimeSetCreate() -> Observable<Mutation> {
        return actionClearTimeSet()
    }
    
    deinit {
        Logger.verbose()
    }
}
