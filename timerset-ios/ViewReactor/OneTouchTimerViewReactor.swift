//
//  OneTouchTimerViewReactor.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class OneTouchTimerViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerServicePorotocol
    
    init(timerService: TimerServicePorotocol) {
        self.initialState = State()
        self.timerService = timerService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}
