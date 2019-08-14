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
        /// Update time set info
        case viewWillAppear
        
        /// Toggle time set bookmark
        case toggleBookmark
        
        /// Toggle time set loop
        case toggleRepeat
        
        /// Select the timer
        case selectTimer(at: IndexPath)
    }
    
    enum Mutation {
        /// Set time set bookmark
        case setBookmark(Bool)
        
        /// Set time set repeat
        case setRepeat(Bool)
        
        /// Set current timer
        case setTimer(TimerInfo)
        
        /// Set selected index path
        case setSelectedIndexPath(at: IndexPath)
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Time set bookmarked mark
        var isBookmark: Bool
        
        /// Title of time set
        let title: String
        
        /// Sum of timers end time
        let sumOfTimers: TimeInterval
        
        /// Time set repeat mark
        var isRepeat: Bool
        
        /// Timers of time set
        let timers: [TimerInfo]
        
        /// Current selected timer
        var timer: TimerInfo
        
        /// Current selected timer index path
        var selectedIndexPath: IndexPath
        
        /// Need section reload
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    var timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        self.timeSetInfo = timeSetInfo
        
        self.initialState = State(isBookmark: self.timeSetInfo.isBookmark,
                                  title: self.timeSetInfo.title,
                                  sumOfTimers: self.timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  isRepeat: self.timeSetInfo.isRepeat,
                                  timers: self.timeSetInfo.timers,
                                  timer: self.timeSetInfo.timers.first!,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  shouldSectionReload: true)
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
            
        case .toggleRepeat:
            return actiontoggleRepeat()
            
        case .toggleBookmark:
            return actionToggleBookmark()
            
        case let .selectTimer(at: indexPath):
            return actionSelectTimer(at: indexPath)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setBookmark(isBookmark):
            state.isBookmark = isBookmark
            return state
            
        case let .setRepeat(isRepeat):
            state.isRepeat = isRepeat
            return state
            
        case let .setTimer(timer):
            state.timer = timer
            return state
            
        case let .setSelectedIndexPath(at: indexPath):
            state.selectedIndexPath = indexPath
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        return .just(.setBookmark(timeSetInfo.isBookmark))
    }
    
    private func actiontoggleRepeat() -> Observable<Mutation> {
        // Toggle time set loop option
        timeSetInfo.isRepeat.toggle()
        return .just(.setRepeat(!currentState.isRepeat))
    }
    
    private func actionToggleBookmark() -> Observable<Mutation> {
        // Toggle time set bookmark
        timeSetInfo.isBookmark.toggle()
        return .just(.setBookmark(!currentState.isBookmark))
    }
    
    private func actionSelectTimer(at indexPath: IndexPath) -> Observable<Mutation> {
        guard indexPath.row < timeSetInfo.timers.count else { return .empty() }
        
        return .concat(.just(.setSelectedIndexPath(at: indexPath)),
                       .just(.setTimer(timeSetInfo.timers[indexPath.row])))
    }
}
