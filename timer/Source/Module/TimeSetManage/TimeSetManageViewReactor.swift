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
        /// Load time set list from database
        case load
        
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
        
        /// Section reload
        case sectionReload
        
        /// Set time set changes applied to `true`
        case apply
    }
    
    struct State {
        /// Title of header
        let type: TimeSetType
        
        /// The section list of time set list
        var sections: RevisionValue<[TimeSetManageSectionModel]>
        
        /// Time set list changes all applied
        var applied: RevisionValue<Bool>
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        
        initialState = State(
            type: type,
            sections: RevisionValue([
                TimeSetManageSectionModel(model: .normal, items: []),
                TimeSetManageSectionModel(model: .removed, items: [])
            ]),
            applied: RevisionValue(false)
        )
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return actionLoad()
            
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
        
        switch mutation {
        case let .setSections(sections):
            state.sections = state.sections.next(sections)
            return state
            
        case let .removeTimeSet(at: indexPath):
            // Remove item at index path
            var sections = state.sections.value
            sections[indexPath.section].items.remove(at: indexPath.row)
            
            state.sections.value = sections
            return state
            
        case let .appendTimeSet(item, section):
            // Emit item's section changed event to cell reactor
            item.action.onNext(.sectionMoved(section))
            
            // Append item to section
            var sections = state.sections.value
            sections[section.rawValue].items.append(item)
            
            state.sections.value = sections
            return state
            
        case let .swapTimeSet(at: sourceIndexPath, to: destinationIndexPath):
            var sections = state.sections.value
            if sourceIndexPath.section == destinationIndexPath.section {
                // Swap items
                sections[sourceIndexPath.section].items.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            } else {
                // Remove item from source section and insert item to destination section
                let item = sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
                sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.row)
            }
            
            state.sections.value = sections
            return state
            
        case .sectionReload:
            state.sections = state.sections.next()
            return state
            
        case .apply:
            state.applied = state.applied.next(true)
            return state
        }
    }
    
    // MARK: - action method
    private func actionLoad() -> Observable<Mutation> {
        let state = currentState
        
        return timeSetService.fetchTimeSets().asObservable()
            .flatMap { timeSets -> Observable<Mutation> in
                let items = timeSets
                    .filter { state.type == .saved || (state.type == .bookmarked && $0.isBookmark) }
                    .sorted(by: {
                        state.type == .saved ?
                            $0.sortingKey < $1.sortingKey :
                            $0.bookmarkSortingKey < $1.bookmarkSortingKey
                    })
                    .map { TimeSetManageCollectionViewCellReactor(timeSetItem: $0) }
                
                return .just(.setSections([
                    TimeSetManageSectionModel(model: .normal, items: items),
                    TimeSetManageSectionModel(model: .removed, items: [])
                ]))
        }
    }
    
    private func actionEditTimeSet(at indexPath: IndexPath) -> Observable<Mutation> {
        guard let fromSection = TimeSetManageSectionType(rawValue: indexPath.section) else { return .empty() }
        
        let toSection: TimeSetManageSectionType = fromSection == .normal ? .removed : .normal // Get section to move
        let item = currentState.sections.value[indexPath.section].items[indexPath.row] // Get item to move
        
        let removeTimeSet: Observable<Mutation> = .just(.removeTimeSet(at: indexPath))
        let appendTimeSet: Observable<Mutation> = .just(.appendTimeSet(item, toSection))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(removeTimeSet, appendTimeSet, sectionReload)
    }
    
    private func actionMoveTimeSet(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Observable<Mutation> {
        guard sourceIndexPath.section == destinationIndexPath.section else { return .empty() }
        return .just(.swapTimeSet(at: sourceIndexPath, to: destinationIndexPath))
    }
    
    private func actionApply() -> Observable<Mutation> {
        let state = currentState
        let sections = state.sections.value
        guard sections.count == TimeSetManageSectionType.allCases.count else { return .empty() }
        
        let updateTimeSets = sections[0].items.map { $0.timeSetItem }
        let removeTimeSetIds = sections[1].items.compactMap { $0.timeSetItem.id }
        
        // Set reordered sorting key
        updateTimeSets.enumerated().forEach {
            switch state.type {
            case .saved:
                $0.element.sortingKey = $0.offset
                
            case .bookmarked:
                $0.element.bookmarkSortingKey = $0.offset
            }
        }
        
        return timeSetService.removeTimeSets(ids: removeTimeSetIds).asObservable()
            .flatMap { _ in self.timeSetService.updateTimeSets(items: updateTimeSets) }
            .flatMap { _ -> Observable<Mutation> in .just(.apply) }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - time set manage datasource
typealias TimeSetManageSectionModel = AnimatableSectionModel<TimeSetManageSectionType, TimeSetManageCollectionViewCellReactor>

enum TimeSetManageSectionType: Int, CaseIterable, IdentifiableType {
    case normal
    case removed
    
    var identity: Int { rawValue }
}
