//
//  HistoryDetailViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class HistoryDetailViewReactor: Reactor {
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
        initialState = State()
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    // MARK: - action method
    // MARK: - priate method
    // MARK: - public method
    
    deinit {
        Logger.verbose()
    }
}
