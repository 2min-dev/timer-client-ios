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
        case updateTimers([TimerInfo], TimerBadgeCellType?)
        case selectBadge(IndexPath)
        case moveBadge(at: IndexPath, to: IndexPath)
    }
    
    enum Mutation {
        case setSections([TimerBadgeSectionModel])
        case setSelectedIndexPath(IndexPath)
        case swapItem(at: IndexPath, to: IndexPath)
        
        case sectionReload
    }
    
    struct State {
        var sections: [TimerBadgeSectionModel]
        var selectedIndexPath: IndexPath?
        
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    init() {
        self.initialState = State(sections: [TimerBadgeSectionModel(model: Void(), items: [])],
                                  selectedIndexPath: nil,
                                  shouldSectionReload: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTimers(timers, extraCell):
            var items = timers.enumerated().map { index, info in
                TimerBadgeCellType.regular(TimerBadgeCellReactor(info: info, index: index + 1))
            }
            
            if let extraCell = extraCell {
                items.append(extraCell)
            }
            
            let setSections: Observable<Mutation> = .just(.setSections([TimerBadgeSectionModel(model: Void(), items: items)]))
            
            var setSelectedIndexPath: Observable<Mutation> = .empty()
            if let indexPath = currentState.selectedIndexPath {
                setSelectedIndexPath = .just(.setSelectedIndexPath(indexPath))
            }
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
    
            return .concat(setSections, setSelectedIndexPath, sectionReload)
        case let .selectBadge(indexPath):
            return .just(.setSelectedIndexPath(indexPath))
        case let .moveBadge(at: sourceIndexPath, to: destinationIndexPath):
            let swapItem: Observable<Mutation> = .just(.swapItem(at: sourceIndexPath, to: destinationIndexPath))
            // Update selected index path
            var setSelectedIndexPath: Observable<Mutation>
            if currentState.selectedIndexPath == sourceIndexPath {
                setSelectedIndexPath = .just(.setSelectedIndexPath(destinationIndexPath))
            } else if currentState.selectedIndexPath == destinationIndexPath {
                setSelectedIndexPath = .just(.setSelectedIndexPath(sourceIndexPath))
            } else {
                setSelectedIndexPath = .empty()
            }
            return .concat(swapItem, setSelectedIndexPath)
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
            if let previousIndexPath = state.selectedIndexPath {
                state.sections[0].items[previousIndexPath.row].item?.action.onNext(.select(false))
            }
            state.sections[0].items[indexPath.row].item?.action.onNext(.select(true))
            
            state.selectedIndexPath = indexPath
            return state
        case let .swapItem(at: sourceIndexPath, to: destinationIndexPath):
            state.sections[0].items.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            
            var items = state.sections[0].items
            items[sourceIndexPath.row].item?.action.onNext(.updateIndex(sourceIndexPath.row + 1))
            items[destinationIndexPath.row].item?.action.onNext(.updateIndex(destinationIndexPath.row + 1))
            
            return state
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
}
