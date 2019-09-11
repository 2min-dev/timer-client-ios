//
//  TimeSetManageViewReactor.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RxDataSources

class TimeSetManageViewReactor: Reactor {
    enum TimeSetType: Int {
        case saved
        case bookmarked
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Title of header
        let type: TimeSetType
        
        /// The section list of time set list
        var sections: [TimeSetManageSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        
        self.initialState = State(type: type,
                                  sections: [TimeSetManageSectionModel(model: Void(), items: ["a", "b", "c", "d"]),
                                             TimeSetManageSectionModel(model: Void(), items: ["a", "b", "c", "d"])],
                                  shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    // MARK: - priate method
    // MARK: - public method
}
