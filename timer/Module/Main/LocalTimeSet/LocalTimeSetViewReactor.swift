//
//  LocalTimeSetViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RxDataSources

typealias TimeSetSectionModel = SectionModel<Void, TimeSetCellType>

class LocalTimeSetViewReactor: Reactor {
    // MARK: - constants
    static let SAVED_TIME_SET_SECTION = 0
    static let BOOKMARKED_TIME_SET_SECTION = 1
    
    enum Action {
        /// Fetch local stored time set list when view will appear
        case viewWillAppear
    }
    
    enum Mutation {
        case setSections([TimeSetSectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// The section list of time set list
        var sections: [TimeSetSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private var timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol) {
        self.timeSetService = timeSetService
        
        self.initialState = State(sections: [TimeSetSectionModel(model: Void(), items: [.empty])],
                                  shouldSectionReload: true)
    }
    
    // MARK: - mutate
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
        return timeSetService.fetchTimeSets()
            .asObservable()
            .flatMap { timeSets -> Observable<Mutation> in
                let savedTimeSetItems = timeSets.isEmpty ? [.empty] : timeSets.map { TimeSetCellType.regular($0) }
                let bookmarkedTimeSetItems = timeSets.filter { $0.isBookmark }
                    .map { TimeSetCellType.regular($0) }
                
                let savedTimeSetSection = TimeSetSectionModel(model: Void(), items: savedTimeSetItems)
                let bookmaredTimeSetSection = TimeSetSectionModel(model: Void(), items: bookmarkedTimeSetItems)
                
                let setSections: Observable<Mutation> = .just(.setSections([savedTimeSetSection, bookmaredTimeSetSection]))
                let sectionReload: Observable<Mutation> = .just(.sectionReload)
                
                return .concat(setSections, sectionReload)
        }
    }
}

enum TimeSetCellType {
    case regular(TimeSetInfo)
    case empty
}
