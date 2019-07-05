//
//  CreateTimerSetViewReactor.swift
//  timer
//
//  Created by JSilver on 19/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class CreateTimerSetViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    // MARK: - properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    private let timerSet: TimerSet
    
    init(timerService: TimerSetServicePorotocol, timerSet: TimerSet) {
        self.initialState = State()
        self.timerService = timerService
        self.timerSet = timerSet
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}
