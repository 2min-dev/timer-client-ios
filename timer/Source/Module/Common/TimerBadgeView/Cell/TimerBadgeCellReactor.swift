//
//  TimerBadgeCollectionViewReactor.swift
//  timer
//
//  Created by JSilver on 08/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

class TimerBadgeCellReactor: Reactor {
    enum Action {
        /// Update badge index
        case updateIndex(Int)
        
        /// Update timer list count
        case updateCount(Int)
        
        /// Update badge time
        case updateTime(TimeInterval)
        
        /// Select badge
        case select(Bool)
    }
    
    enum Mutation {
        /// Set badge index
        case setIndex(Int)
        
        /// Set timer list count
        case setCount(Int)
        
        /// Set badge time
        case setTime(TimeInterval)
        
        /// Set badge is selected
        case setSelected(Bool)
    }
    
    struct State {
        /// Index of badge
        var index: Int
        
        /// Count of timer list
        var count: Int
        
        /// time of timer
        var time: TimeInterval
        
        /// Selected state of badge
        var isSelected: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    let id: Int
    
    init(id: Int = 0, time: TimeInterval = 0, index: Int = 0, count: Int = 1, isSelected: Bool = false) {
        self.id = id
        
        initialState = State(
            index: index,
            count: count,
            time: time,
            isSelected: isSelected
        )
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateIndex(index):
            return .just(.setIndex(index))
            
        case let .updateCount(count):
            return .just(.setCount(count))
            
        case let .updateTime(time):
            return .just(.setTime(time))
            
        case let .select(isSelected):
            return .just(.setSelected(isSelected))
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setIndex(index):
            state.index = index
            return state
            
        case let .setCount(count):
            state.count = count
            return state
            
        case let .setTime(time):
            state.time = time
            return state
            
        case let .setSelected(isSelected):
            state.isSelected = isSelected
            return state
        }
    }
}
