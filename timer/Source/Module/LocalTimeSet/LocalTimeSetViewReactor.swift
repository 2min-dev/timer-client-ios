//
//  LocalTimeSetViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
import ReactorKit

class LocalTimeSetViewReactor: Reactor {
    // MARK: - constants
    static let MAX_SAVED_TIME_SET = 10
    
    enum Action {
        /// Fetch local stored time set list
        case refresh
    }
    
    enum Mutation {
        /// Set sections
        case setSections([LocalTimeSetSectionModel])
        
        /// Set saved time set count
        case setSavedTimeSetCount(Int)
    }
    
    struct State {
        /// The section list of time set list
        var sections: RevisionValue<[LocalTimeSetSectionModel]>
        
        /// Item count of saved time set list
        var savedTimeSetCount: Int
    }
    
    // MARK: - properties
    var initialState: State
    
    private var timeSetService: TimeSetServiceProtocol
    private var dataSource: LocalTimeSetDataSource
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol) {
        self.timeSetService = timeSetService
        dataSource = LocalTimeSetDataSource()
        
        initialState = State(
            sections: RevisionValue(dataSource.makeSecitons()),
            savedTimeSetCount: dataSource.savedTimeSetCount
        )
    }
    
    // MARK: - mutate
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
            
        case let .setSavedTimeSetCount(count):
            state.savedTimeSetCount = count
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        return timeSetService.fetchTimeSets()
            .do(onSuccess: { self.dataSource.setItems($0) })
            .flatMap { _ in self.timeSetService.fetchRecentlyUsedTimeSets(count: 3) }
            .do(onSuccess: { self.dataSource.setRecentlyUsed(timeSets: $0) })
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                let setSections: Observable<Mutation> = .just(.setSections(self.dataSource.makeSecitons()))
                let setSavedTimeSetCount: Observable<Mutation> = .just(.setSavedTimeSetCount(self.dataSource.savedTimeSetCount))
                
                return .concat(setSections, setSavedTimeSetCount)
            }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - local time set datasource
typealias LocalTimeSetSectionModel = SectionModel<LocalTimeSetSectionType, LocalTimeSetCellType>

enum LocalTimeSetSectionType {
    case saved
    case recentlyUsed
}

enum LocalTimeSetCellType {
    case regular(TimeSetCollectionViewCellReactor)
    case all
    case empty
    
    var item: TimeSetCollectionViewCellReactor? {
        switch self {
        case let .regular(reactor):
            return reactor
            
        default:
            return nil
        }
    }
}

struct LocalTimeSetDataSource {
    // MARK: - section
    private var savedTimeSetSection: [LocalTimeSetCellType] = []
    private var recentlyUsedTimeSetSection: [LocalTimeSetCellType] = []
    
    // MARK: - property
    private(set) var savedTimeSetCount: Int = 0
    
    // MARK: - public method
    mutating func setItems(_ items: [TimeSetItem]) {
        // Store all count of section
        savedTimeSetCount = items.count
        
        if savedTimeSetCount == 0 {
            savedTimeSetSection = [.empty]
        } else {
            // Make section data
            savedTimeSetSection = items
                .sorted(by: { $0.sortingKey < $1.sortingKey })
                .range(0 ..< LocalTimeSetViewReactor.MAX_SAVED_TIME_SET)
                .map { .regular(TimeSetCollectionViewCellReactor(timeSetItem: $0)) }
            
            if savedTimeSetCount > LocalTimeSetViewReactor.MAX_SAVED_TIME_SET {
                // Add all time set cell type if item's count exceed MAX_SAVED_TIME_SET
                savedTimeSetSection.append(.all)
            }
        }
        
    }
    
    mutating func setRecentlyUsed(timeSets: [TimeSetItem]) {
        // Make section data
        recentlyUsedTimeSetSection = timeSets.map { .regular(TimeSetCollectionViewCellReactor(timeSetItem: $0)) }
    }
    
    func makeSecitons() -> [LocalTimeSetSectionModel] {
        // Make section model
        let savedTimeSetSection = LocalTimeSetSectionModel(
            model: .saved,
            items: self.savedTimeSetSection
        )
        
        let recentlyUsedTimeSetSection = LocalTimeSetSectionModel(
            model: .recentlyUsed,
            items: self.recentlyUsedTimeSetSection
        )
        
        return [savedTimeSetSection, recentlyUsedTimeSetSection].filter { $0.items.count > 0 }
    }
}
