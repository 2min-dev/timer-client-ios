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
        case changeTimer(TimerInfo)
        case updateComment(String)
        case updateAlarm(String)
    }
    
    enum Mutation {
        case setTitle(String)
        case setAlarm(String)
        case setComment(String)
    }
    
    struct State {
        var title: String
        var comment: String
        var alarm: String
    }
    
    // MARK: - properties
    var initialState: State
    private var timerInfo: TimerInfo
    
    // MARK: - constructor
    init() {
        self.timerInfo = TimerInfo(title: "default")
        self.initialState = State(title: self.timerInfo.title,
                                  comment: self.timerInfo.comment,
                                  alarm: self.timerInfo.alarm)
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .changeTimer(timerInfo):
            self.timerInfo = timerInfo
            
            let setTitle: Observable<Mutation> = .just(.setTitle(timerInfo.title))
            let setComment: Observable<Mutation> = .just(.setComment(timerInfo.comment))
            let setAlarm: Observable<Mutation> = .just(.setAlarm(timerInfo.alarm))
            
            return .concat(setTitle, setComment, setAlarm)
        case let .updateComment(comment):
            let length = comment.lengthOfBytes(using: .utf8)
            
            var setComment: Observable<Mutation> = .just(.setComment(timerInfo.comment))
            if length < TimerOptionViewReactor.MAX_COMMENT_LENGTH {
                timerInfo.comment = comment
                setComment = .just(.setComment(comment))
            }
            
            return setComment
        case let .updateAlarm(alarm):
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
