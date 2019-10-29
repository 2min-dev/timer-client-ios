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
        
        /// Change time set order
        case moveTimeSet(at: IndexPath, to: IndexPath)
        
        /// Apply all changes
        case apply
    }
    
    enum Mutation {
        /// Set sections
        case setSections([TimeSetManageSectionModel])
        
        /// Remove a time set from section
        case removeTimeSet(at: IndexPath)
        
        /// Append a time set from section
        case appendTimeSet(TimeSetManageCollectionViewCellReactor, TimeSetManageSectionType)
        
        /// Move time set
        case swapTimeSet(at: IndexPath, to: IndexPath)
        
        /// Set should section reload `true`
        case sectionReload
        
        /// Set should dismiss `true`
        case dismiss
    }
    
    struct State {
        /// Title of header
        let type: TimeSetType
        
        /// The section list of time set list
        var sections: [TimeSetManageSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
        
        /// Need to dismiss view
        var shouldDismiss: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        
        initialState = State(type: type,
                             sections: [TimeSetManageSectionModel(model: .normal, items: []),
                                        TimeSetManageSectionModel(model: .removed, items: [])],
                             shouldSectionReload: true,
                             shouldDismiss: false)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
            
        case let .editTimeSet(at: indexPath):
            return actionEditTimeSet(at: indexPath)
            
        case let .moveTimeSet(at: sourceIndexPath, to: destinationIndexPath):
            return actionMoveTimeSet(at: sourceIndexPath, to: destinationIndexPath)
            
        case .apply:
            return actionApply()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.shouldDismiss = false
        
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
            
        case let .swapTimeSet(at: sourceIndexPath, to: destinationIndexPath):
            if sourceIndexPath.section == destinationIndexPath.section {
                state.sections[sourceIndexPath.section].items.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            } else {
                let item = state.sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
                state.sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.row)
            }
            
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
            
        case .dismiss:
            state.shouldDismiss = true
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
                    .map { TimeSetManageCollectionViewCellReactor(timeSetItem: $0) }
                
                let setSections: Observable<Mutation> = .just(.setSections([TimeSetManageSectionModel(model: .normal, items: items),
                                                                            TimeSetManageSectionModel(model: .removed, items: [])]))
                let sectionReload: Observable<Mutation> = .just(.sectionReload)
                
                return .concat(setSections, sectionReload)
        }
    }
    
    private func actionEditTimeSet(at indexPath: IndexPath) -> Observable<Mutation> {
        let sectionType: TimeSetManageSectionType = indexPath.section == 0 ? .removed: .normal
        let item = currentState.sections[indexPath.section].items[indexPath.row]
        
        let removeTimeSet: Observable<Mutation> = .just(.removeTimeSet(at: indexPath))
        let appendTimeSet: Observable<Mutation> = .just(.appendTimeSet(item, sectionType))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(removeTimeSet, appendTimeSet, sectionReload)
    }
    
    private func actionMoveTimeSet(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Observable<Mutation> {
        guard sourceIndexPath.section == destinationIndexPath.section else { return .empty() }
        return .just(.swapTimeSet(at: sourceIndexPath, to: destinationIndexPath))
    }
    
    private func actionApply() -> Observable<Mutation> {
        let state = currentState
        
        guard state.sections.count == 2 else { return .empty() }
        
        let updateTimeSets = state.sections[0].items.map { $0.timeSetItem }
        let removeTimeSetIds = state.sections[1].items.compactMap { $0.timeSetItem.id }
        
        // Set reordered sorting key
        updateTimeSets.enumerated().forEach {
            if state.type == .saved {
                $0.element.sortingKey = $0.offset
            } else {
                $0.element.bookmarkSortingKey = $0.offset
            }
        }
        
        return timeSetService.removeTimeSets(ids: removeTimeSetIds).asObservable()
            .flatMap { _ in self.timeSetService.updateTimeSets(items: updateTimeSets) }
            .flatMap { _ -> Observable<Mutation> in .just(.dismiss) }
    }
    
    deinit {
        Logger.verbose()
    }
}
