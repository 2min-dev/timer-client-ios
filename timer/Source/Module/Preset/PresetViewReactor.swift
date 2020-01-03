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

class PresetViewReactor: Reactor {
    enum Action {
        /// Fetch preset list from server
        case refresh
    }
    
    enum Mutation {
        /// Set preset sections
        case setSections([PresetSectionModel]?)
        
        /// Set loading flag
        case setLoading(Bool)
        
        /// Set error
        case setError(Error)
    }
    
    struct State {
        /// The section list of preset list
        var sections: RevisionValue<[PresetSectionModel]?>
        
        /// Is loading to process
        var isLoading: Bool
        
        /// Any error state
        var error: RevisionValue<Error?>
    }
    
    // MARK: - properties
    var initialState: State
    private let networkService: NetworkServiceProtocol

    private var dataSource: PresetSectionDataSource
    
    // MARK: - constructor
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        dataSource = PresetSectionDataSource()
        
        initialState = State(
            sections: RevisionValue(dataSource.makeSections()),
            isLoading: false,
            error: RevisionValue(nil)
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
        
        switch mutation {
        case let .setSections(sections):
            state.sections = state.sections.next(sections)
            return state
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
            
        case let .setError(error):
            state.error = state.error.next(error)
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        // Request only preset never fetched
        guard dataSource.presetSection == nil else { return .empty() }
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        // Request preset list from server
        let requestPresets: Observable<Mutation> = networkService.requestPresets().asObservable()
            .map {
                self.dataSource.setItems($0)
                return .setSections(self.dataSource.makeSections())
            }
            // Set error when any error occured
            .catchError { .just(.setError($0)) }
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        return .concat(startLoading, requestPresets, endLoading)
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - preste datasource
typealias PresetSectionModel = SectionModel<Void, TimeSetCollectionViewCellReactor>

typealias PresetCellType = TimeSetCollectionViewCellReactor

struct PresetSectionDataSource {
    // MARK: - section
    private(set) var presetSection: [PresetCellType]?
    
    // MARK: - public method
    mutating func setItems(_ items: [TimeSetItem]) {
        self.presetSection = items.map { TimeSetCollectionViewCellReactor(timeSetItem: $0) }
    }
    
    func makeSections() -> [PresetSectionModel]? {
        guard let items = presetSection else { return nil }
        return [PresetSectionModel(model: Void(), items: items)]
    }
}
