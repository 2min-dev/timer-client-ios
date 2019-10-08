//
//  MainViewReactor.swift
//  timer
//
//  Created by JSilver on 03/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class MainViewReactor: Reactor {
    enum Action {
        /// Get running time set from time set service when view will appear
        case viewWillAppear
    }
    
    enum Mutation {
        /// Set running time set
        case setRunningTimeSet(TimeSet?)
    }
    
    struct State {
        /// Current running time set
        var runningTimeSet: TimeSet?
    }
    
    // MARK: - properties
    var initialState: State
    private var timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol) {
        self.timeSetService = timeSetService
        self.initialState = State()
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
        }
    }
    
    func mutate(timeSetEvent: TimeSetEvent) -> Observable<Mutation> {
        switch timeSetEvent {
        case let .timeSetChanged(timeSet):
            return actionTimeSetChanged(timeSet)
            
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
        
        switch mutation {
        case let .setRunningTimeSet(timeSet):
            state.runningTimeSet = timeSet
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        return .just(.setRunningTimeSet(timeSetService.runningTimeSet))
    }
    
    // MARK: - time set service action method
    private func actionTimeSetChanged(_ timeSet: TimeSet?) -> Observable<Mutation> {
        return .just(.setRunningTimeSet(timeSet))
    }
    
    deinit {
        Logger.verbose()
    }
}
