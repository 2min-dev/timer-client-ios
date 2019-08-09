//
//  TimeSetDetailViewReactor.swift
//  timer
//
//  Created by JSilver on 06/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetDetailViewReactor: Reactor {
    enum Action {
        case toggleBookmark
        case toggleLoop
        case selectTimer(at: IndexPath)
    }
    
    enum Mutation {
        case setBookmark(Bool)
        case setLoop(Bool)
        case setTimer(at: Int)
        case setSelectedIndexPath(at: IndexPath)
    }
    
    struct State {
        var isBookmark: Bool
        
        let title: String
        let sumOfTimers: TimeInterval
        var isLoop: Bool
        
        let timers: [TimerInfo]
        var selectedIndexPath: IndexPath
        var timer: TimerInfo
        
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        self.timeSetInfo = timeSetInfo
        // TODO: Time set info <- bookmark
        self.initialState = State(isBookmark: false,
                                  title: timeSetInfo.title,
                                  sumOfTimers: timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  isLoop: false,
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  timer: timeSetInfo.timers[0],
                                  shouldSectionReload: true)
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleLoop:
            timeSetInfo.isLoop.toggle()
            return .just(.setLoop(!currentState.isLoop))
        case .toggleBookmark:
            // TODO: Set bookmark in time set info
            return .just(.setBookmark(!currentState.isBookmark))
        case let .selectTimer(at: indexPath):
            let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(at: indexPath))
            let setTimer: Observable<Mutation> = .just(.setTimer(at: indexPath.row))
            return .concat(setSelectedIndexPath, setTimer)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setLoop(isLoop):
            state.isLoop = isLoop
            return state
        case let .setBookmark(isBookmark):
            state.isBookmark = isBookmark
            return state
        case let .setTimer(at: index):
            state.timer = state.timers[index]
            return state
        case let .setSelectedIndexPath(at: indexPath):
            state.selectedIndexPath = indexPath
            return state
        }
    }
    
    // MARK: - priate method
    // MARK: - public method
}
