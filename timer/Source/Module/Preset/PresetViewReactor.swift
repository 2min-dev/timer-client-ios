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
    var items: [TimeSetItem] = []
    
    func makeSections() -> [PresetSectionModel] {
        let items = self.items.map { TimeSetCollectionViewCellReactor(timeSetItem: $0) }
        return [PresetSectionModel(model: Void(), items: items)]
    }
}

class PresetViewReactor: Reactor {
    enum Action {
        /// Fetch preset list from server
        case refresh
    }
    
    enum Mutation {
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        var dataSource: PresetDataSource
        
        /// The section list of time set list
        var sections: [PresetSectionModel] {
            dataSource.makeSections()
        }
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    private let networkService: NetworkServiceProtocol
    
    // MARK: - constructor
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        
        initialState = State(dataSource: PresetDataSource(),
                             shouldSectionReload: true)
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
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        // TODO: Fetch presets
        return .just(.sectionReload)
    }
    
    deinit {
        Logger.verbose()
    }
}
