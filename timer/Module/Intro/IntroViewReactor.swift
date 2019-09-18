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
        case done
    }
    
    struct State {
        var isDone: Bool
    }
    
    // MARK: properties
    var initialState: IntroViewReactor.State
    
    init() {
        self.initialState = State(isDone: false)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return actionViewDidLoad()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .done:
            state.isDone = true
        }
        
        return state
    }
    
    // MARK: - action method
    private func actionViewDidLoad() -> Observable<Mutation> {
        Logger.info("""
        app launched.
        - title(\(Constants.appTitle ?? ""))
        - version(\(Constants.appVersion ?? ""))
        - build(\(Constants.appBuild ?? ""))
        - device version(\(Constants.deviceModel))
        """)
        
        return Observable<Mutation>.just(.done).delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
