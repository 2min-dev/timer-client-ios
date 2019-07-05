//
//  TimerSetViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimerSetListViewReactor: Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setTimerSets([TimeSet])
    }
    
    struct State {
        var timeSets: [TimeSet]
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    
    init(timerService: TimerSetServicePorotocol) {
        self.initialState = State(timeSets: [])
        self.timerService = timerService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return timerService.fetchTimerSets().map { Mutation.setTimerSets($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setTimerSets(timeSets):
            state.timeSets = timeSets
            return state
        }
    }
}
