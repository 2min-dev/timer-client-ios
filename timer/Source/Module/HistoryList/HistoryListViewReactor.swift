//
//  HistoryListViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/10/13.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
import ReactorKit

class HistoryListViewReactor: Reactor {
    enum Action {
        /// Fetch history list to refresh
        case refresh
    }
    
    enum Mutation {
        /// Set menu sections
        case setSections([HistorySectionModel])
    }
    
    struct State {
        /// History sections
        var sections: RevisionValue<[HistorySectionModel]>
    }
    
    // MARK: - properties
    var initialState: State
    private let historyService: HistoryServiceProtocol
    
    private var dataSource: HistoryListSectionDataSource
    
    // MARK: - constructor
    init(historyService: HistoryServiceProtocol) {
        self.historyService = historyService
        dataSource = HistoryListSectionDataSource()
        
        initialState = State(sections: RevisionValue(dataSource.makeSections()))
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
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        historyService.fetchHistories()
            .do(onSuccess: { self.dataSource.setItems($0) })
            .asObservable()
            .map { _ in .setSections(self.dataSource.makeSections()) }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - setting datasource
typealias HistorySectionModel = SectionModel<Void, HistoryListCollectionViewCellReactor>

typealias HistoryCellType = HistoryListCollectionViewCellReactor

struct HistoryListSectionDataSource {
    // MARK: - section
    var historySection: [HistoryCellType] = []
    
    // MARK: - public method
    mutating func setItems(_ itmes: [History]) {
        historySection = itmes
            .compactMap { HistoryListCollectionViewCellReactor(history: $0) }
    }
    
    func makeSections() -> [HistorySectionModel] {
        return [HistorySectionModel(model: Void(), items: historySection)]
    }
}
