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
    static let MAX_TIMER_COUNT: Int = 15
    
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
        
        /// Add a timer into time set
        case addTimer
        
        /// Delete a timer from time set
        case deleteTimer
        
        /// Change timer position
        case moveTimer(at: Int, to: Int)
        
        /// Select the timer
        case selectTimer(at: Int)
        
        /// Apply alarm to all timers
        case alarmApplyAll(Alarm)
        
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
        
        /// Set sections
        case setSections([TimerBadgeSectionModel])
        
        /// Set selected index
        case setSelectedIndex(Int)
        
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
        
        /// The timer list badge sections
        var sections: RevisionValue<[TimerBadgeSectionModel]>
        
        /// Current selected timer index path
        var selectedIndex: Int
        
        /// Should save the time set
        var shouldSave: RevisionValue<Bool?>
        
        /// Should start the time set
        var shouldStart: RevisionValue<Bool?>
        
        /// Need to dismiss view
        var shouldDismiss: RevisionValue<Bool?>
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    private let timeSetService: TimeSetServiceProtocol
    
    var timeSetItem: TimeSetItem
    private var dataSource: TimerBadgeSectionDataSource
    
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
            self.timeSetItem = TimeSetItem()
            self.timeSetItem.timers.append(TimerItem(alarm: appService.getAlarm()))
        }
        
        // Create sub reactor
        timerOptionViewReactor = TimerOptionViewReactor()
        
        let timers = self.timeSetItem.timers.toArray()
        let timer = timers.first
        
        // Create section datasource
        dataSource = TimerBadgeSectionDataSource(
            regulars: timers,
            leftExtras: [.repeat(TimerBadgeRepeatCellReactor(timeSetItem: self.timeSetItem))],
            rightExtras: [.add],
            index: 0
        )
        
        initialState = State(
            endTime: timer?.end ?? 0,
            allTime: timers.reduce(0) { $0 + $1.end },
            time: 0,
            sections: RevisionValue(dataSource.makeSections(isExtrasIncluded: {
                switch $1 {
                case .add:
                    return $0.count < Self.MAX_TIMER_COUNT && timer?.end ?? 0 > 0
                    
                case .repeat(_):
                    return true
                }
            })),
            selectedIndex: 0,
            shouldSave: RevisionValue(nil),
            shouldStart: RevisionValue(nil),
            shouldDismiss: RevisionValue(nil)
        )
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
            
        case .addTimer:
            return actionAddTimer()
            
        case .deleteTimer:
            return actionDeleteTimer()
            
        case let .moveTimer(at: sourceIndex, to: destinationIndex):
            return actionMoveTimer(at: sourceIndex, to: destinationIndex)
            
        case let .selectTimer(index):
            return actionSelectTimer(at: index)
            
        case let .alarmApplyAll(alarm):
            return actionAlarmApplyAll(alarm)
            
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
            
        case let .setSections(sections):
            state.sections = state.sections.next(sections)
            return state
            
        case let .setSelectedIndex(index):
            state.selectedIndex = index
            return state
            
        case .save:
            state.shouldSave = state.shouldSave.next(true)
            return state
            
        case .start:
            state.shouldStart = state.shouldStart.next(true)
            return state
            
        case .dismiss:
            state.shouldDismiss = state.shouldDismiss.next(true)
            return state
        }
    }
    
    // MARK: - action method
    private func actionClearTimeSet() -> Observable<Mutation> {
        // Clear time set
        timeSetItem = TimeSetItem()
        timeSetItem.timers.append(TimerItem(alarm: appService.getAlarm()))
        
        // Clear section data source
        dataSource.clear()
        dataSource.setTimeSet(item: timeSetItem)
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(0))
        let setSelectedIndex: Observable<Mutation> = actionSelectTimer(at: 0)
        
        return .concat(setAllTime, setSelectedIndex)
    }
    
    private func actionClearTimers() -> Observable<Mutation> {
        // Clear default timers
        let timers = [TimerItem(alarm: appService.getAlarm())]
        timeSetItem.timers = timers.toList()
        
        // Clear section data source
        dataSource.clear()
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(0))
        let setSelectedIndex: Observable<Mutation> = actionSelectTimer(at: 0)
        
        return .concat(setAllTime, setSelectedIndex)
    }
    
    private func actionClearTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Clear the timer's end time
        timeSetItem.timers[state.selectedIndex].target = 0
        dataSource.setTime(0, at: state.selectedIndex)
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(0))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - state.endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSections: Observable<Mutation> = .just(.setSections(dataSource.makeSections(isExtrasIncluded: isExtraIncluded(endTime: 0))))
        
        return .concat(setEndTime, setAllTime, setTime, setSections)
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
        dataSource.setTime(timeInterval, at: state.selectedIndex)
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeInterval))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - state.endTime + timeInterval))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSections: Observable<Mutation> = .just(.setSections(dataSource.makeSections(isExtrasIncluded: isExtraIncluded(endTime: timeInterval))))
        
        return .concat(setEndTime, setAllTime, setTime, setSections)
    }
    
    private func actionAddTimer() -> Observable<Mutation> {
        // Create timer and append into time set item
        let item = TimerItem(alarm: appService.getAlarm())
        timeSetItem.timers.append(item)
        dataSource.append(item: item)
        
        return actionSelectTimer(at: dataSource.regularSection.count - 1)
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
        dataSource.remove(at: index)
        
        // Calculate selected index
        // If selected index is last index, adjust index to last index of removed list
        let selectIndex = index < timeSetItem.timers.count ? index : index - 1
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - removedTimer.end))
        let setSelectIndex: Observable<Mutation> = actionSelectTimer(at: selectIndex)
        
        return .concat(setAllTime, setSelectIndex)
    }
    
    private func actionMoveTimer(at sourceIndex: Int, to destinationIndex: Int) -> Observable<Mutation> {
        let state = currentState
        
        // Swap timer
        timeSetItem.timers.swapAt(sourceIndex, destinationIndex)
        dataSource.swap(at: sourceIndex, to: destinationIndex)
        
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
        guard (0 ..< timeSetItem.timers.count).contains(index) else { return .empty() }
        
        var index = index
        let previousIndex = currentState.selectedIndex
        // When user remove the timer, remove action perform remove the timer of time set & data source.
        // So double-check that timer exist at previous selected index.
        if index != previousIndex && (0 ..< dataSource.regularSection.count).contains(previousIndex) {
            // Update to previous item state
            if timeSetItem.timers[previousIndex].end == 0 {
                // If current selected timer's end time is 0, remove previous selected timer.
                timeSetItem.timers.remove(at: previousIndex)
                dataSource.remove(at: previousIndex)
                
                // Adjust index
                index = index > previousIndex ? index - 1 : index
            } else {
                // Deselect previous item
                dataSource.setSelected(false, at: previousIndex)
            }
        }
        
        // Select current item
        dataSource.setSelected(true, at: index)
        
        let timer = timeSetItem.timers[index]
        // Update timer info of timer option reactor
        timerOptionViewReactor.action.onNext(.updateTimer(timer, at: index))
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timer.end))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(index))
        let setSections: Observable<Mutation> = .just(.setSections(dataSource.makeSections(isExtrasIncluded: isExtraIncluded(endTime: timer.end))))
        
        return .concat(setEndTime, setTime, setSections, setSelectedIndex)
    }
    
    private func actionAlarmApplyAll(_ alarm: Alarm) -> Observable<Mutation> {
        // Update alarm of all timers to selected timer's alarm
        timeSetItem.timers.forEach { $0.alarm = alarm }
        return .empty()
    }
    
    private func actionDeleteTimeSet() -> Observable<Mutation> {
        return timeSetService.removeTimeSet(id: timeSetItem.id).asObservable()
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
    private func isExtraIncluded(endTime: TimeInterval) -> ([TimerBadgeCellType], TimerBadgeExtraCellType) -> Bool {
        return {
            switch $1 {
            case .add:
                return $0.count < Self.MAX_TIMER_COUNT && endTime > 0
                
            case .repeat:
                return true
            }
        }
    }
    
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
