//
//  TimerSetViewReactor.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimerSetViewReactor: Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setTimerSet(TimerSet)
    }
    
    struct State {
        var timerSet: TimerSet?
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    
    init(timerService: TimerSetServicePorotocol) {
        self.initialState = State()
        self.timerService = timerService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return timerService.fetchTimerSet().map { Mutation.setTimerSet($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setTimerSet(timerSet):
            state.timerSet = timerSet
            return state
        }
    }
}
