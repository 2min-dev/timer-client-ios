//
//  TimeSetProcessViewReactor.swift
//  timer
//
//  Created by JSilver on 12/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetProcessViewReactor: Reactor {
    // MARK: - constants
    static let MAX_EXTRA_TIME: TimeInterval = TimeInterval(99 * Constants.Time.minute)
    
    enum Action {
        /// Start the time set after countdown when view will appear
        case viewWillAppear
        
        /// Toggle the time set repeat option
        case toggleRepeat
        
        /// Select timer at index
        case selectTimer(at: Int)
        
        /// Start the time set
        case startTimeSet(at: Int?)
        
        /// Start overtime record of time set
        case startOvertimeRecord
        
        /// Pause the time set
        case pauseTimeSet
        
        /// Cancel the time set
        case stopTimeSet
        
        /// Add some time into current timer
        case addExtraTime(TimeInterval)
    }
    
    enum Mutation {
        /// Set current ramained time of timer
        case setTime(TimeInterval)
        
        /// Set remainted time of time set
        case setRemainedTime(TimeInterval)
        
        /// Set time set is repeat
        case setRepeat(Bool)
        
        /// Set repeat count of time set
        case setRepeatCount(Int)
        
        /// Add extra time into current timer
        case setExtraTime(TimeInterval)
        
        /// Set current countdown state
        case setCountdownState(JSTimer.State)
        
        /// Set current remained countdown
        case setCountdown(Int)
        
        /// Set current state of time set
        case setTimeSetState(TimeSet.State)
        
        /// Set current timer
        case setTimer(TimerItem)
        
        /// Set current selected index
        case setSelectedIndex(at: Int)
        
        /// Set should section reload value to `true`
        case sectionReload
        
        /// Set should dismiss value to `true`
        case dismiss
    }
    
    struct State {
        /// Title of time set
        let title: String
        
        /// Remained time of current timer
        var time: TimeInterval
        
        /// All time of time set
        let allTime: TimeInterval
        
        /// Remained time of time set
        var remainedTime: TimeInterval
        
        /// Repeat setting value of time set
        var isRepeat: Bool
        
        /// Repeat count of time set
        var repeatCount: Int
        
        /// Sum of all added extra time
        var extraTime: TimeInterval
        
        /// Current countdown state
        var countdownState: JSTimer.State
        
        /// Remained countdown
        var countdown: Int
        
        /// Current state of time set
        var timeSetState: TimeSet.State
        
        /// Section datasource to make sections
        let sectionDataSource: TimerBadgeDataSource
        
        /// The timer list badge sections
        var sections: [TimerBadgeSectionModel] {
            sectionDataSource.makeSections()
        }
        
        /// Current running timer item
        var timer: TimerItem
        
        /// Index of current selected timer
        var selectedIndex: Int
        
        /// Flag that represent need to section reload
        var shouldSectionReload: Bool
        
        /// Flag that view should dismiss
        var shouldDismiss: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    private var timeSetService: TimeSetServiceProtocol
    
    let origin: TimeSetItem
    let timeSet: TimeSet // Running time set
    
    private var remainedTime: TimeInterval // Remained time that after executing timer of time set
    
    private var countdownTimer: JSTimer
    
    // MARK: - constructor
    init?(appService: AppServiceProtocol, timeSetService: TimeSetServiceProtocol, timeSetItem: TimeSetItem? = nil, start index: Int = 0) {
        self.appService = appService
        self.timeSetService = timeSetService
        
        var index = index
        if let timeSetItem = timeSetItem {
            guard index >= 0 && index < timeSetItem.timers.count else {
                Logger.error("can't start from \(index) because time set not fulfill count of timers", tag: "TIME SET PROCESS")
                return nil
            }
            
            // Copy time set item to preserve origin data
            guard let copiedItem = timeSetItem.copy() as? TimeSetItem else { return nil }
            
            origin = timeSetItem
            timeSet = TimeSet(item: copiedItem)
        } else {
            // Fetch running time set from time set service
            guard let runningTimeSet = timeSetService.runningTimeSet else {
                Logger.error("no running time set.", tag: "TIME SET PROCESS")
                return nil
            }
            
            origin = runningTimeSet.origin
            timeSet = runningTimeSet.timeSet
            
            index = timeSet.currentIndex
        }
        
        // Create countdown timer
        countdownTimer = JSTimer(item: TimerItem(target: TimeInterval(appService.getCountdown())))
        if timeSetItem == nil {
            // Countdown end if time set isn't initial state
            countdownTimer.end()
        }
        
        // Calculate remainted time
        remainedTime = timeSet.item.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.end }
        
        // Get initial state
        let timer = timeSet.item.timers[index]
        let allTime = timeSet.item.timers.reduce(0) { $0 + $1.end }
        let extraTime = timeSet.item.timers.reduce(0) { $0 + $1.extra }
        let time = timer.end + timer.extra - timer.current
        let remainedTime = self.remainedTime + time
        
        // Create seciont datasource
        let dataSource = TimerBadgeDataSource(timers: timeSet.item.timers.toArray(), index: index)
        
        initialState = State(title: timeSet.item.title,
                             time: time,
                             allTime: allTime,
                             remainedTime: remainedTime,
                             isRepeat: timeSet.item.isRepeat,
                             repeatCount: timeSet.history.repeatCount,
                             extraTime: extraTime,
                             countdownState: countdownTimer.state,
                             countdown: Int(ceil(countdownTimer.item.end - countdownTimer.item.current)),
                             timeSetState: timeSet.state,
                             sectionDataSource: dataSource,
                             timer: timer,
                             selectedIndex: index,
                             shouldSectionReload: true,
                             shouldDismiss: false)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
            
        case .toggleRepeat:
            return actionToggleRepeat()
            
        case let .selectTimer(at: index):
            return actionSelectTimer(at: index)
            
        case let .startTimeSet(at: index):
            return actionStartTimeSet(at: index)
            
        case .startOvertimeRecord:
            return actionStartOvertimeRecord()
            
        case .pauseTimeSet:
            return actionPauseTimeSet()
            
        case .stopTimeSet:
            return actionStopTimeSet()
            
        case let .addExtraTime(timeInterval) :
            return actionAddExtraTime(timeInterval)
        }
    }
    
    func mutate(timerEvent: JSTimer.Event) -> Observable<Mutation> {
        switch timerEvent {
        case let .stateChanged(state, item: item):
            return actionCountdownTimerStateChanged(state, item: item)
            
        case let .timeChanged(current: currentTime, end: endTime):
            return actionCountdownTimeChanged(current: currentTime, end: endTime)
        }
    }
    
    func mutate(timeSetEvent: TimeSet.Event) -> Observable<Mutation> {
        switch timeSetEvent {
        case let .stateChanged(state):
            return actionTimeSetStateChanged(state)
            
        case let .timerChanged(timer, at: index):
            return actionTimeSetTimerChanged(timer, at: index)
            
        case let .timeChanged(current: currentTime, end: endTime):
            return actionTimeSetTimeChanged(current: currentTime, end: endTime)
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let countdownEventMutation = countdownTimer.event
            .flatMap { [weak self] in self?.mutate(timerEvent: $0) ?? .empty() }
        
        let timeSetEventMutation = timeSet.event
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        return .merge(mutation, countdownEventMutation, timeSetEventMutation)
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
            
        case let .setRemainedTime(remainedTime):
            state.remainedTime = remainedTime
            return state
            
        case let .setRepeat(isRepeat):
            state.isRepeat = isRepeat
            return state
            
        case let .setRepeatCount(count):
            state.repeatCount = count
            return state
            
        case let .setExtraTime(extraTime):
            state.extraTime = extraTime
            return state
            
        case let .setCountdownState(countdownState):
            state.countdownState = countdownState
            return state
            
        case let .setCountdown(countdown):
            state.countdown = countdown
            return state
            
        case let .setTimeSetState(timeSetState):
            state.timeSetState = timeSetState
            return state
            
        case let .setTimer(timer):
            state.timer = timer
            return state
            
        case let .setSelectedIndex(at: index):
            state.selectedIndex = index
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
        if countdownTimer.state == .stop {
            // Start the time set if the time set has never has been start
            countdownTimer.start()
        }
        
        return .empty()
    }
    
    private func actionToggleRepeat() -> Observable<Mutation> {
        // Toggle time set repeat option
        timeSet.item.isRepeat.toggle()
        return .just(.setRepeat(timeSet.item.isRepeat))
    }
    
    private func actionSelectTimer(at index: Int) -> Observable<Mutation> {
        guard index >= 0 && index < timeSet.item.timers.count else { return .empty() }
        
        let state = currentState
        let previousIndex = state.selectedIndex
        
        // Update selected timer state
        if index != previousIndex {
            state.sectionDataSource.regulars[previousIndex].action.onNext(.select(false))
        }
        state.sectionDataSource.regulars[index].action.onNext(.select(true))
        
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(at: index))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSet.item.timers[index]))
        
        return .concat(setSelectedIndex, setTimer)
    }
    
    private func actionStartTimeSet(at index: Int?) -> Observable<Mutation> {
        if let index = index {
            // Restart time set from timer at index (reset)
            guard index >= 0 && index < timeSet.item.timers.count else { return .empty() }
            // Stop countdown & initialize time set
            countdownTimer.stop()
            timeSet.stop()
            
            // Start time set
            timeSet.start(.normal(at: index))
            
            let selectTimer: Observable<Mutation> = actionSelectTimer(at: index)
            let setTime: Observable<Mutation> = .just(.setTime(timeSet.item.timers[index].end))
            let setExtraTime: Observable<Mutation> = .just(.setExtraTime(0))
            
            return .concat(selectTimer, setTime, setExtraTime)
        } else {
            // Resume had been running time set or countdown
            if countdownTimer.state != .end {
                // Resume countdown
                countdownTimer.start()
            } else {
                // Resume time set
                timeSet.start()
            }
            
            return .empty()
        }
    }
    
    private func actionStartOvertimeRecord() -> Observable<Mutation> {
        timeSet.start(.overtime)
        return .empty()
    }
    
    private func actionPauseTimeSet() -> Observable<Mutation> {
        if countdownTimer.state != .end {
            // Pause countdown
            countdownTimer.pause()
            return .just(.setCountdownState(.pause))
        } else {
            // Pause time set
            timeSet.pause()
            return .empty()
        }
    }
    
    private func actionStopTimeSet() -> Observable<Mutation> {
        if countdownTimer.state != .end {
            // Dismiss
            countdownTimer.stop()
        } else {
            // Cancel the time set
            timeSet.stop()
        }

        return .just(.dismiss)
    }
    
    private func actionAddExtraTime(_ extra: TimeInterval) -> Observable<Mutation> {
        let state = currentState
        guard state.extraTime < TimeSetProcessViewReactor.MAX_EXTRA_TIME else { return .empty() }
        
        // Add extra time into current timer
        state.timer.extra += extra
        
        let setExtraTime: Observable<Mutation> = .just(.setExtraTime(state.extraTime + extra))
        let setTime: Observable<Mutation> = .just(.setTime(state.time + extra))
        let setRemainedTime: Observable<Mutation> = .just(.setRemainedTime(state.remainedTime + extra))
        
        return .concat(setExtraTime, setTime, setRemainedTime)
    }
    
    // MARK: - countdown timer action method
    private func actionCountdownTimerStateChanged(_ state: JSTimer.State, item: Recordable) -> Observable<Mutation> {
        let setCountdownState: Observable<Mutation> = .just(.setCountdownState(state))
        
        switch state {
        case .end:
            return .concat(setCountdownState, actionStartTimeSet(at: currentState.selectedIndex))
            
        default:
            return setCountdownState
        }
    }
    
    private func actionCountdownTimeChanged(current: TimeInterval, end: TimeInterval) -> Observable<Mutation> {
        return .just(.setCountdown(Int(ceil(end - current))))
    }
    
    // MARK: - time set action method
    private func actionTimeSetStateChanged(_ state: TimeSet.State) -> Observable<Mutation> {
        let setTimeSetState: Observable<Mutation> = .just(.setTimeSetState(state))
        
        switch state {
        case .run:
            let setExtraTime: Observable<Mutation> = .just(.setExtraTime(timeSet.item.timers.reduce(0) { $0 + $1.extra }))
            let setRepeatCount: Observable<Mutation> = .just(.setRepeatCount(timeSet.history.repeatCount))
            
            if timeSetService.runningTimeSet == nil {
                // Set running time set only first time
                timeSetService.runningTimeSet = RunningTimeSet(timeSet: timeSet, origin: origin)
            }
            
            return .concat(setTimeSetState, setExtraTime, setRepeatCount)
            
        case .end:
            timeSetService.runningTimeSet = nil
            
            switch timeSet.history.endState {
            case .normal,
                 .cancel:
                _ = timeSetService.createHistory(timeSet.history).subscribe()
                
            case .overtime:
                _ = timeSetService.updateHistory(timeSet.history).subscribe()
                
            default:
                break
            }
            
        default:
            break
        }
        
        return setTimeSetState
    }
    
    private func actionTimeSetTimerChanged(_ timer: TimerItem, at index: Int) -> Observable<Mutation> {
        // Calculate remained time
        remainedTime = timeSet.item.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.end }
        
        return .concat(actionSelectTimer(at: index),
                       .just(.setRemainedTime(remainedTime + timer.end)))
    }
    
    private func actionTimeSetTimeChanged(current: TimeInterval, end: TimeInterval) -> Observable<Mutation> {
        return .concat(.just(.setTime(abs(end - floor(current)))),
                       .just(.setRemainedTime(remainedTime + end - current)))
    }
    
    deinit {
        Logger.verbose()
    }
}
