//
//  ProductivityTimerCollectionViewCellReactor.swift
//  timer
//
//  Created by JSilver on 08/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class ProductivityTimerCollectionViewCellReactor: Reactor {
    enum Action {
        case updateTime(TimeInterval)
        case select(Bool)
    }
    
    enum Mutation {
        case setTime(TimeInterval)
        case setSelected(Bool)
    }
    
    struct State {
        var time: TimeInterval
        let index: Int
        var selected: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private var info: TimerInfo
    
    init(info: TimerInfo, index: Int, selected: Bool) {
        self.info = info
        self.initialState = State(time: info.endTime, index: index, selected: selected)
    }
    
    convenience init(info: TimerInfo, index: Int) {
        self.init(info: info, index: index, selected: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTime(time):
            // Update timer info
            info.endTime = time
            return .just(.setTime(time))
        case let .select(isSelected):
            return .just(.setSelected(isSelected))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
        case let .setSelected(isSelected):
            state.selected = isSelected
            return state
        }
    }
}
