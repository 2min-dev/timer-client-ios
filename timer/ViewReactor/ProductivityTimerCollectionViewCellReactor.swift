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
        case select(Bool)
    }
    
    enum Mutation {
        case setSelected(Bool)
    }
    
    struct State {
        let time: TimeInterval
        let index: Int
        var selected: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private var info: TimerInfo
    
    init(info: TimerInfo, index: Int) {
        self.info = info
        self.initialState = State(time: info.endTime, index: index, selected: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .select(isSelected):
            return Observable.just(Mutation.setSelected(isSelected))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setSelected(isSelected):
            state.selected = isSelected
            return state
        }
    }
}
