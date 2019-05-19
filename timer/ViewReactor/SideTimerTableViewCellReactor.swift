//
//  SideTimerTableViewCellReactor.swift
//  timer
//
//  Created by JSilver on 08/05/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class SideTimerTableViewCellReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let time: TimeInterval
    }
    
    // MARK: - properties
    var initialState: State
    private var info: TimerInfo
    
    init(info: TimerInfo) {
        self.info = info
        self.initialState = State(time: info.endTime)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}
