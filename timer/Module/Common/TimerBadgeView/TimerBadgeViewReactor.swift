//
//  TimerBadgeViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/07/09.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimerBadgeViewReactor: Reactor {
    enum Action {
        /// Update timer badge view enabled
        case updateEnabled(Bool)
        
        /// Update timer list
        case updateTimers([TimerInfo], [TimerBadgeExtraCellType]?, [TimerBadgeExtraCellType]?)
        
        /// Select badge at index path
        /// Index path represent selected index path of only regular items
        case selectBadge(at: IndexPath)
        
        /// Change badge position
        /// Index path represent in all range of timer badge view
        case moveBadge(at: IndexPath, to: IndexPath)
    }
    
    enum Mutation {
        /// Set timer badge view enabled
        case setEnabled(Bool)
        
        /// Set sections
        case setSections([TimerBadgeSectionModel])
        
        /// Set selected index path
        case setSelectedIndexPath(IndexPath)
        
        /// Swap the position of two items
        case swapItem(at: IndexPath, to: IndexPath)
        
        /// Set should section reload `ture`
        case sectionReload
    }
    
    struct State {
        /// Is timer badge view enabled
        var isEnabled: Bool
        
        /// Sections of timer badge list
        var sections: [TimerBadgeSectionModel]
        
        /// Current selected index path
        var selectedIndexPath: IndexPath?
        
        /// Need to reload sections
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    init() {
        self.initialState = State(isEnabled: true,
                                  sections: [TimerBadgeSectionModel(model: Void(), items: [])],
                                  selectedIndexPath: nil,
                                  shouldSectionReload: true)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateEnabled(isEnabled):
            return actionUpdateEnabled(isEnabled)
            
        case let .updateTimers(timers, leftExtraItems, rightExtraItems):
            return actionUpdateTimers(timers, leftExtraItems: leftExtraItems, rightExtraItems: rightExtraItems)
            
        case let .selectBadge(at: indexPath):
            return actionSelectBadge(at: indexPath)
            
        case let .moveBadge(at: sourceIndexPath, to: destinationIndexPath):
            return actionMoveBadge(at: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setEnabled(isEnabled):
            state.isEnabled = isEnabled
            return state
            
        case let .setSections(sections):
            state.sections = sections
            if let indexPath = state.selectedIndexPath {
                // Set select badge if current selected index path is exist
                let items = state.sections[0].items.filter { $0.isRegular }
                items[indexPath.row].item?.action.onNext(.select(true))
            }
            return state
            
        case let .setSelectedIndexPath(indexPath):
            let items = state.sections[0].items.filter({ $0.isRegular })
            guard indexPath.row < items.count else { return state }
            
            if let previousIndexPath = state.selectedIndexPath {
                // Emit deselect action to previous selected item
                items[previousIndexPath.row].item?.action.onNext(.select(false))
            }
            // Emit select action to selected item
            items[indexPath.row].item?.action.onNext(.select(true))
            
            state.selectedIndexPath = indexPath
            return state
            
        case let .swapItem(at: sourceIndexPath, to: destinationIndexPath):
            var items = state.sections[0].items
            guard let firstIndex = items.firstIndex(where: { $0.isRegular }) else { return state }
            
            // Swap item
            items.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        
            // Update badge index
            items[sourceIndexPath.row].item?.action.onNext(.updateIndex(sourceIndexPath.row - firstIndex + 1))
            items[destinationIndexPath.row].item?.action.onNext(.updateIndex(destinationIndexPath.row - firstIndex + 1))
            
            state.sections[0].items = items
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionUpdateEnabled(_ isEnabled: Bool) -> Observable<Mutation> {
        let setEnabled: Observable<Mutation> = .just(.setEnabled(isEnabled))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setEnabled, sectionReload)
    }
    
    private func actionUpdateTimers(_ timers: [TimerInfo], leftExtraItems: [TimerBadgeExtraCellType]?, rightExtraItems: [TimerBadgeExtraCellType]?) -> Observable<Mutation> {
        var items: [TimerBadgeCellType] = []
        // Make timer badge section
        items.append(contentsOf: leftExtraItems?.map { TimerBadgeCellType.extra($0) } ?? [])
        items.append(contentsOf: timers.enumerated().map { TimerBadgeCellType.regular(TimerBadgeCellReactor(info: $0.element, index: $0.offset + 1, count: timers.count)) })
        items.append(contentsOf: rightExtraItems?.map { TimerBadgeCellType.extra($0) } ?? [])
        
        let setSections: Observable<Mutation> = .just(.setSections([TimerBadgeSectionModel(model: Void(), items: items)]))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSections, sectionReload)
    }
    
    private func actionSelectBadge(at indexPath: IndexPath) -> Observable<Mutation> {
        return .just(.setSelectedIndexPath(indexPath))
    }
    
    private func actionMoveBadge(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Observable<Mutation> {
        return .just(.swapItem(at: sourceIndexPath, to: destinationIndexPath))
    }
    
    deinit {
        Logger.verbose()
    }
}
