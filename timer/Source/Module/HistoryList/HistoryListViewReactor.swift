//
//  HistoryListViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class HistoryListViewReactor: Reactor {
    enum Action {
        /// Fetch history list when view will appear
        case viewWillAppear
    }
    
    enum Mutation {
        /// Set menu sections
        case setSections([HistorySectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// History sections
        var sections: [HistorySectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol) {
        self.timeSetService = timeSetService
        initialState = State(sections: [],
                             shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setSections(sections):
            state.sections = sections
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        // TODO: fetch time set history
//        let items: [History] = timeSetService.fetchHistory()
        
        let setSections: Observable<Mutation> = .just(.setSections([HistorySectionModel(model: Void(), items: [HistoryListCollectionViewCellReactor()])]))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSections, sectionReload)
    }
    
    deinit {
        Logger.verbose()
    }
}
