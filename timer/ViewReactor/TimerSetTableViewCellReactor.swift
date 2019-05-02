//
//  TimerSetTableViewCellReactor.swift
//  timer
//
//  Created by JSilver on 02/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class TimerSetTableViewCellReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let name: String
        let state: TimerInfo.State
    }
    
    // MARK: properties
    var initialState: State
    private let timerSet: TimerSet
    
    init(timerSet: TimerSet) {
        self.timerSet = timerSet
        initialState = State(name: timerSet.info.name, state: timerSet.info.state)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}
