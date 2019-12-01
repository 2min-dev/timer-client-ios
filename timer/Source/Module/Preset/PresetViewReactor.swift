//
//  PresetViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/11/30.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RxDataSources

// MARK: - local time set datasource
typealias PresetSectionModel = SectionModel<Void, TimeSetCollectionViewCellReactor>

class PresetDataSource {
    var items: [TimeSetItem]?
    
    func makeSections() -> [PresetSectionModel] {
        guard let items = items else { return [] }
        
        let reactors = items.map { TimeSetCollectionViewCellReactor(timeSetItem: $0) }
        return [PresetSectionModel(model: Void(), items: reactors)]
    }
}

class PresetViewReactor: Reactor {
    enum Action {
        /// Fetch preset list from server
        case refresh
    }
    
    enum Mutation {
        /// Set loading flag
        case setLoading(Bool)
        
        /// Set error
        case setError(Error)
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Data source of preset list
        var dataSource: PresetDataSource
        
        /// The section list of preset list
        var sections: [PresetSectionModel] {
            dataSource.makeSections()
        }
        
        /// Is loading to process
        var isLoading: Bool
        
        /// Any error state
        var error: RevisionValue<Error?>
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    private let networkService: NetworkServiceProtocol
    
    // MARK: - constructor
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        
        initialState = State(
            dataSource: PresetDataSource(),
            isLoading: false,
            error: RevisionValue(nil),
            shouldSectionReload: true
        )
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
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
            
        case let .setError(error):
            state.error = state.error.next(error)
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        let state = currentState
        // Request only preset never fetched
        guard state.dataSource.items == nil else { return .empty() }
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        // Request preset list from server
        let requestPresets: Observable<Mutation> = networkService.requestPresets().asObservable()
            .do(onNext: { state.dataSource.items = $0 })    // Set preset list to data source
            .map { _ in .sectionReload }                    // Section reload
            .catchError { .just(.setError($0)) }            // Set error when any error occured
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        return .concat(startLoading, requestPresets, endLoading)
    }
    
    deinit {
        Logger.verbose()
    }
}
