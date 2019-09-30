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
        /// Update repeat state
        case updateRepeat(Bool)
        
        /// Enable  badge
        case updateEnabled(Bool)
    }
    
    enum Mutation {
        /// Set repeat state
        case setRepeat(Bool)
        
        /// Set enabled state
        case setEnabled(Bool)
    }
    
    struct State {
        /// Is repeat
        var isRepeat: Bool
        
        /// Is enabled
        var isEnabled: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    init(isRepeat: Bool = false, isEnabled: Bool = false) {
        initialState = State(isRepeat: isRepeat, isEnabled: isEnabled)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateRepeat(isRepeat):
            return .just(.setRepeat(isRepeat))
            
        case let .updateEnabled(isEnabled):
            return .just(.setEnabled(isEnabled))
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRepeat(isRepeat):
            state.isRepeat = isRepeat
            return state
            
        case let .setEnabled(isEnabled):
            state.isEnabled = isEnabled
            return state
        }
    }
}
