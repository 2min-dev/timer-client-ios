//
//  NoticeListViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class NoticeListViewReactor: Reactor {
    enum Action {
        /// Load notice list to refresh
        case refresh
    }
    
    enum Mutation {
        /// Set countdown menu sections
        case setSections([NoticeListSectionModel])
        
        /// Set loading flag
        case setLoading(Bool)
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Countdown menu sections
        var sections: [NoticeListSectionModel]
        
        /// Is loading to process
        var isLoading: Bool
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let networkService: NetworkServiceProtocol
    
    // MARK: - constructor
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        initialState = State(sections: [], isLoading: true, shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return actionRefresh()
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
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let requestNoticeList: Observable<Mutation> = networkService.requestNoticeList().asObservable()
            .flatMap { notices -> Observable<Mutation> in
                let setSections: Observable<Mutation> = .just(.setSections([NoticeListSectionModel(model: Void(), items: notices)]))
                let sectionReload: Observable<Mutation> = .just(.sectionReload)
                
                return .concat(setSections, sectionReload)
        }
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        return .concat(startLoading, requestNoticeList, endLoading)
    }
    
    deinit {
        Logger.verbose()
    }
}
