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
    static let MAX_SAVED_TIME_SET = 9
    static let MAX_BOOKMARKED_TIME_SET = 10
    
    enum Action {
        /// Fetch local stored time set list
        case refresh
    }
    
    enum Mutation {
        /// Set sections
        case setSections([LocalTimeSetSectionModel])
        
        /// Set saved time set count
        case setSavedTimeSetCount(Int)
        
        /// Set bookmarked time set count
        case setBookmarkedTimeSetCount(Int)
    }
    
    struct State {
        /// The section list of time set list
        var sections: RevisionValue<[LocalTimeSetSectionModel]>
        
        /// Item count of saved time set list
        var savedTimeSetCount: Int
        
        /// Item count of bookmarked time set list
        var bookmarkedTimeSetCount: Int
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
            savedTimeSetCount: dataSource.savedTimeSetCount,
            bookmarkedTimeSetCount: dataSource.bookmarkedTimeSetCount
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
            
        case let .setBookmarkedTimeSetCount(count):
            state.bookmarkedTimeSetCount = count
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        return timeSetService.fetchTimeSets().asObservable()
            .flatMap { timeSets -> Observable<Mutation> in
                self.dataSource.setItems(timeSets)
                    
                let setSections: Observable<Mutation> = .just(.setSections(self.dataSource.makeSecitons()))
                let setSavedTimeSetCount: Observable<Mutation> = .just(.setSavedTimeSetCount(self.dataSource.savedTimeSetCount))
                let setBookmarkedTimeSetCount: Observable<Mutation> = .just(.setBookmarkedTimeSetCount(self.dataSource.bookmarkedTimeSetCount))
                
                return .concat(setSections, setSavedTimeSetCount, setBookmarkedTimeSetCount)
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
    case bookmarked
}

enum LocalTimeSetCellType {
    case regular(TimeSetCollectionViewCellReactor)
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
    private var bookmarkedTimeSetSection: [LocalTimeSetCellType] = []
    
    // MARK: - property
    private(set) var savedTimeSetCount: Int = 0
    private(set) var bookmarkedTimeSetCount: Int = 0
    
    // MARK: - public method
    mutating func setItems(_ items: [TimeSetItem]) {
        // Classify items by section
        let savedTimeSetItems = items
        let bookmarkedTimeSetItems = items.filter { $0.isBookmark }
        
        // Store all count of section
        savedTimeSetCount = savedTimeSetItems.count
        bookmarkedTimeSetCount = bookmarkedTimeSetItems.count
        
        // Make section data
        savedTimeSetSection = savedTimeSetItems
            .sorted(by: { $0.sortingKey < $1.sortingKey })
            .enumerated()
            .filter { $0.offset < LocalTimeSetViewReactor.MAX_SAVED_TIME_SET }
            .map { .regular(TimeSetCollectionViewCellReactor(timeSetItem: $0.element)) }
        
        bookmarkedTimeSetSection = bookmarkedTimeSetItems
            .sorted(by: { $0.bookmarkSortingKey < $1.bookmarkSortingKey })
            .enumerated()
            .filter { $0.offset < LocalTimeSetViewReactor.MAX_BOOKMARKED_TIME_SET }
            .map { .regular(TimeSetCollectionViewCellReactor(timeSetItem: $0.element)) }
    }
    
    func makeSecitons() -> [LocalTimeSetSectionModel] {
        // Make section model
        let savedTimeSetSection = LocalTimeSetSectionModel(
            model: .saved,
            items: savedTimeSetCount == 0 ? [.empty] : self.savedTimeSetSection
        )
        
        let bookmarkedTimeSetSection = LocalTimeSetSectionModel(
            model: .bookmarked,
            items: self.bookmarkedTimeSetSection
        )
        
        return [savedTimeSetSection, bookmarkedTimeSetSection].filter { $0.items.count > 0 }
    }
}
