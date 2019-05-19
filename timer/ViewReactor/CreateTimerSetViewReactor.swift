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
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}
