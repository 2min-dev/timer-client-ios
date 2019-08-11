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
            return actionViewWillAppear()
        case let .changeTimer(timerInfo):
            return actionChangeTimer(info: timerInfo)
        case let .updateComment(comment):
            return actionUpdateComment(comment)
        case let .updateAlarm(alarm):
            return actionUpdateAlarm(alarm)
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
    
    // MARK: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        guard let timerInfo = timerInfo else { return .empty() }
        return actionChangeTimer(info: timerInfo)
    }
    
    private func actionChangeTimer(info: TimerInfo) -> Observable<Mutation> {
        // Change current timer
        timerInfo = info
        return .concat(.just(.setTitle(info.title)),
                       .just(.setComment(info.comment)),
                       .just(.setAlarm(info.alarm)))
    }
    
    private func actionUpdateComment(_ comment: String) -> Observable<Mutation> {
        // Update timer's comment
        guard let timerInfo = timerInfo else { return .empty() }
        let length = comment.lengthOfBytes(using: .utf8)
        
        guard length <= TimerOptionViewReactor.MAX_COMMENT_LENGTH else {
            return .just(.setComment(timerInfo.comment))
        }
        
        timerInfo.comment = comment
        
        return .just(.setComment(comment))
    }
    
    private func actionUpdateAlarm(_ alarm: String) -> Observable<Mutation> {
        // Update alarm title
        timerInfo?.alarm = alarm
        return .just(.setAlarm(alarm))
    }
}
