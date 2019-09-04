//
//  TimerBadgeCollectionViewReactor.swift
//  timer
//
//  Created by JSilver on 08/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimerBadgeCellReactor: Reactor {
    enum Action {
        /// Update badge index
        case updateIndex(Int)
        
        /// Update badge time
        case updateTime(TimeInterval)
        
        /// Select badge
        case select(Bool)
        
        /// Enable  badge
        case enable(Bool)
    }
    
    enum Mutation {
        /// Set badge index
        case setIndex(Int)
        
        /// Set badge time
        case setTime(TimeInterval)
        
        /// Set badge is selected
        case setSelected(Bool)
        
        /// Set badge is enabled
        case setEnabled(Bool)
    }
    
    struct State {
        /// Index of badge
        var index: Int
        
        /// time of timer
        var time: TimeInterval
        
        /// Enable state of badge
        var isEnabled: Bool
        
        /// Selected state of badge
        var isSelected: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    init(info: TimerInfo, index: Int, isEnabled: Bool = true, isSelected: Bool = false) {
        self.initialState = State(index: index,
                                  time: info.endTime,
                                  isEnabled: isEnabled,
                                  isSelected: isSelected)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateIndex(index):
            return .just(.setIndex(index))
            
        case let .updateTime(time):
            return .just(.setTime(time))
            
        case let .select(isSelected):
            return .just(.setSelected(isSelected))
            
        case let .enable(isEnabled):
            return .just(.setEnabled(isEnabled))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setIndex(index):
            state.index = index
            return state
            
        case let .setTime(time):
            state.time = time
            return state
            
        case let .setSelected(isSelected):
            state.isSelected = isSelected
            return state
            
        case let .setEnabled(isEnabled):
            state.isEnabled = isEnabled
            return state
        }
    }
}
