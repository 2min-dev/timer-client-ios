//
//  TimerBadgeRepeatCellReactor.swift
//  timer
//
//  Created by JSilver on 25/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimerBadgeRepeatCellReactor: Reactor {
    enum Action {
        /// Time set changed
        case timeSetChanged(TimeSetItem)
        
        /// Toggle repeat state
        case toggleRepeat
    }
    
    enum Mutation {
        /// Set repeat state
        case setRepeat(Bool)
    }
    
    struct State {
        /// Is repeat
        var isRepeat: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private var timeSetItem: TimeSetItem
    
    init(timeSetItem: TimeSetItem) {
        self.timeSetItem = timeSetItem
        
        initialState = State(isRepeat: timeSetItem.isRepeat)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .timeSetChanged(timeSetItem):
            return actionTimeSetChanged(timeSetItem)
            
        case .toggleRepeat:
            return actionToggleRepeat()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setRepeat(isRepeat):
            state.isRepeat = isRepeat
            return state
        }
    }
    
    // MARK: - action method
    private func actionTimeSetChanged(_ timeSetItem: TimeSetItem) -> Observable<Mutation> {
        self.timeSetItem = timeSetItem
        return .just(.setRepeat(timeSetItem.isRepeat))
    }
    
    private func actionToggleRepeat() -> Observable<Mutation> {
        timeSetItem.isRepeat.toggle()
        return .just(.setRepeat(timeSetItem.isRepeat))
    }
}
