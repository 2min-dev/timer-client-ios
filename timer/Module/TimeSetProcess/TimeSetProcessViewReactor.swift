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
    
    /// Countdown timer state
    enum CountdownState {
        case stop
        case run
        case pause
        case done
    }
    
    enum Action {
        /// Start the time set after countdown when view will appear
        case viewWillAppear
        
        /// Toggle the time set bookmark
        case toggleBookmark
        
        /// Toggle the time set repeat option
        case toggleRepeat
        
        /// Start the time set
        case startTimeSet(at: Int?)
        
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
        
        /// Set time set bookmark
        case setBookmark(Bool)
        
        /// Set time set is repeat
        case setRepeat(Bool)
        
        /// Add extra time into current timer
        case setExtraTime(TimeInterval)
        
        /// Set countdown seconds
        case setCountdown(Int)
        
        /// Set current countdown state
        case setCountdownState(CountdownState)
        
        /// Set current state of time set
        case setTimeSetState(TimeSet.State)
        
        /// Set current timer
        case setTimer(TimerInfo)
        
        /// Set current selected index path
        case setSelectedIndexPath(at: IndexPath)
        
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
        
        /// Bookmark setting value of time set
        var isBookmark: Bool
        
        /// Repeat setting value of time set
        var isRepeat: Bool
        
        /// Sum of all added extra time
        var extraTime: TimeInterval
        
        /// Countdown before time set start
        var countdown: Int
        
        /// Current countdown state
        var countdownState: CountdownState
        
        /// Current state of time st
        var timeSetState: TimeSet.State
        
        /// All timers info of time set
        let timers: [TimerInfo]
        
        /// Current running timer info
        var timer: TimerInfo
        
        /// Index path of current selected timer
        var selectedIndexPath: IndexPath
        
        /// Flag that represent need to section reload
        var shouldSectionReload: Bool
        
        /// Flag that view should dismiss
        var shouldDismiss: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServicePorotocol
    private var timeSetService: TimeSetServiceProtocol
    
    let timeSetInfo: TimeSetInfo? // Original time set info
    let timeSet: TimeSet // Running time set
    private var remainedTime: TimeInterval // Remained time that after executing timer of time set
    
    // Countdown
    private var countdown: TimeInterval // Current countdown time
    private var disposableTimer: Disposable? // Countdown disposable timer
    
    // MARK: - constructor
    init?(appService: AppServicePorotocol,
          timeSetService: TimeSetServiceProtocol,
          timeSetInfo: TimeSetInfo? = nil,
          start index: Int) {
        self.appService = appService
        self.timeSetService = timeSetService
        
        if let timeSetInfo = timeSetInfo {
            // Start time set from passed time set info parameter
            // Create will run time set from original time set info
            self.timeSetInfo = timeSetInfo
            self.timeSet = TimeSet(info: timeSetInfo.copy() as! TimeSetInfo)
            
            // Set running time set inrto time set service
            self.timeSetService.setRunningTimeSet(self.timeSet, origin: timeSetInfo)
        } else {
            // Present running time set from time set service
            // Fetch running time set from time set service
            guard let timeSetInfo = timeSetService.runningTimeSetInfo,
                let timeSet = timeSetService.runningTimeSet else { return nil }
            self.timeSetInfo = timeSetInfo
            self.timeSet = timeSet
        }
        
        // Get initial state
        let timer = self.timeSet.info.timers[index]
        let allTime = self.timeSet.info.timers.reduce(0) { $0 + $1.endTime }
        
        self.remainedTime = self.timeSet.info.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.endTime }
        let remainedTime = self.remainedTime + (timer.endTime + timer.extraTime - timer.currentTime)
        let extraTime = self.timeSet.info.timers.reduce(0) { $0 + $1.extraTime }
        
        self.countdown = self.timeSet.state == .initialize ? TimeInterval(self.appService.getCountdown()) : 0
        
        self.initialState = State(title: self.timeSet.info.title,
                                  time: timer.endTime,
                                  allTime: allTime,
                                  remainedTime: remainedTime,
                                  isBookmark: self.timeSet.info.isBookmark,
                                  isRepeat: self.timeSet.info.isRepeat,
                                  extraTime: extraTime,
                                  countdown: Int(self.countdown),
                                  countdownState: self.timeSet.state == .initialize ? .stop : .done,
                                  timeSetState: self.timeSet.state,
                                  timers: self.timeSet.info.timers,
                                  timer: timer,
                                  selectedIndexPath: IndexPath(row: index, section: 0),
                                  shouldSectionReload: true,
                                  shouldDismiss: false)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()

        case .toggleBookmark:
            return actionToggleBookmark()
            
        case .toggleRepeat:
            return actionToggleRepeat()
            
        case let .startTimeSet(at: index):
            return actionStartTimeSet(at: index)
            
        case .pauseTimeSet:
            return actionPauseTimeSet()
            
        case .stopTimeSet:
            return actionStopTimeSet()

        case let .addExtraTime(timeInterval) :
            return actionAddExtraTime(timeInterval)
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
    
    func transform(mutation: Observable<TimeSetProcessViewReactor.Mutation>) -> Observable<TimeSetProcessViewReactor.Mutation> {
        let timeSetEventMutation = timeSet.event
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        return .merge(mutation, timeSetEventMutation)
    }
    
    // MARK: - Reduce
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
            
        case let .setBookmark(isBookmark):
            state.isBookmark = isBookmark
            return state
            
        case let .setRepeat(isRepeat):
            state.isRepeat = isRepeat
            return state
            
        case let .setExtraTime(extraTime):
            state.extraTime = extraTime
            return state
                
        case let .setCountdown(time):
            state.countdown = time
            return state
            
        case let .setCountdownState(countdownState):
            state.countdownState = countdownState
            return state
            
        case let .setTimeSetState(timeSetState):
            state.timeSetState = timeSetState
            return state
            
        case let .setTimer(timer):
            state.timer = timer
            return state
            
        case let .setSelectedIndexPath(at: indexPath):
            state.selectedIndexPath = indexPath
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
        guard timeSet.state == .initialize else { return .empty() }
        
        let index = currentState.selectedIndexPath.row
        return startCountdown()
            .do(onNext: {
                if case .setCountdownState(.done) = $0 {
                    self.timeSet.start(at: index)
                }
            })
    }
    
    private func actionToggleBookmark() -> Observable<Mutation> {
        guard let timeSetInfo = timeSetInfo else { return .empty() }
        // Toggle original time set bookmark
        timeSetInfo.isBookmark.toggle()
        return .just(.setBookmark(timeSetInfo.isBookmark))
    }
    
    private func actionToggleRepeat() -> Observable<Mutation> {
        // Toggle time set repeat option
        timeSet.info.isRepeat.toggle()
        return .just(.setRepeat(timeSet.info.isRepeat))
    }
    
    private func actionStartTimeSet(at index: Int?) -> Observable<Mutation> {
        let state = currentState
        
        if let index = index {
            guard index < timeSet.info.timers.count else { return .empty() }
            
            if timeSet.state != .initialize {
                // Ignore countdown if time set isn't init state
                countdown = 0
            }
            
            // Restart at index after reset
            timeSet.reset()
            
            let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(at: IndexPath(row: index, section: 0)))
            let setTimer: Observable<Mutation> = .just(.setTimer(timeSet.info.timers[index]))
            let setTime: Observable<Mutation> = .just(.setTime(timeSet.info.timers[index].endTime))
            let setExtraTime: Observable<Mutation> = .just(.setExtraTime(0))
            let startedCountdown: Observable<Mutation> = startCountdown(reset: countdown > 0)
                .do(onNext: {
                    if case .setCountdownState(.done) = $0 {
                        self.timeSet.start(at: index)
                    }
                })
            
            return .concat(setSelectedIndexPath, setTimer, setTime, setExtraTime, startedCountdown)
        } else {
            // Resume had been running time set or countdown
            if timeSet.state == .initialize {
                // Resume countdown
                return startCountdown()
                    .do(onNext: {
                        if case .setCountdownState(.done) = $0 {
                            self.timeSet.start(at: state.selectedIndexPath.row)
                        }
                    })
            } else {
                // Resume time set
                timeSet.start()
                return .empty()
            }
        }
    }
    
    private func actionPauseTimeSet() -> Observable<Mutation> {
        if timeSet.state == .initialize {
            // Pause countdown
            disposableTimer?.dispose()
            return .just(.setCountdownState(.pause))
        } else {
            // Pause time set
            timeSet.pause()
            return .empty()
        }
        
    }
    
    private func actionStopTimeSet() -> Observable<Mutation> {
        if timeSet.state == .initialize {
            // Dispose countdown & free time set
            disposableTimer?.dispose()
            timeSetService.setRunningTimeSet(nil, origin: nil)
            // Dismiss
            return .just(.dismiss)
        } else {
            // Cancel the time set
            timeSet.stop()
            return .empty()
        }
    }
    
    private func actionAddExtraTime(_ extraTime: TimeInterval) -> Observable<Mutation> {
        let state = currentState
        guard state.extraTime < TimeSetProcessViewReactor.MAX_EXTRA_TIME else { return .empty() }
        
        // Add extra time into current timer
        state.timer.extraTime += extraTime
        
        let setExtraTime: Observable<Mutation> = .just(.setExtraTime(state.extraTime + extraTime))
        let setTime: Observable<Mutation> = .just(.setTime(state.time + extraTime))
        let setRemainedTime: Observable<Mutation> = .just(.setRemainedTime(state.remainedTime + extraTime))
        
        return .concat(setExtraTime, setTime, setRemainedTime)
    }
    
    // MARK: - Time set action method
    private func actionTimeSetStateChanged(_ state: TimeSet.State) -> Observable<Mutation> {
        var setExtraTime: Observable<Mutation> = .empty()
        switch state {
        case .stop:
            setExtraTime = .just(.setExtraTime(0))
            
        case .end(detail: _):
            timeSetService.setRunningTimeSet(nil, origin: nil)
            
        default:
            break
        }
        
        return .concat(.just(.setTimeSetState(state)), setExtraTime)
    }

    private func actionTimeSetTimerChanged(_ timer: TimerInfo, at index: Int) -> Observable<Mutation> {
        // Calculate remained time
        remainedTime = timeSet.info.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.endTime }
        
        return .concat(.just(.setSelectedIndexPath(at: IndexPath(row: index, section: 0))),
                       .just(.setTimer(timer)),
                       .just(.setRemainedTime(remainedTime + timer.endTime)))
    }
    
    private func actionTimeSetTimeChanged(current: TimeInterval, end: TimeInterval) -> Observable<Mutation> {
        return .concat(.just(.setTime(end - floor(current))),
                       .just(.setRemainedTime(remainedTime + end - current)))
    }
    
    // MARK: - private method
    private func startCountdown(reset: Bool = false) -> Observable<Mutation> {
        if reset {
            countdown = TimeInterval(appService.getCountdown())
        }

        // Dispose countdown timer
        disposableTimer?.dispose()
        disposableTimer = nil
        
        return .create { emitter in
            guard self.countdown > 0 else {
                emitter.onNext(.setCountdown(0))
                emitter.onNext(.setCountdownState(.done))
                
                emitter.onCompleted()
                return Disposables.create()
            }
            
            var isCompleted = false
            
            // Emit countdown is running
            emitter.onNext(.setCountdownState(.run))
            
            // Create new interval stream
            self.disposableTimer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance)
                .map { _ -> Int in
                    self.countdown = max(self.countdown - 0.1, 0)
                    return Int(ceil(self.countdown))
                }
                .distinctUntilChanged()
                .subscribe(onNext: {
                    // Emit countdown
                    emitter.onNext(.setCountdown($0))
                    
                    if $0 == 0 {
                        // Emit countdown was done
                        emitter.onNext(.setCountdownState(.done))
                        emitter.onCompleted()
                        isCompleted = true

                        // Dispose countdown timer
                        self.disposableTimer?.dispose()
                        self.disposableTimer = nil
                    }
                }, onDisposed: {
                    if !isCompleted {
                        emitter.onCompleted()
                    }
                })
            
            return Disposables.create()
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
