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
    enum TimeSetType: Int {
        case saved
        case bookmarked
    }
    
    enum Action {
        /// Load time set list from database
        case load
    }
    
    enum Mutation {
        /// Set sections
        case setSections([AllTimeSetSectionModel])
    }
    
    struct State {
        /// Title of header
        let type: TimeSetType
        
        /// The section list of time set list
        var sections: RevisionValue<[AllTimeSetSectionModel]>
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
            sections: RevisionValue(dataSource.makeSections())
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
        }
    }
    
    // MARK: - action method
    private func actionLoad() -> Observable<Mutation> {
        return timeSetService.fetchTimeSets().asObservable()
            .map {
                self.dataSource.setItems($0, type: self.currentState.type)
                return .setSections(self.dataSource.makeSections())
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
    var timeSetSection: [AllTimeSetCellType] = []
    
    // MARK: - public method
    mutating func setItems(_ items: [TimeSetItem], type: AllTimeSetViewReactor.TimeSetType) {
        timeSetSection = items
            .filter { type == .saved || (type == .bookmarked && $0.isBookmark) }
            .sorted(by: { type == .saved ? $0.sortingKey < $1.sortingKey : $0.bookmarkSortingKey < $1.bookmarkSortingKey })
            .map { TimeSetCollectionViewCellReactor(timeSetItem: $0) }
    }
    
    func makeSections() -> [AllTimeSetSectionModel] {
        return [AllTimeSetSectionModel(model: Void(), items: timeSetSection)]
    }
}
