//
//  ProductivityViewReactor.swift
//  timerset-ios
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

class ProductivityViewReactor: Reactor {
    enum Action {
        case updateTimeInput(Int)
        case tapTimeKey(ProductivityView.TimeKey)
        case clearTimer
        case toggleLoop
        case toggleVibrationAlert
    }
    
    enum Mutation {
        case setTime(Int)
        case setTimer(TimeInterval)
        case setLoop(Bool)
        case setVibrationAlert(Bool)
    }
    
    struct State {
        var time: Int
        var timer: TimeInterval
        var loop: Bool
        var vibationAlert: Bool
    }
    
    // MARK: properties
    var initialState: State
    private let timerService: TimerSetServicePorotocol
    
    init(timerService: TimerSetServicePorotocol) {
        self.initialState = State(time: 0, timer: 0, loop: false, vibationAlert: false)
        self.timerService = timerService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateTimeInput(time):
            return Observable.just(Mutation.setTime(time))
        case let .tapTimeKey(key):
            var timeInterval = currentState.timer
            switch key {
            case .hour:
                timeInterval += Double(currentState.time * Constants.Time.hour)
            case .minute:
                timeInterval += Double(currentState.time * Constants.Time.minute)
            case .second:
                timeInterval += Double(currentState.time)
            }
            return Observable.concat(Observable.just(Mutation.setTimer(timeInterval)), Observable.just(Mutation.setTime(0)))
        case .clearTimer:
            return Observable.concat(Observable.just(Mutation.setTimer(0)), Observable.just(Mutation.setTime(0)))
        case .toggleLoop:
            return Observable.just(Mutation.setLoop(!currentState.loop))
        case .toggleVibrationAlert:
            return Observable.just(Mutation.setVibrationAlert(!currentState.vibationAlert))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setTime(time):
            state.time = time
            return state
        case let .setTimer(timeInterval):
            state.timer = timeInterval
            return state
        case let .setLoop(loop):
            state.loop = loop
            return state
        case let .setVibrationAlert(vibrationAlert):
            state.vibationAlert = vibrationAlert
            return state
        }
    }
}
