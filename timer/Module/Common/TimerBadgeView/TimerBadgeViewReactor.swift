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
        /// Update timer list
        case updateTimers([TimerInfo], TimerBadgeCellType?)
        
        /// Select badge
        case selectBadge(at: IndexPath)
        
        /// Change badge position
        case moveBadge(at: IndexPath, to: IndexPath)
        
        /// Refresh section
        case refresh
    }
    
    enum Mutation {
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
        /// Sections of timer badge view
        var sections: [TimerBadgeSectionModel]
        
        /// Current selected index path
        var selectedIndexPath: IndexPath?
        
        /// Need section reload
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    init() {
        self.initialState = State(sections: [TimerBadgeSectionModel(model: Void(), items: [])],
                                  selectedIndexPath: nil,
                                  shouldSectionReload: true)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTimers(timers, cell):
            return actionUpdateTimers(timers, extra: cell)
            
        case let .selectBadge(at: indexPath):
            return actionSelectBadge(at: indexPath)
            
        case let .moveBadge(at: sourceIndexPath, to: destinationIndexPath):
            return actionMoveBadge(at: sourceIndexPath, to: destinationIndexPath)
            
        case .refresh:
            return .just(.sectionReload)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setSections(sections):
            state.sections = sections
            return state
            
        case let .setSelectedIndexPath(indexPath):
            guard indexPath.row < state.sections[0].items.count else { return state }
            
            if let previousIndexPath = state.selectedIndexPath {
                state.sections[0].items[previousIndexPath.row].item?.action.onNext(.select(false))
            }
            state.sections[0].items[indexPath.row].item?.action.onNext(.select(true))
            
            state.selectedIndexPath = indexPath
            return state
            
        case let .swapItem(at: sourceIndexPath, to: destinationIndexPath):
            state.sections[0].items.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            
            let items = state.sections[0].items
            items[sourceIndexPath.row].item?.action.onNext(.updateIndex(sourceIndexPath.row + 1))
            items[destinationIndexPath.row].item?.action.onNext(.updateIndex(destinationIndexPath.row + 1))
            
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionUpdateTimers(_ timers: [TimerInfo], extra cell: TimerBadgeCellType?) -> Observable<Mutation> {
        var items = timers.enumerated().map { index, info in
            TimerBadgeCellType.regular(TimerBadgeCellReactor(info: info, index: index + 1))
        }
        
        if let cell = cell {
            items.append(cell)
        }
        
        let setSections: Observable<Mutation> = .just(.setSections([TimerBadgeSectionModel(model: Void(), items: items)]))
        
        var setSelectedIndexPath: Observable<Mutation> = .empty()
        if let indexPath = currentState.selectedIndexPath {
            setSelectedIndexPath = .just(.setSelectedIndexPath(indexPath))
        }
        let sectionReload: Observable<Mutation> = .just(.sectionReload)

        return .concat(setSections, setSelectedIndexPath, sectionReload)
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
