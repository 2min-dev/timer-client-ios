//
//  AllTimeSetViewReactor.swift
//  timer
//
//  Created by JSilver on 18/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class AllTimeSetViewReactor: Reactor {
    enum TimeSetType: Int {
        case saved
        case bookmarked
    }
    
    enum Action {
        /// Fetch time set list from database when view will appear
        case viewWillAppear
    }
    
    enum Mutation {
        /// Set sections
        case setSections([AllTimeSetSectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Title of header
        let type: TimeSetType
        
        /// The section list of time set list
        var sections: [AllTimeSetSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        
        initialState = State(type: type, sections: [], shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
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
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        let state = currentState
        
        return timeSetService.fetchTimeSets()
            .asObservable()
            .flatMap { timeSets -> Observable<Mutation> in
                let items = timeSets
                    .filter { return state.type == .saved || (state.type == .bookmarked && $0.isBookmark) }
                    .sorted(by: {
                        return state.type == .saved ?
                            $0.sortingKey < $1.sortingKey :
                            $0.bookmarkSortingKey < $1.bookmarkSortingKey
                    })
                    .map { TimeSetCollectionViewCellReactor(timeSetInfo: $0) }
                
                let setSections: Observable<Mutation> = .just(.setSections([AllTimeSetSectionModel(model: Void(), items: items)]))
                let sectionReload: Observable<Mutation> = .just(.sectionReload)
                
                return .concat(setSections, sectionReload)
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
