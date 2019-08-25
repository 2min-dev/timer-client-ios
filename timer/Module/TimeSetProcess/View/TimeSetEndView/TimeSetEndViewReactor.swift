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
    // MARK:- Constants
    static let MAX_MEMO_LENGTH = 1000
    
    enum Action {
        case updateMemo(String)
    }
    
    enum Mutation {
        /// Set memo of time set
        case setMemo(String)
    }
    
    struct State {
        /// Title of time set
        let title: String
        
        /// Running time of time set
        let runningTime: TimeInterval
        
        /// Ended timer index of time set
        let endIndex: Int
        
        /// All count of timers of time set
        let timerCount: Int
        
        /// Repeat count of time set
        let repeatCount: Int
        
        /// Memo of time set
        var memo: String
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSet: TimeSet
    
    // MARK: - constructor
    init(timeSet: TimeSet) {
        self.timeSet = timeSet
        self.initialState = State(title: timeSet.info.title,
                                  runningTime: timeSet.info.runningTime,
                                  endIndex: timeSet.currentIndex,
                                  timerCount: timeSet.info.timers.count,
                                  repeatCount: timeSet.info.repeatCount,
                                  memo: timeSet.info.memo)
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
        // Update timer's comment
        let length = memo.lengthOfBytes(using: .utf16)
        
        guard length <= TimeSetEndViewReactor.MAX_MEMO_LENGTH else {
            return .just(.setMemo(timeSet.info.memo))
        }
        
        timeSet.info.memo = memo
        
        return .just(.setMemo(memo))
    }
    
    deinit {
        Logger.verbose()
    }
}
