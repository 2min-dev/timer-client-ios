//
//  TimeSetProcessFloatingViewReactor.swift
//  timer
//
//  Created by JSilver on 02/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetProcessFloatingViewReactor: Reactor {
    enum Action {
        /// Start the time set
        case startTimeSet
        
        /// Pause the time set
        case pauseTimeSet
        
        /// Cancel the time set
        case stopTimeSet
    }
    
    enum Mutation {
        /// Set remainted time of time set
        case setRemainedTime(TimeInterval)
        
        /// Set current timer index of time set
        case setCurrentIndex(Int)
        
        /// Set repeat count of time set
        case setRepeatCount(Int)
        
        /// Set current state of time set
        case setTimeSetState(TimeSet.State)
    }
    
    struct State {
        /// Title of time set
        let title: String
        
        /// Remained time of time set
        var remainedTime: TimeInterval
        
        /// Current timer index of time set
        var currentIndex: Int
        
        /// Count of timers
        let count: Int
        
        /// Repeated count of time set
        var repeatCount: Int
        
        /// Current state of time set
        var timeSetState: TimeSet.State
    }
    
    // MARK: - properties
    var initialState: State
    
    private var timeSet: TimeSet // Running time set
    private var remainedTime: TimeInterval // Remained time that after executing timer of time set
    
    // MARK: - constructor
    init(timeSet: TimeSet) {
        self.timeSet = timeSet
        
        let index = timeSet.currentIndex
        self.remainedTime = timeSet.info.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.endTime }
        
        let timer = timeSet.info.timers[index]
        let remainedTime = self.remainedTime + (timer.endTime + timer.extraTime - timer.currentTime)
        
        self.initialState = State(title: self.timeSet.info.title,
                                  remainedTime: remainedTime,
                                  currentIndex: index,
                                  count: self.timeSet.info.timers.count,
                                  repeatCount: self.timeSet.info.repeatCount,
                                  timeSetState: self.timeSet.state)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startTimeSet:
            return actionStartTimeSet()
            
        case .pauseTimeSet:
            return actionPauseTimeSet()
            
        case .stopTimeSet:
            return actionStopTimeSet()
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
        let timeSetEventMutation = timeSet.event
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        return .merge(mutation, timeSetEventMutation)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setRemainedTime(time):
            state.remainedTime = time
            return state
            
        case let .setCurrentIndex(index):
            state.currentIndex = index
            return state
            
        case let .setRepeatCount(count):
            state.repeatCount = count
            return state
            
        case let .setTimeSetState(timeSetState):
            state.timeSetState = timeSetState
            return state
        }
    }
    
    // MARK: - action method
    private func actionStartTimeSet() -> Observable<Mutation> {
        timeSet.start()
        return .empty()
    }
    
    private func actionPauseTimeSet() -> Observable<Mutation> {
        timeSet.pause()
        return .empty()
    }
    
    private func actionStopTimeSet() -> Observable<Mutation> {
        timeSet.stop()
        return .empty()
    }
    
    // MARK: - Time set action method
    private func actionTimeSetStateChanged(_ state: TimeSet.State) -> Observable<Mutation> {
        let setTimeSetState: Observable<Mutation> = .just(.setTimeSetState(state))
        var setRepeatCount: Observable<Mutation> = .empty()
        
        switch state {
        case .initialize:
            setRepeatCount = .just(.setRepeatCount(0))
            
        case let .stop(repeat: count):
            setRepeatCount = .just(.setRepeatCount(count))
            
        default:
            break
        }
        
        return .concat(setTimeSetState, setRepeatCount)
    }
    
    private func actionTimeSetTimerChanged(_ timer: TimerInfo, at index: Int) -> Observable<Mutation> {
        // Calculate remained time
        remainedTime = timeSet.info.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.endTime }
        
        return .concat(.just(.setCurrentIndex(index)),
                       .just(.setRemainedTime(remainedTime + timer.endTime)))
    }
    
    private func actionTimeSetTimeChanged(current: TimeInterval, end: TimeInterval) -> Observable<Mutation> {
        return .just(.setRemainedTime(abs(remainedTime + (end - floor(current)))))
    }
}
