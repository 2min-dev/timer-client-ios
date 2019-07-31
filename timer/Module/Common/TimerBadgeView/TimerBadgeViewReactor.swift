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
        case updateTimer(TimeInterval)
        case selectBadge(IndexPath)
    }
    
    enum Mutation {
        case setSections([TimerBadgeSectionModel])
        case setSelectedIndexPath(IndexPath)
        case updateTimer(TimeInterval, at: IndexPath)
    }
    
    struct State {
        var sections: [TimerBadgeSectionModel]
        var selectedIndexPath: IndexPath?
    }
    
    // MARK: - properties
    var initialState: State
    
    init() {
        self.initialState = State(sections: [TimerBadgeSectionModel(model: Void(), items: [])], selectedIndexPath: nil)
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
            
            let setSections = Observable.just(Mutation.setSections([TimerBadgeSectionModel(model: Void(), items: items)]))
            let setSelectedIndexPath = currentState.selectedIndexPath == nil ?
                Observable.just(Mutation.setSelectedIndexPath(IndexPath(row: 0, section: 0))) :
                Observable.just(Mutation.setSelectedIndexPath(IndexPath(row: timers.count - 1, section: 0)))
    
            return .concat(setSections, setSelectedIndexPath)
        case let .updateTimer(timeInterval):
            guard let indexPath = currentState.selectedIndexPath else { return .empty() }
            return .just(.updateTimer(timeInterval, at: indexPath))
        case let .selectBadge(indexPath):
            return .just(.setSelectedIndexPath(indexPath))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
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
        case let .updateTimer(timeInterval, at: indexPath):
            state.sections[0].items[indexPath.row].item?.action.onNext(.updateTime(timeInterval))
            return state
        }
    }
}
