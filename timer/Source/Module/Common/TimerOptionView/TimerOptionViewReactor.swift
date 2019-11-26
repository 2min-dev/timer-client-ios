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
        /// Update timer item
        case updateTimer(TimerItem, at: Int)
        
        /// Update comment of the timer
        case updateComment(String)
        
        /// Update alarm of the timer
        case updateAlarm(Alarm)
    }
    
    enum Mutation {
        /// Set title of the timer
        case setIndex(Int)
        
        /// Set comment of the timer
        case setComment(String)
        
        /// Set alarm of the ttimer
        case setAlarm(Alarm)
    }
    
    struct State {
        /// Index of timer
        var index: Int = 0
        
        /// Comment of the timer
        var comment: String = ""
        
        /// Alarm of the timer
        var alarm: Alarm = .default
    }
    
    // MARK: - properties
    var initialState: State = State()
    private var timerItem: TimerItem?
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTimer(timerItem, at: index):
            return actionUpdateTimer(item: timerItem, at: index)
            
        case let .updateComment(comment):
            return actionUpdateComment(comment)
            
        case let .updateAlarm(alarm):
            return actionUpdateAlarm(alarm)
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
            
        case let .setAlarm(alarm):
            state.alarm = alarm
            return state
        }
    }
    
    // MARK: - action method
    private func actionUpdateTimer(item: TimerItem, at index: Int) -> Observable<Mutation> {
        // Change current timer
        timerItem = item
        
        return .concat(.just(.setComment(item.comment)),
                       .just(.setAlarm(item.alarm)),
                       .just(.setIndex(index)))
    }
    
    private func actionUpdateComment(_ comment: String) -> Observable<Mutation> {
        guard let timerItem = timerItem else { return .empty() }
        // Update timer comment
        timerItem.comment = comment
        
        return .just(.setComment(comment))
    }
    
    private func actionUpdateAlarm(_ alarm: Alarm) -> Observable<Mutation> {
        guard let timerItem = timerItem else { return .empty() }
        // Update timer alarm
        timerItem.alarm = alarm
        
        return .just(.setAlarm(alarm))
    }
    
    deinit {
        Logger.verbose()
    }
}
