//
//  IntroViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class IntroViewReactor: Reactor {
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case introDone
    }
    
    struct State {
        var isDone: Bool
    }
    
    // MARK: properties
    var initialState: IntroViewReactor.State
    
    init() {
        self.initialState = State(isDone: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.just(Mutation.introDone).delay(.seconds(3), scheduler: MainScheduler.instance)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .introDone:
            state.isDone = true
        }
        
        return state
    }
}
