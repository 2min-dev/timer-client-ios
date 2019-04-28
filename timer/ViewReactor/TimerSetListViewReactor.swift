//
//  TimerSetViewReactor.swift
//  timerset-ios
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
        case setTimerSets([TimerSet])
    }
    
    struct State {
        var timerSets: [TimerSet]
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    
    init(timerService: TimerSetServicePorotocol) {
        self.initialState = State(timerSets: [])
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
        case let .setTimerSets(timerSets):
            state.timerSets = timerSets
            return state
        }
    }
}
