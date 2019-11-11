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
        case setPreviousTimeSetEndState(History.EndState?)
        
        case timeSetEnded
    }
    
    struct State {
        var previousTimeSetEndState: History.EndState?
        
        var didTimeSetEnded: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private var timeSetService: TimeSetServiceProtocol
    
    var previousTimeSet: TimeSetItem?
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol) {
        self.timeSetService = timeSetService
        initialState = State(didTimeSetEnded: false)
    }
    
    // MARK: - mutation
    func mutate(timeSetEvent: TimeSetEvent) -> Observable<Mutation> {
        switch timeSetEvent {
        case let .ended(endState, timeSetItem):
            return actionTimeSetEnded(endState, item: timeSetItem)
            
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
        case let .setPreviousTimeSetEndState(endState):
            state.previousTimeSetEndState = endState
            return state
            
        case .timeSetEnded:
            state.didTimeSetEnded = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionTimeSetEnded(_ endState: History.EndState, item: TimeSetItem) -> Observable<Mutation> {
        previousTimeSet = item
        
        var setPreviousTimeSetEndState: Observable<Mutation> = .just(.setPreviousTimeSetEndState(nil))
        switch endState {
        case .cancel,
             .overtime:
            setPreviousTimeSetEndState = .just(.setPreviousTimeSetEndState(endState))
            
        default:
            break
        }
        
        return .concat(
            setPreviousTimeSetEndState,
            .just(.timeSetEnded)
        )
    }
    
    deinit {
        Logger.verbose()
    }
}
