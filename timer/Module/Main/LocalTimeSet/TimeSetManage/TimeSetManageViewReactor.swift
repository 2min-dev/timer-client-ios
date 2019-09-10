//
//  TimeSetManageViewReactor.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetManageViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    // MARK: - properties
    var initialState: State
    
    // MARK: - constructor
    init() {
        self.initialState = State()
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    // MARK: - action method
    // MARK: - priate method
    // MARK: - public method
}
