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
        case updateIndex(Int)
        case updateTime(TimeInterval)
        case select(Bool)
        case updateOptionVisible(Bool)
    }
    
    enum Mutation {
        case setIndex(Int)
        case setTime(TimeInterval)
        case setSelected(Bool)
        case setIsOptionVisible(Bool)
        
    }
    
    struct State {
        var index: Int
        var time: TimeInterval
        var isSelected: Bool
        var isOptionVisible: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    init(info: TimerInfo, index: Int, isSelected: Bool = false, isOptionVisible: Bool = true) {
        self.initialState = State(index: index, time: info.endTime, isSelected: isSelected, isOptionVisible: isOptionVisible)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateIndex(index):
            return .just(.setIndex(index))
        case let .updateTime(time):
            return .just(.setTime(time))
        case let .select(isSelected):
            return .just(.setSelected(isSelected))
        case let .updateOptionVisible(isOptionVisible):
            return .just(.setIsOptionVisible(isOptionVisible))
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
        case let .setIsOptionVisible(isOptionVisible):
            state.isOptionVisible = isOptionVisible
            return state
        }
    }
}
