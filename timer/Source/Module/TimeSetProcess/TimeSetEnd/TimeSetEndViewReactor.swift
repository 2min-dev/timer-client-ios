//
//  TimeSetEndViewReactor.swift
//  timer
//
//  Created by JSilver on 22/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetEndViewReactor: Reactor {
    enum Action {
        /// Update memo of current time set
        case updateMemo(String)
    }
    
    enum Mutation {
        /// Set memo of time set
        case setMemo(String)
    }
    
    struct State {
        /// Title of time set
        let title: String
        
        /// Memo of time set
        var memo: String
    }
    
    // MARK: - properties
    var initialState: State
    
    private let timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        self.timeSetInfo = timeSetInfo
        initialState = State(title: timeSetInfo.title,
                             memo: timeSetInfo.memo)
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateMemo(memo):
            return actionUpdateMemo(memo)
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setMemo(memo):
            state.memo = memo
            return state
        }
    }
    
    // MARK: - action method
    private func actionUpdateMemo(_ memo: String) -> Observable<Mutation> {
        // Update time set's memo
        timeSetInfo.memo = memo
        return .just(.setMemo(memo))
    }
    
    deinit {
        Logger.verbose()
    }
}
