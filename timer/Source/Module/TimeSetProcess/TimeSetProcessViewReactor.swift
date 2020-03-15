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
        
        /// Stop alarm
        case stopAlarm
        
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
        
        /// Add extra time into current timer
        case setExtraTime(TimeInterval)
        
        /// Set current countdown state
        case setCountdownState(JSTimer.State)
        
        /// Set current remained countdown
        case setCountdown(Int)
        
        /// Set current state of time set
        case setTimeSetState(TimeSet.State)
        
        /// Set current running timer state
        case setTimerState(JSTimer.State)
        
        /// Set current timer
        case setTimer(TimerItem)
        
        /// Set current selected index
        case setSelectedIndex(at: Int)
        
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
        
        /// Sum of all added extra time
        var extraTime: TimeInterval
        
        /// Current countdown state
        var countdownState: JSTimer.State
        
        /// Remained countdown
        var countdown: Int
        
        /// Current state of time set
        var timeSetState: TimeSet.State
        
        /// Current running timer state of time set
        var timerState: JSTimer.State
        
        /// The timer list badge sections
        var sections: RevisionValue<[TimerBadgeSectionModel]>
        
        /// Current running timer item
        var timer: TimerItem
        
        /// Index of current selected timer
        var selectedIndex: Int
        
        /// Flag that represent need to section reload
        var shouldSectionReload: Bool
        
        /// Flag that represent current time set can save
        let canTimeSetSave: Bool
        
        /// Flag that view should dismiss
        var shouldDismiss: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    private var timeSetService: TimeSetServiceProtocol
    private let historyService: HistoryServiceProtocol
    
    private var dataSource: TimerBadgeSectionDataSource
    
    let origin: TimeSetItem
    let timeSet: TimeSet // Running time set
    private var countdownTimer: JSTimer
    
    private var remainedTime: TimeInterval // Remained time that after executing timer of time set
    
    // MARK: - constructor
    private init(
        appService: AppServiceProtocol,
        timeSetService: TimeSetServiceProtocol,
        historyService: HistoryServiceProtocol,
        origin: TimeSetItem,
        timeSet: TimeSet,
        canSave: Bool
    ) {
        self.appService = appService
        self.timeSetService = timeSetService
        self.historyService = historyService

        self.origin = origin
        self.timeSet = timeSet
        
        // Get initial state
        let index = timeSet.currentIndex
        let timer = timeSet.item.timers[index]
        let time = timer.end - timer.current
        
        // Create countdown timer
        countdownTimer = JSTimer(item: TimerItem(target: TimeInterval(appService.getCountdown())))
        remainedTime = timeSet.item.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.end }
        
        // Create seciont datasource
        dataSource = TimerBadgeSectionDataSource(regulars: timeSet.item.timers.toArray(), index: index)
        
        initialState = State(
            title: timeSet.item.title,
            time: time,
            allTime: timeSet.item.timers.reduce(0) { $0 + $1.end },
            remainedTime: remainedTime + time,
            isRepeat: timeSet.item.isRepeat,
            extraTime: timeSet.item.timers.reduce(0) { $0 + $1.extra },
            countdownState: countdownTimer.state,
            countdown: Int(ceil(countdownTimer.item.end - countdownTimer.item.current)),
            timeSetState: timeSet.state,
            timerState: timeSet.timer.state,
            sections: RevisionValue(dataSource.makeSections()),
            timer: timer,
            selectedIndex: index,
            shouldSectionReload: true,
            canTimeSetSave: canSave,
            shouldDismiss: false
        )
    }
    
    convenience init?(
        appService: AppServiceProtocol,
        timeSetService: TimeSetServiceProtocol,
        historyService: HistoryServiceProtocol
    ) {
        // Fetch running time set from time set service
        guard let runningTimeSet = timeSetService.runningTimeSet else {
            Logger.error("no running time set.", tag: "TIME SET PROCESS")
            return nil
        }
        
        self.init(
            appService: appService,
            timeSetService: timeSetService,
            historyService: historyService,
            origin: runningTimeSet.origin,
            timeSet: runningTimeSet.timeSet,
            canSave: runningTimeSet.canSave
        )
        
        // End countdown timer
        countdownTimer.end()
    }
    
    convenience init?(
        appService: AppServiceProtocol,
        timeSetService: TimeSetServiceProtocol,
        historyService: HistoryServiceProtocol,
        timeSetItem: TimeSetItem,
        startIndex: Int,
        canSave: Bool
    ) {
        // Check start index
        guard (0 ..< timeSetItem.timers.count).contains(startIndex) else {
            Logger.error("can't start from \(startIndex) because time set not fulfill count of timers", tag: "TIME SET PROCESS")
            return nil
        }
        
        // Copy time set item to preserve origin data
        guard let copiedItem = timeSetItem.copy() as? TimeSetItem else { return nil }
        
        self.init(
            appService: appService,
            timeSetService: timeSetService,
            historyService: historyService,
            origin: timeSetItem,
            timeSet: TimeSet(item: copiedItem, index: startIndex),
            canSave: canSave
        )
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
            
        case .stopAlarm:
            return actionStopAlarm()
            
        case let .addExtraTime(timeInterval) :
            return actionAddExtraTime(timeInterval)
        }
    }
    
    func mutate(countdownEvent: JSTimer.Event) -> Observable<Mutation> {
        switch countdownEvent {
        case let .stateChanged(state, item: item):
            return actionCountdownTimerStateChanged(state, item: item)
            
        case let .timeChanged(current, end, diff: _):
            return actionCountdownTimeChanged(current, end)
        }
    }
    
    func mutate(timeSetEvent: TimeSet.Event) -> Observable<Mutation> {
        switch timeSetEvent {
        case let .stateChanged(state):
            return actionTimeSetStateChanged(state)
            
        case let .timerChanged(timer, at: index):
            return actionTimeSetTimerChanged(timer, at: index)
            
        case let .timeChanged(current, end):
            return actionTimeSetTimeChanged(current, end)
        }
    }
    
    func mutate(timerEvent: JSTimer.Event) -> Observable<Mutation> {
        switch timerEvent {
        case let .stateChanged(state, item: _):
            return actionTimerStateChanged(state)
            
        case .timeChanged(_, _, diff: _):
            return .empty()
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let countdownEventMutation = countdownTimer.event
            .flatMap { [weak self] in self?.mutate(countdownEvent: $0) ?? .empty() }
        
        let timeSetEventMutation = timeSet.event
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        let timerEventMutation = timeSet.timer.event
            .flatMap { [weak self] in self?.mutate(timerEvent: $0) ?? .empty() }
        
        return .merge(mutation, countdownEventMutation, timeSetEventMutation, timerEventMutation)
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
            
        case let .setTimerState(timerState):
            state.timerState = timerState
            return state
            
        case let .setTimer(timer):
            state.timer = timer
            return state
            
        case let .setSelectedIndex(at: index):
            state.selectedIndex = index
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
            dataSource.setSelected(false, at: previousIndex)
        }
        dataSource.setSelected(true, at: index)
        
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(at: index))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSet.item.timers[index]))
        
        return .concat(setSelectedIndex, setTimer)
    }
    
    private func actionStartTimeSet(at index: Int?) -> Observable<Mutation> {
        if let index = index {
            // Restart time set from timer at index (reset)
            guard index >= 0 && index < timeSet.item.timers.count else { return .empty() }
            // Stop countdown & initialize time set
            countdownTimer.end()
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
            timeSet.end()
        }

        return .just(.dismiss)
    }
    
    private func actionStopAlarm() -> Observable<Mutation> {
        timeSet.audioPlayer?.stop()
        return .empty()
    }
    
    // FIXME: refactor method to reduce repeated `+ extra` assignment
    private func actionAddExtraTime(_ extra: TimeInterval) -> Observable<Mutation> {
        let state = currentState
        guard state.extraTime < TimeSetProcessViewReactor.MAX_EXTRA_TIME else { return .empty() }
        
        // Add extra time into current timer
        state.timer.extra += extra
        timeSet.history.extraTime += extra
        
        let setExtraTime: Observable<Mutation> = .just(.setExtraTime(state.extraTime + extra))
        let setTime: Observable<Mutation> = .just(.setTime(state.time + extra))
        let setRemainedTime: Observable<Mutation> = .just(.setRemainedTime(state.remainedTime + extra))
        
        return .concat(setExtraTime, setTime, setRemainedTime)
    }
    
    // MARK: - countdown timer action method
    private func actionCountdownTimerStateChanged(_ state: JSTimer.State, item: Recordable) -> Observable<Mutation> {
        switch state {
        case .end:
            timeSet.start()
            
        default:
            break
        }
        
        return .just(.setCountdownState(state))
    }
    
    private func actionCountdownTimeChanged(_ current: TimeInterval, _ end: TimeInterval) -> Observable<Mutation> {
        return .just(.setCountdown(Int(ceil(end - current))))
    }
    
    // MARK: - time set action method
    private func actionTimeSetStateChanged(_ state: TimeSet.State) -> Observable<Mutation> {
        let setTimeSetState: Observable<Mutation> = .just(.setTimeSetState(state))
        
        switch state {
        case .run:
            let setExtraTime: Observable<Mutation> = .just(.setExtraTime(timeSet.item.timers.reduce(0) { $0 + $1.extra }))
            
            if timeSetService.runningTimeSet == nil {
                // Set running time set only first time
                timeSetService.runningTimeSet = RunningTimeSet(
                    timeSet: timeSet,
                    origin: origin,
                    canSave: currentState.canTimeSetSave
                )
            }
            
            return .concat(setTimeSetState, setExtraTime)
            
        case .end:
            timeSetService.runningTimeSet = nil
            
            switch timeSet.history.endState {
            case .normal,
                 .cancel:
                return historyService.createHistory(timeSet.history)
                    .asObservable()
                    .flatMap { _ in setTimeSetState }
                
            case .overtime:
                return historyService.updateHistory(timeSet.history)
                    .asObservable()
                    .flatMap { _ in setTimeSetState }
                
            default:
                break
            }
            
        default:
            break
        }
        
        return setTimeSetState
    }
    
    private func actionTimeSetTimerChanged(_ timer: JSTimer, at index: Int) -> Observable<Mutation> {
        // Calculate remained time
        remainedTime = timeSet.item.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.end }
        
        let selectTimer: Observable<Mutation> = actionSelectTimer(at: index)
        let setRemainedTime: Observable<Mutation> = .just(.setRemainedTime(remainedTime + timer.item.end))
        let timerEvent: Observable<Mutation> = timer.event
            .flatMap { [weak self] in self?.mutate(timerEvent: $0) ?? .empty() }
        
        return .concat(selectTimer, setRemainedTime, timerEvent)
    }
    
    private func actionTimeSetTimeChanged(_ current: TimeInterval, _ end: TimeInterval) -> Observable<Mutation> {
        let setTime: Observable<Mutation> = .just(.setTime(abs(end - floor(current))))
        let setRemainedTime: Observable<Mutation> = .just(.setRemainedTime(remainedTime + end - current))
        
        return .concat(setTime, setRemainedTime)
    }
    
    // MARK: - timer action method
    private func actionTimerStateChanged(_ state: JSTimer.State) -> Observable<Mutation> {
        return .just(.setTimerState(state))
    }
    
    deinit {
        Logger.verbose()
    }
}
