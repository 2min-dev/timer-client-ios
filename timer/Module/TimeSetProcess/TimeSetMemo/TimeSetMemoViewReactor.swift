//
//  TimeSetMemoViewReactor.swift
//  timer
//
//  Created by JSilver on 25/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetMemoViewReactor: Reactor {
    // MARK: - Constants
    static let MAX_MEMO_LENGTH = 1000
    
    enum Action {
        /// Update memo of current time set
        case updateMemo(String)
    }
    
    enum Mutation {
        /// Set memo of time set
        case setMemo(String)
        
        /// Set remainted time of time set
        case setRemainedTime(TimeInterval)
    }
    
    struct State {
        /// Title of time set
        let title: String
        
        /// Remained time of time set
        var remainedTime: TimeInterval
        
        /// Memo of time set
        var memo: String
    }
    
    // MARK: - properties
    var initialState: State
    
    private let timeSet: TimeSet
    private var remainedTime: TimeInterval
    
    // MARK: - constructor
    init(timeSet: TimeSet) {
        self.timeSet = timeSet

        let index = self.timeSet.currentIndex
        self.remainedTime = self.timeSet.info.timers.enumerated()
            .filter { $0.offset > index }
            .reduce(0) { $0 + $1.element.endTime }
        
        let timer = self.timeSet.info.timers[index]
        let remainedTime = self.remainedTime + (timer.endTime + timer.extraTime - timer.currentTime)
        
        self.initialState = State(title: self.timeSet.info.title,
                                  remainedTime: remainedTime,
                                  memo: self.timeSet.info.memo)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateMemo(memo):
            return actionUpdateMemo(memo)
        }
    }
    
    func mutate(timeSetEvent: TimeSet.Event) -> Observable<Mutation> {
        switch timeSetEvent {
        case let .timerChanged(timer, at: index):
            return actionTimeSetTimerChanged(timer, at: index)
            
        case let .timeChanged(current: currentTime, end: endTime):
            return actionTimeSetTimeChanged(current: currentTime, end: endTime)
            
        default:
            return .empty()
        }
    }
    
    func transform(mutation: Observable<TimeSetMemoViewReactor.Mutation>) -> Observable<TimeSetMemoViewReactor.Mutation> {
        let timeSetEventMutation = timeSet.event
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        return .merge(mutation, timeSetEventMutation)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setMemo(memo):
            state.memo = memo
            return state
            
        case let .setRemainedTime(remainedTime):
            state.remainedTime = remainedTime
            return state
        }
    }
    
    // MARK: - action method
    private func actionUpdateMemo(_ memo: String) -> Observable<Mutation> {
        // Update time set's memo
        let length = memo.lengthOfBytes(using: .utf16)
        
        guard length <= TimeSetMemoViewReactor.MAX_MEMO_LENGTH else {
            return .just(.setMemo(timeSet.info.memo))
        }
        
        timeSet.info.memo = memo
        
        return .just(.setMemo(memo))
    }
    
    private func actionTimeSetTimerChanged(_ timer: TimerInfo, at index: Int) -> Observable<Mutation> {
       // Calculate remained time
       remainedTime = timeSet.info.timers.enumerated()
           .filter { $0.offset > index }
           .reduce(0) { $0 + $1.element.endTime }
       
       return .just(.setRemainedTime(remainedTime + timer.endTime))
   }
   
   private func actionTimeSetTimeChanged(current: TimeInterval, end: TimeInterval) -> Observable<Mutation> {
       return .just(.setRemainedTime(remainedTime + (end - floor(current))))
   }
}
