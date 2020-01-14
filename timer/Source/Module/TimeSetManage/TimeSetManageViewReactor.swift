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

    private var dataSource: TimeSetManageSectionDataSource
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, type: TimeSetType) {
        self.timeSetService = timeSetService
        dataSource = TimeSetManageSectionDataSource()
        
        initialState = State(
            type: type,
            sections: RevisionValue(dataSource.makeSections()),
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
            
        case .apply:
            state.applied = state.applied.next(true)
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
    
    private func actionEditTimeSet(at indexPath: IndexPath) -> Observable<Mutation> {
        let section = currentState.sections.value[indexPath.section].model
        
        switch section {
        case .saved:
            let item = dataSource.remove(at: indexPath.item)
            item.action.onNext(.sectionMoved(.removed))
            
        case .removed:
            let item = dataSource.restore(at: indexPath.item)
            item.action.onNext(.sectionMoved(.saved))
        }

        return .just(.setSections(dataSource.makeSections()))
    }
    
    private func actionMoveTimeSet(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Observable<Mutation> {
        guard sourceIndexPath.section == destinationIndexPath.section else { return .empty() }
        let section = currentState.sections.value[sourceIndexPath.section].model
        
        dataSource.swap(at: sourceIndexPath.item, to: destinationIndexPath.item, section: section)
        return .empty()
    }
    
    private func actionApply() -> Observable<Mutation> {
        let state = currentState
        
        let updateTimeSets = dataSource.savedTimeSetSection.map { $0.timeSetItem }
        let removeTimeSetIds = dataSource.removedTimeSetSection.compactMap { $0.timeSetItem.id }
        
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
typealias TimeSetManageSectionModel = AnimatableSectionModel<TimeSetManageSectionType, TimeSetManageCellType>

enum TimeSetManageSectionType: Int, CaseIterable, IdentifiableType {
    case saved
    case removed
    
    var identity: Int { rawValue }
}

typealias TimeSetManageCellType = TimeSetManageCollectionViewCellReactor

struct TimeSetManageSectionDataSource {
    // MARK: - section
    private(set) var savedTimeSetSection: [TimeSetManageCellType] = []
    private(set) var removedTimeSetSection: [TimeSetManageCellType] = []
    
    // MARK: - public method
    mutating func setItems(_ items: [TimeSetItem], type: TimeSetManageViewReactor.TimeSetType) {
        savedTimeSetSection = items
            .filter { type == .saved || (type == .bookmarked && $0.isBookmark) }
            .sorted(by: { type == .saved ? $0.sortingKey < $1.sortingKey : $0.bookmarkSortingKey < $1.bookmarkSortingKey })
            .map { TimeSetManageCollectionViewCellReactor(timeSetItem: $0) }
    }
    
    mutating func remove(at index: Int) -> TimeSetManageCellType {
        // Remove item from saved section and append to removed section
        let item = savedTimeSetSection.remove(at: index)
        removedTimeSetSection.append(item)
        
        return item
    }
    
    mutating func restore(at index: Int) -> TimeSetManageCellType {
        // Remove item from removed section and append to saved section
        let item = removedTimeSetSection.remove(at: index)
        savedTimeSetSection.append(item)
        
        return item
    }
    
    mutating func swap(at sourceIndex: Int, to destinationIndex: Int, section: TimeSetManageSectionType) {
        switch section {
        case .saved:
            savedTimeSetSection.swapAt(sourceIndex, destinationIndex)
            
        case .removed:
            removedTimeSetSection.swapAt(sourceIndex, destinationIndex)
        }
    }
    
    func makeSections() -> [TimeSetManageSectionModel] {
        let savedTimeSetSection = TimeSetManageSectionModel(model: .saved, items: self.savedTimeSetSection)
        let removedTimeSetSection = TimeSetManageSectionModel(model: .removed, items: self.removedTimeSetSection)
        
        return [savedTimeSetSection, removedTimeSetSection]
    }
}
