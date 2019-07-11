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
        case updateTime(TimeInterval)
        case select(Bool)
        
        case setoOtionVisible(Bool)
    }
    
    enum Mutation {
        case setTime(TimeInterval)
        case setSelected(Bool)
        case setIsOptionVisible(Bool)
    }
    
    struct State {
        let index: Int
        var time: TimeInterval
        var isSelected: Bool
        var isOptionVisible: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private var timerInfo: TimerInfo
    
    init(info: TimerInfo, index: Int, isSelected: Bool = false, isOptionVisible: Bool = true) {
        self.timerInfo = info
        self.initialState = State(index: index, time: info.endTime, isSelected: isSelected, isOptionVisible: isOptionVisible)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTime(time):
            // Update timer info
            timerInfo.endTime = time
            return .just(.setTime(time))
        case let .select(isSelected):
            return .just(.setSelected(isSelected))
        case let .setoOtionVisible(isOptionVisible):
            return .just(.setIsOptionVisible(isOptionVisible))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
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
