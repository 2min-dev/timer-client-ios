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
        case touchStateButton
    }
    
    enum Mutation {
        case setState(TimerInfo.State)
        case setStateChanging(Bool)
    }
    
    struct State {
        var name: String
        var state: TimerInfo.State
        var count: Int
        
        var stateChanging: Bool
    }
    
    // MARK: properties
    var initialState: State
    private let timeSet: TimeSet
    
    init(timeSet: TimeSet) {
        self.timeSet = timeSet
        initialState = State(name: timeSet.info.name, state: timeSet.info.state, count: timeSet.info.timers.count, stateChanging: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .touchStateButton:
            let timeSetOperator = Observable<Mutation>.empty()
                .do(onCompleted: {
                    switch self.currentState.state {
                    case .stop:
                        fallthrough
                    case .pause:
                        self.timeSet.startTimerSet()
                    case .start:
                        self.timeSet.pauseTimerSet()
                    case .end:
                        self.timeSet.stopTimerSet()
                    }
                })
            
            return Observable.concat(Observable.just(Mutation.setStateChanging(true)), timeSetOperator)
        }
    }
    
    func mutate(event: TimeSet.Event) -> Observable<Mutation> {
        switch event {
        case let .changeState(state):
            return Observable.concat(Observable.just(Mutation.setState(state)), Observable.just(Mutation.setStateChanging(false)))
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge(mutation, timeSet.event.flatMap { self.mutate(event: $0) })
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setState(timeSetState):
            state.state = timeSetState
            return state
        case let .setStateChanging(stateChanging):
            state.stateChanging = stateChanging
            return state
        }
    }
}
