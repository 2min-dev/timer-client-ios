//
//  MainViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/11/11.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class MainViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        case setPreviousHistory(History)
        
        case timeSetEnded
    }
    
    struct State {
        var didTimeSetEnded: Bool

        var previousHistory: History?
    }
    
    // MARK: - properties
    var initialState: State
    private var timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol) {
        self.timeSetService = timeSetService
        initialState = State(didTimeSetEnded: false)
    }
    
    // MARK: - mutation
    func mutate(timeSetEvent: TimeSetEvent) -> Observable<Mutation> {
        switch timeSetEvent {
        case let .ended(history):
            return actionTimeSetEnded(history: history)
            
        default:
            return .empty()
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let timeSetEventMutation = timeSetService.event
            .flatMap { [weak self] in self?.mutate(timeSetEvent: $0) ?? .empty() }
        
        return .merge(mutation, timeSetEventMutation)
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.didTimeSetEnded = false
        
        switch mutation {
        case let .setPreviousHistory(history):
            state.previousHistory = history
            return state
            
        case .timeSetEnded:
            state.didTimeSetEnded = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionTimeSetEnded(history: History) -> Observable<Mutation> {
        return .concat(
            .just(.setPreviousHistory(history)),
            .just(.timeSetEnded)
        )
    }
    
    deinit {
        Logger.verbose()
    }
}
