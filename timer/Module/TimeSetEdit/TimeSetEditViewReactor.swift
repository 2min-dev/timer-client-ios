//
//  TimeSetEditViewReactor.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetEditViewReactor: Reactor {
    enum Action {
        
    }
    
    enum Mutation {
        case sectionReload
    }
    
    struct State {
        let title: String                   // Title of time set
        let sumOfTimers: TimeInterval       // The time that sum of all timers
        var isStartAfterSave: Bool          // Is time set start after it save
        
        var timers: [TimerInfo]             // The timer list model of time set
        var selectedIndexPath: IndexPath    // Current selected timer index path
        
        var shouldSectionReload: Bool       // Need section reload
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        self.timeSetInfo = timeSetInfo
        self.initialState = State(title: timeSetInfo.title,
                                  sumOfTimers: timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  isStartAfterSave: false,
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  shouldSectionReload: true)
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
}
