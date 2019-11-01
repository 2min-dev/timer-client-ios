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
        /// Update history when view will dissppaer
        case viewWillDisappear
        
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
        
        /// Started date of the time set
        let startDate: Date
        
        /// Ended date of the time set
        let endDate: Date
        
        /// Memo of time set
        var memo: String
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    private let history: History
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, history: History) {
        self.timeSetService = timeSetService
        self.history = history
        initialState = State(title: history.item?.title ?? "",
                             startDate: history.startDate ?? Date(),
                             endDate: history.endDate ?? Date(),
                             memo: history.item?.memo ?? "")
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillDisappear:
            return actionViewWillDisappear()
            
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
    private func actionViewWillDisappear() -> Observable<Mutation> {
        _ = timeSetService.updateHistory(history).subscribe()
        return .empty()
    }
    
    private func actionUpdateMemo(_ memo: String) -> Observable<Mutation> {
        // Update time set's memo
        history.item?.memo = memo
        return .just(.setMemo(memo))
    }
    
    deinit {
        Logger.verbose()
    }
}
