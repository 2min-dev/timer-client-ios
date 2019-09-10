//
//  TimeSetManageViewReactor.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetManageViewReactor: Reactor {
    enum TimeSetType: Int {
        case saved
        case bookmarked
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetService: TimeSetServiceProtocol
    var type: TimeSetType
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        self.type = type
        
        self.initialState = State()
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
    // MARK: - action method
    // MARK: - priate method
    // MARK: - public method
}
