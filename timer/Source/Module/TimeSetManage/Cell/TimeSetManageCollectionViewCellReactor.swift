//
//  TimeSetManageCollectionViewCellReactor.swift
//  timer
//
//  Created by JSilver on 15/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RxDataSources

class TimeSetManageCollectionViewCellReactor: Reactor, IdentifiableType {
    enum Action {
        /// Time set moved other section
        case sectionMoved(TimeSetManageSectionType)
    }
    
    enum Mutation {
        /// Set type of section containing cell
        case setType(TimeSetManageSectionType)
    }
    
    struct State {
        /// All time of the time set
        let allTime: TimeInterval
        
        /// Title of the time set
        let title: String
        
        /// Type of section containing cell
        var type: TimeSetManageSectionType
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetItem: TimeSetItem
    var identity: String?
    
    // MARK: - constructor
    init(timeSetItem: TimeSetItem) {
        self.timeSetItem = timeSetItem
        identity = timeSetItem.id
        
        initialState = State(allTime: timeSetItem.timers.reduce(0) { $0 + $1.end },
                             title: timeSetItem.title,
                             type: .normal)
    }
    
    // MARK: - mutation
    func mutate(action: TimeSetManageCollectionViewCellReactor.Action) -> Observable<TimeSetManageCollectionViewCellReactor.Mutation> {
        switch action {
        case let .sectionMoved(section):
            return actionSectionMoved(section: section)
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setType(type):
            state.type = type
            return state
        }
    }
    
    // MARK: - action method
    private func actionSectionMoved(section: TimeSetManageSectionType) -> Observable<Mutation> {
        return .just(.setType(section))
    }
}

extension TimeSetManageCollectionViewCellReactor: Equatable {
    static func == (lhs: TimeSetManageCollectionViewCellReactor, rhs: TimeSetManageCollectionViewCellReactor) -> Bool {
        return lhs.identity == rhs.identity
    }
}
