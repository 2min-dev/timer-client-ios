//
//  LocalTimeSetViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
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
        case setSections([TimeSetSectionModel])
        
        /// Set saved time set count
        case setSavedTimeSetCount(Int)
        
        /// Set bookmarked time set count
        case setBookmarkedTimeSetCount(Int)
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// The section list of time set list
        var sections: [TimeSetSectionModel]
        
        /// Item count of saved time set list
        var savedTimeSetCount: Int
        
        /// Item count of bookmarked time set list
        var bookmarkedTimeSetCount: Int
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private var timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol) {
        self.timeSetService = timeSetService
        
        self.initialState = State(sections: [],
                                  savedTimeSetCount: 0,
                                  bookmarkedTimeSetCount: 0,
                                  shouldSectionReload: true)
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
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setSections(sections):
            state.sections = sections
            return state
            
        case let .setSavedTimeSetCount(count):
            state.savedTimeSetCount = count
            return state
            
        case let .setBookmarkedTimeSetCount(count):
            state.bookmarkedTimeSetCount = count
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        return timeSetService.fetchTimeSets()
            .asObservable()
            .flatMap { timeSets -> Observable<Mutation> in
                let savedTimeSetItems: [TimeSetCellType] = timeSets.sorted(by: { $0.sortingKey < $1.sortingKey })
                    .map { .regular(TimeSetCollectionViewCellReactor(timeSetInfo: $0)) }
                let bookmarkedTimeSetItems: [TimeSetCellType] = timeSets.filter { $0.isBookmark }
                    .sorted(by: { $0.bookmarkSortingKey < $1.bookmarkSortingKey })
                    .map { .regular(TimeSetCollectionViewCellReactor(timeSetInfo: $0)) }
                
                // Get time set items count
                let savedTimeSetCount = savedTimeSetItems.count
                let bookmarkedTimeSetCount = bookmarkedTimeSetItems.count
                
                // Create sections
                let savedTimeSetSection = TimeSetSectionModel(model: Void(),
                                                              items: savedTimeSetCount == 0 ? [.empty] : Array(savedTimeSetItems[0 ..< min(savedTimeSetCount, LocalTimeSetViewReactor.MAX_SAVED_TIME_SET)]))
                var bookmarkedTimeSetSection: TimeSetSectionModel?
                if bookmarkedTimeSetCount > 0 {
                    bookmarkedTimeSetSection = TimeSetSectionModel(model: Void(),
                                                                   items: Array(bookmarkedTimeSetItems[0 ..< min(bookmarkedTimeSetCount, LocalTimeSetViewReactor.MAX_BOOKMARKED_TIME_SET)]))
                }
                
                // Create mutation observable
                let setSections: Observable<Mutation> = .just(.setSections([savedTimeSetSection, bookmarkedTimeSetSection].compactMap { $0 }))
                let setSavedTimeSetCount: Observable<Mutation> = .just(.setSavedTimeSetCount(savedTimeSetCount))
                let setBookmarkedTimeSetCount: Observable<Mutation> = .just(.setBookmarkedTimeSetCount(bookmarkedTimeSetCount))
                let sectionReload: Observable<Mutation> = .just(.sectionReload)
                
                return .concat(setSections, setSavedTimeSetCount, setBookmarkedTimeSetCount, sectionReload)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
