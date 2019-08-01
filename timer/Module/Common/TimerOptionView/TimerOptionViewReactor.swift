//
//  TimerOptionViewReactor.swift
//  timer
//
//  Created by JSilver on 25/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimerOptionViewReactor: Reactor {
    // MARK: - constants
    static let MAX_COMMENT_LENGTH: Int = 50
    
    enum Action {
        case viewWillAppear
        case changeTimer(TimerInfo)
        case updateComment(String)
        case updateAlarm(String)
    }
    
    enum Mutation {
        case setTitle(String)
        case setComment(String)
        case setAlarm(String)
    }
    
    struct State {
        var title: String           // Title of the timer
        var comment: String         // Comment of the timer
        var alarm: String           // Alarm of the timer
    }
    
    // MARK: - properties
    var initialState: State
    var timerInfo: TimerInfo?
    
    // MARK: - constructor
    init() {
        self.initialState = State(title: "",
                                  comment: "",
                                  alarm: "")
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            guard let timerInfo = timerInfo else { return .empty() }
            return mutate(action: .changeTimer(timerInfo))
        case let .changeTimer(timerInfo):
            // Change current timer
            self.timerInfo = timerInfo
            
            let setTitle: Observable<Mutation> = .just(.setTitle(timerInfo.title))
            let setComment: Observable<Mutation> = .just(.setComment(timerInfo.comment))
            let setAlarm: Observable<Mutation> = .just(.setAlarm(timerInfo.alarm))
            
            return .concat(setTitle, setComment, setAlarm)
        case let .updateComment(comment):
            // Update timer's comment
            guard let timerInfo = timerInfo else { return .empty() }
            let length = comment.lengthOfBytes(using: .utf8)
            
            guard length <= TimerOptionViewReactor.MAX_COMMENT_LENGTH else {
                return .just(.setComment(timerInfo.comment))
            }
            
            timerInfo.comment = comment
            
            return .just(.setComment(comment))
        case let .updateAlarm(alarm):
            // Update alarm title
            timerInfo?.alarm = alarm
            return .just(.setAlarm(alarm))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setTitle(title):
            state.title = title
            return state
        case let .setComment(comment):
            state.comment = comment
            return state
        case let .setAlarm(alarm):
            state.alarm = alarm
            return state
        }
    }
}
