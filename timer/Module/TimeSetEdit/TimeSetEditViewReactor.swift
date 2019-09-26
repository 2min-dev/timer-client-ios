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
    private let MAX_TIMER_COUNT: Int = 10
    
    private enum TimerBadgeExtraType {
        case add
        case `repeat`
    }
    
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
        
        /// Set timer list badge sections
        case setSections([TimerBadgeSectionModel])
        
        /// Set selected index
        case setSelectedIndex(Int)
        
        /// Set alert message
        case setAlertMessage(String)
        
        /// Set should section reload `true`
        case sectionReload
        
        /// Set should dismiss `true`
        case dismiss
    }
    
    struct State {
        /// The time of timer
        var endTime: TimeInterval = 0
        
        /// All time of time set
        var allTime: TimeInterval = 0
        
        /// The time that user inputed
        var time: Int = 0
        
        /// The timer list badge sections
        var sections: [TimerBadgeSectionModel] = []
        
        /// Current selected timer index path
        var selectedIndex: Int = 0
        
        /// Alert message
        var alertMessage: String?
        
        /// Need section reload
        var shouldSectionReload: Bool = false
        
        /// Need to dismiss view
        var shouldDismiss: Bool = false
    }
    
    // MARK: - properties
    var initialState: State = State()
    private let timeSetService: TimeSetServiceProtocol

    var timeSetInfo: TimeSetInfo
    
    private var regularItems: [TimerBadgeCellReactor] = []
    private lazy var extraItems: [TimerBadgeExtraType: TimerBadgeExtraCellType] = [
        .add: .add,
        .repeat: .repeat(TimerBadgeRepeatCellReactor(isRepeat: timeSetInfo.isRepeat))
    ]
    
    private var itemId: Int = 0
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, timeSetInfo: TimeSetInfo? = nil) {
        self.timeSetService = timeSetService
        self.timeSetInfo = timeSetInfo ?? TimeSetInfo(id: nil)
        
        let timers = self.timeSetInfo.timers.toArray()
        let timer = timers.first
        
        itemId = timers.count
        regularItems = self.timeSetInfo.timers.enumerated().map {
            TimerBadgeCellReactor(id: $0.offset,
                                  time: $0.element.endTime,
                                  index: $0.offset + 1,
                                  count: timers.count,
                                  isSelected: $0.offset == 0)
        }
        
        initialState = State(endTime: timer?.endTime ?? 0,
                             allTime: self.timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                             time: 0,
                             sections: makeSections(regular: regularItems, time: timer?.endTime ?? 0),
                             selectedIndex: 0,
                             alertMessage: nil,
                             shouldSectionReload: true,
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
            
        case .deleteTimeSet:
            return actionDeleteTimeSet()
            
        case let .applyAlarm(alarm):
            return actionApplyAlarm(alarm)
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
        state.alertMessage = nil
        
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
            
        case let .setSections(timers):
            state.sections = timers
            return state
            
        case let .setSelectedIndex(index):
            let section: Int = TimerBadgeSectionType.regular.rawValue
            guard index >= 0 && index < state.sections[section].items.count else { return state }
            state.selectedIndex = index
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
    private func actionClearTimeSet() -> Observable<Mutation> {
        // Clear time set
        timeSetInfo = TimeSetInfo(id: nil)
        
        // Clear timer items
        regularItems = [regularItems.first].compactMap { $0 }
        
        extraItems = [
            .add: .add,
            .repeat: .repeat(TimerBadgeRepeatCellReactor(isRepeat: timeSetInfo.isRepeat))
        ]
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(0))
        let setSections: Observable<Mutation> = .just(.setSections(makeSections(regular: regularItems)))
        let setSelectedIndex: Observable<Mutation> = actionSelectTimer(at: 0)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setAllTime, setSections, setSelectedIndex, sectionReload)
    }
    
    private func actionClearTimers() -> Observable<Mutation> {
        guard let item = regularItems.first else { return .empty() }
        
        // Clear default timers
        let timers = List<TimerInfo>()
        timers.append(TimerInfo())
        timeSetInfo.timers = timers
        
        // Clear timer items
        item.action.onNext(.updateTime(0))
        regularItems = [item]
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(0))
        let setSections: Observable<Mutation> = .just(.setSections(makeSections(regular: regularItems)))
        let setSelectedIndex: Observable<Mutation> = actionSelectTimer(at: 0)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setAllTime, setSections, setSelectedIndex, sectionReload)
    }
    
    private func actionClearTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Clear the timer's end time
        timeSetInfo.timers[state.selectedIndex].endTime = 0
        
        // Update badge time
        regularItems[state.selectedIndex].action.onNext(.updateTime(0))
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(0))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - state.endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSections: Observable<Mutation> = .just(.setSections(makeSections(regular: regularItems)))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setAllTime, setTime, setSections, sectionReload)
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
        regularItems[state.selectedIndex].action.onNext(.updateTime(timeInterval))
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeInterval))
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - state.endTime + timeInterval))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSections: Observable<Mutation> = .just(.setSections(makeSections(regular: regularItems, time: timeInterval)))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setAllTime, setTime, setSections, sectionReload)
    }
    
    private func actionToggleRepeat() -> Observable<Mutation> {
        // Toggle time set repeat
        timeSetInfo.isRepeat.toggle()
        
        if case let .repeat(reactor) = extraItems[.repeat] {
            reactor.action.onNext(.updateRepeat(timeSetInfo.isRepeat))
        }
        
        return .empty()
    }
    
    private func actionAddTimer() -> Observable<Mutation> {
        // Create timer and append into time set info
        let info = TimerInfo()
        timeSetInfo.timers.append(info)
        
        // Create timer item and append into regular items
        let count = timeSetInfo.timers.count
        regularItems.append(TimerBadgeCellReactor(id: itemId, time: info.endTime, index: count, count: count))
        itemId += 1
        
        let setSections: Observable<Mutation> = .just(.setSections(makeSections(regular: regularItems, time: info.endTime)))
        let setSelectIndex = actionSelectTimer(at: count - 1)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSections, sectionReload, setSelectIndex)
    }
    
    private func actionDeleteTimer() -> Observable<Mutation> {
        let state = currentState
        
        // Get will remove timer
        let index = state.selectedIndex
        let removedTimer = timeSetInfo.timers[index]
        
        // Remove a timer
        timeSetInfo.timers.remove(at: index)
        
        // Remove a timer item
        regularItems.remove(at: index)
        
        // Calculate selected index
        // If selected index is last index, adjust index to last index of removed list
        let selectIndex = index < timeSetInfo.timers.count ? index : index - 1
        
        let setAllTime: Observable<Mutation> = .just(.setAllTime(state.allTime - removedTimer.endTime))
        let setSections: Observable<Mutation> = .just(.setSections(makeSections(regular: regularItems,
                                                                                time: timeSetInfo.timers[selectIndex].endTime)))
        let setSelectIndex = actionSelectTimer(at: selectIndex)
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setAllTime, setSelectIndex, setSections, sectionReload)
    }
    
    private func actionMoveTimer(at sourceIndex: Int, to destinationIndex: Int) -> Observable<Mutation> {
        let state = currentState
        
        // Swap timer
        timeSetInfo.timers.swapAt(sourceIndex, destinationIndex)
        
        // Swap timer item & update index
        regularItems.swapAt(sourceIndex, destinationIndex)
        regularItems[sourceIndex].action.onNext(.updateIndex(sourceIndex + 1))
        regularItems[destinationIndex].action.onNext(.updateIndex(destinationIndex + 1))
        
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
        let state = currentState
        
        let previousIndex = state.selectedIndex
        var index = index
        
        if index != previousIndex && previousIndex < timeSetInfo.timers.count {
            // Update to previous item state
            if timeSetInfo.timers[previousIndex].endTime == 0 {
                // If current selected timer's end time is 0
                // Remove previous selected timer
                timeSetInfo.timers.remove(at: previousIndex)
                regularItems.remove(at: previousIndex)
                
                // Adjust index
                index = index > previousIndex ? index - 1 : index
            } else {
                // Deselect previous item
                regularItems[previousIndex].action.onNext(.select(false))
            }
        }
        
        // Select current item
        regularItems[index].action.onNext(.select(true))
        
        let setEndTime: Observable<Mutation> = .just(.setEndTime(timeSetInfo.timers[index].endTime))
        let setTime: Observable<Mutation> = .just(.setTime(0))
        let setSections: Observable<Mutation> = .just(.setSections(makeSections(regular: regularItems,
                                                                                time: timeSetInfo.timers[index].endTime)))
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(index))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEndTime, setTime, setSections, sectionReload, setSelectedIndex)
    }
    
    private func actionDeleteTimeSet() -> Observable<Mutation> {
        guard let id = timeSetInfo.id else { return .empty() }
        return timeSetService.removeTimeSet(id: id).asObservable()
            .flatMap { _ -> Observable<Mutation> in .just(.dismiss) }
    }
    
    private func actionApplyAlarm(_ alarm: String) -> Observable<Mutation> {
        timeSetInfo.timers.forEach { $0.alarm = alarm }
        return .just(.setAlertMessage("alert_alarm_all_apply_description".localized))
    }
    
    /// If current time set info doesn't asigned id(It is createing new), clear time set info due to save the time set
    private func actionTimeSetCreate() -> Observable<Mutation> {
        return actionClearTimeSet()
    }
    
    // MARK: - private method
    private func makeSections(regular: [TimerBadgeCellReactor], left: [TimerBadgeExtraType] = [.repeat], right: [TimerBadgeExtraType] = [.add], time: TimeInterval = 0) -> [TimerBadgeSectionModel] {
    
        let count = regular.count
        let regularItem: [TimerBadgeCellType] = regular.enumerated().map { (offset, reactor) in
            reactor.action.onNext(.updateIndex(offset + 1))
            reactor.action.onNext(.updateCount(count))
            
            return .regular(reactor)
        }
        
        let leftItems: [TimerBadgeCellType] = left
            .filter { isExtraItemIncluded(type: $0, count: count, time: time) }
            .compactMap { extraItems[$0] }
            .map { .extra($0) }
        
        let rightItems: [TimerBadgeCellType] = right
            .filter { isExtraItemIncluded(type: $0, count: count, time: time) }
            .compactMap { extraItems[$0] }
            .map { .extra($0) }
        
        return [
            TimerBadgeSectionModel(model: .leftExtra, items: leftItems),
            TimerBadgeSectionModel(model: .regular, items: regularItem),
            TimerBadgeSectionModel(model: .rightExtra, items: rightItems)
        ]
    }
    
    private func isExtraItemIncluded(type: TimerBadgeExtraType, count: Int, time: TimeInterval) -> Bool {
        switch type {
        case .add:
            return count < MAX_TIMER_COUNT && time > 0
            
        case .repeat:
            return true
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
