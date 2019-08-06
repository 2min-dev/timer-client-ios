//
//  TimeSetDetailViewReactor.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetDetailViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    // MARK: - properties
    var initialState: State
    private var timeSet: TimeSet
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        timeSet = TimeSet(info: timeSetInfo)
        self.initialState = State()
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    // MARK: - priate method
    // MARK: - public method
}
