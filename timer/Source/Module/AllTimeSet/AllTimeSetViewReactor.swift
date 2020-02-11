//
//  AllTimeSetViewReactor.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
import ReactorKit

class AllTimeSetViewReactor: Reactor {
    enum TimeSetType {
        case saved
        case preset
    }
    
    enum Action {
        /// Load time set list from database
        case load
    }
    
    enum Mutation {
        /// Set sections
        case setSections([AllTimeSetSectionModel])
        
        /// Set loading state
        case setLoading(Bool)
    }
    
    struct State {
        /// The type of time set
        var type: TimeSetType
        
        /// The section list of time set list
        var sections: RevisionValue<[AllTimeSetSectionModel]>
        
        /// Is loading to process
        var isLoading: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol

    private var dataSource: AllTimeSetSectionDataSource
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        dataSource = AllTimeSetSectionDataSource()
        
        initialState = State(
            type: type,
            sections: RevisionValue(dataSource.makeSections()),
            isLoading: false
        )
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return actionLoad()
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
        }
    }
    
    // MARK: - action method
    private func actionLoad() -> Observable<Mutation> {
        switch currentState.type {
        case .saved:
            return timeSetService.fetchTimeSets()
                .do(onSuccess: { self.dataSource.setItems($0) })
                .asObservable()
                .map { _ in .setSections(self.dataSource.makeSections()) }
            
        case .preset:
            let startLoading: Observable<Mutation> = .just(.setLoading(true))
            let setSections: Observable<Mutation> = timeSetService.fetchAllPresets()
                .do(onSuccess: { self.dataSource.setItems($0) })
                .asObservable()
                .map { _ in .setSections(self.dataSource.makeSections()) }
            let stopLoading: Observable<Mutation> = .just(.setLoading(true))
            
            return .concat(startLoading, setSections, stopLoading)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - all time set datasource
typealias AllTimeSetSectionModel = SectionModel<Void, TimeSetCollectionViewCellReactor>

typealias AllTimeSetCellType = TimeSetCollectionViewCellReactor

struct AllTimeSetSectionDataSource {
    // MARK: - section
    private var timeSetSection: [AllTimeSetCellType] = []
    
    // MARK: - public method
    mutating func setItems(_ items: [TimeSetItem]) {
        timeSetSection = items
            .sorted(by: { $0.sortingKey < $1.sortingKey })
            .map { TimeSetCollectionViewCellReactor(timeSetItem: $0) }
    }
    
    func makeSections() -> [AllTimeSetSectionModel] {
        let timeSetSection = AllTimeSetSectionModel(model: Void(), items: self.timeSetSection)
        return [timeSetSection].filter { $0.items.count > 0 }
    }
}
