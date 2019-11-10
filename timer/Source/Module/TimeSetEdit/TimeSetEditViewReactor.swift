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
        
        /// Apply alarm to all timers
        case alarmApplyAll
        
        /// Delete time set
        case deleteTimeSet
        
        /// Save the time set
        case saveTimeSet
        
        /// Start the time set
        case startTimeSet
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
        
        /// Set should save `true`
        case save
        
        /// Set should start `true`
        case start
        
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
        
        /// Should save the time set
        var shouldSave: Bool
        
        /// Should start the time set
        var shouldStart: Bool
        
        /// Need to dismiss view
        var shouldDismiss: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    private let timeSetService: TimeSetServiceProtocol
    
    var timeSetItem: TimeSetItem
    
    // Sub reactor
    let timerOptionViewReactor: TimerOptionViewReactor
    
    // MARK: - constructor
    init?(appService: AppServiceProtocol, timeSetService: TimeSetServiceProtocol, timeSetItem: TimeSetItem? = nil) {
        self.appService = appService
        self.timeSetService = timeSetService
        
        if let timeSetItem = timeSetItem {
            // Copy time set item to preserve origin data
            guard let copiedItem = timeSetItem.copy() as? TimeSetItem else { return nil }
            
            self.timeSetItem = copiedItem
        } else {
            // Create new time set item
            let timeSetItem = TimeSetItem()
            timeSetItem.timers.append(TimerItem(alarm: appService.getAlarm()))
            
            self.timeSetItem = timeSetItem
        }
        
        // Create sub reactor
        timerOptionViewReactor = TimerOptionViewReactor()
        
        let timers = self.timeSetItem.timers.toArray()
        let timer = timers.first
        
        // Create section datasource
        let dataSource = TimerBadgeDataSource(
            timers: self.timeSetItem.timers.toArray(),
            extras: [
                .add: .add,
                .repeat: .repeat(TimerBadgeRepeatCellReactor(isRepeat: self.timeSetItem.isRepeat))
            ],
            leftExtras: [.repeat],
            rightExtras: [.add],
            index: 0
        )
        
        initialState = State(endTime: timer?.end ?? 0,
                             allTime: self.timeSetItem.timers.reduce(0) { $0 + $1.end },
                             time: 0,
                             sectionDataSource: dataSource,
                             selectedIndex: 0,
                             shouldSectionReload: true,
                             shouldSave: false,
                             shouldStart: false,
                             shouldDismiss: false)
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
            
        case .alarmApplyAll:
            return actionAlarmApplyAll()
            
        case .deleteTimeSet:
            return actionDeleteTimeSet()
            
        case .saveTimeSet:
            return actionSaveTimeSet()
            
        case .startTimeSet:
            return actionStartTimeSet()
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
        state.shouldSave = false
        state.shouldStart = false
        state.shouldDismiss = false
        
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
            
        case .save:
            state.shouldSave = true
            return state
            
        case .start:
            state.shouldStart = true
            return state
            
        case .dismiss:
            state.shouldDismiss = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionClearTimeSet() -> Observable<Mutation> {
        let state = currentState
        
        // Clear time set
        timeSetItem = TimeSetItem()
        timeSetItem.timers.append(TimerItem(alarm: appService.getAlarm()))
        
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
        let timers = List<TimerItem>()
        timers.append(TimerItem(alarm: appService.getAlarm()))
        timeSetItem.timers = timers
        
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
        timeSetItem.timers[state.selectedIndex].target = 0
        
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
        timeSetItem.timers[state.selectedIndex].target = timeInterval
        
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
        timeSetItem.isRepeat.toggle()
        
        if case let .repeat(reactor) = currentState.sectionDataSource.extras[.repeat] {
            reactor.action.onNext(.updateRepeat(timeSetItem.isRepeat))
        }
        
        return .empty()
    }
    
    private func actionAddTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Create timer and append into time set item
        let item = TimerItem(alarm: appService.getAlarm())
        timeSetItem.timers.append(item)
        
        // Create timer item and append into regular items
        state.sectionDataSource.append(item: item)
        
        let setSelectIndex = actionSelectTimer(at: state.sectionDataSource.regulars.count - 1)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(sectionReload, setSelectIndex)
    }
    
    private func actionDeleteTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Clear timer if try to delete the only timer
        guard timeSetItem.timers.count > 1 else { return actionClearTimer() }
        
        // Get will remove timer
        let index = state.selectedIndex
        let removedTimer = timeSetItem.timers[index]
        
        // Remove a timer
        timeSetItem.timers.remove(at: index)
        
        // Remove a timer item
        state.sectionDataSource.remove(at: index)
        
        // Calculate selected index
        // If selected index is last index, adjust index to last index of removed list
        let selectIndex = index < timeSetItem.timers.count ? index : index - 1
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - removedTimer.end))
        let setSelectIndex = actionSelectTimer(at: selectIndex)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setAllTime, setSelectIndex, sectionReload)
    }
    
    private func actionMoveTimer(at sourceIndex: Int, to destinationIndex: Int) -> Observable<Mutation> {
        let state = currentState
        
        // Swap timer
        timeSetItem.timers.swapAt(sourceIndex, destinationIndex)
        
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
        guard index >= 0 && index < timeSetItem.timers.count else { return .empty() }
        
        let state = currentState
        let previousIndex = state.selectedIndex
        
        var index = index
        if index != previousIndex && previousIndex < timeSetItem.timers.count {
            // Update to previous item state
            if timeSetItem.timers[previousIndex].end == 0 {
                // If current selected timer's end time is 0
                // Remove previous selected timer
                timeSetItem.timers.remove(at: previousIndex)
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
        let timer = timeSetItem.timers[index]
        timerOptionViewReactor.action.onNext(.updateTimer(timer, at: index))
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeSetItem.timers[index].end))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(index))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setTime, sectionReload, setSelectedIndex)
    }
    
    private func actionAlarmApplyAll() -> Observable<Mutation> {
        // Update alarm of all timers to selected timer's alarm
        let alarm = timeSetItem.timers[currentState.selectedIndex].alarm
        timeSetItem.timers.forEach { $0.alarm = alarm }
        
        return .empty()
    }
    
    private func actionDeleteTimeSet() -> Observable<Mutation> {
        guard let id = timeSetItem.id else { return .empty() }
        return timeSetService.removeTimeSet(id: id).asObservable()
            .flatMap { _ -> Observable<Mutation> in .just(.dismiss) }
    }
    
    private func actionSaveTimeSet() -> Observable<Mutation> {
        return .concat(
            validate(current: currentState.selectedIndex),
            .just(.save)
        )
    }
    
    private func actionStartTimeSet() -> Observable<Mutation> {
        timeSetItem.title = "time_set_default_title".localized
        
        return .concat(
            validate(current: currentState.selectedIndex),
            .just(.start)
        )
    }
    
    // MARK: - time set action method
    /// If current time set item doesn't asigned id(It is createing new), clear time set item due to save the time set
    private func actionTimeSetCreate() -> Observable<Mutation> {
        return actionClearTimeSet()
    }
    
    // MARK: - private method
    private func validate(current index: Int) -> Observable<Mutation> {
        let timer = timeSetItem.timers[index]
        if timer.end == 0 {
            let selectIndex = index > 0 ? index - 1 : index + 1
            return actionSelectTimer(at: selectIndex)
        }
        
        return .empty()
    }
    
    deinit {
        Logger.verbose()
    }
}
