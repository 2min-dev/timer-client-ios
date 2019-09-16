//
//  TimeSetManageViewReactor.swift
//  timer
//
//  Created by JSilver on 10/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit
import RxDataSources

class TimeSetManageViewReactor: Reactor {
    enum TimeSetType: Int {
        case saved
        case bookmarked
    }
    
    enum Action {
        /// Fetch time set list from database when view will appear
        case viewWillAppear
        
        /// Remove or restore a time set at index path
        case editTimeSet(at: IndexPath)
        
        /// Apply all changes
        case apply
    }
    
    enum Mutation {
        /// Set sections
        case setSections([TimeSetManageSectionModel])
        
        // Remove a time set from section
        case removeTimeSet(at: IndexPath)
        
        // Append a time set from section
        case appendTimeSet(TimeSetManageCollectionViewCellReactor, TimeSetManageSectionType)
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Title of header
        let type: TimeSetType
        
        /// The section list of time set list
        var sections: [TimeSetManageSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        
        self.initialState = State(type: type,
                                  sections: [TimeSetManageSectionModel(model: .normal, items: []),
                                             TimeSetManageSectionModel(model: .removed, items: [])],
                                  shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
            
        case let .editTimeSet(at: indexPath):
            return actionEditTimeSet(at: indexPath)
            
        case .apply:
            return actionApply()
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
            
        case let .removeTimeSet(at: indexPath):
            state.sections[indexPath.section].items.remove(at: indexPath.row)
            return state
            
        case let .appendTimeSet(timeSet, section):
            timeSet.action.onNext(.sectionMoved(section))
            state.sections[section.rawValue].items.append(timeSet)
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
                let items = timeSets
                    .filter {
                        guard self.currentState.type == .bookmarked else { return true }
                        return $0.isBookmark
                }
                .map { TimeSetManageCollectionViewCellReactor(timeSetInfo: $0) }
                
                let setSections: Observable<Mutation> = .just(.setSections([TimeSetManageSectionModel(model: .normal, items: items),
                                                                            TimeSetManageSectionModel(model: .removed, items: [])]))
                let sectionReload: Observable<Mutation> = .just(.sectionReload)
                
                return .concat(setSections, sectionReload)
        }
    }
    
    static var testId = 9999
    private func actionEditTimeSet(at indexPath: IndexPath) -> Observable<Mutation> {
        let sectionType: TimeSetManageSectionType = indexPath.section == 0 ? .removed: .normal
        let item = currentState.sections[indexPath.section].items[indexPath.row]
        
        let removeTimeSet: Observable<Mutation> = .just(.removeTimeSet(at: indexPath))
        let appendTimeSet: Observable<Mutation> = .just(.appendTimeSet(item, sectionType))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)

        return .concat(removeTimeSet, appendTimeSet, sectionReload)
    }
    
    private func actionApply() -> Observable<Mutation> {
        return .empty()
    }
}
