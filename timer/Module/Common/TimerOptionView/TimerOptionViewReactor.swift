//
//  TimerOptionViewReactor.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimerOptionViewReactor: Reactor {
    enum Action {
        /// Update timer info
        case updateTimer(TimerInfo, at: Int)
        
        /// Update comment of timer
        case updateComment(String)
        
        // TODO: After alarm model design
        // case updateAlarm(String)
    }
    
    enum Mutation {
        /// Set title of timer
        case setIndex(Int)
        
        /// Set comment of timer
        case setComment(String)
        
        // TODO: After alarm model design
        // case setAlarm(String)
    }
    
    struct State {
        /// Index of timer
        var index: Int = 0
        
        /// Comment of the timer
        var comment: String = ""
        
        // TODO: After alarm model design
        // var alarm: String
    }
    
    // MARK: - properties
    var initialState: State = State()
    private var timerInfo: TimerInfo?
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTimer(timerInfo, at: index):
            return actionUpdateTimer(info: timerInfo, at: index)
            
        case let .updateComment(comment):
            return actionUpdateComment(comment)
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setIndex(index):
            state.index = index
            return state
            
        case let .setComment(comment):
            state.comment = comment
            return state
        }
    }
    
    // MARK: - action method
    private func actionUpdateTimer(info: TimerInfo, at index: Int) -> Observable<Mutation> {
        // Change current timer
        timerInfo = info
        
        return .concat(.just(.setComment(info.comment)),
                       .just(.setIndex(index)))
    }
    
    private func actionUpdateComment(_ comment: String) -> Observable<Mutation> {
        // Update timer's comment
        guard let timerInfo = timerInfo else { return .empty() }
        // Update timer comment
        timerInfo.comment = comment
        
        return .just(.setComment(comment))
    }
    
    deinit {
        Logger.verbose()
    }
}
