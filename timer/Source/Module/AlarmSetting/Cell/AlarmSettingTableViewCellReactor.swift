//
//  AlarmSettingTableViewCellReactor.swift
//  timer
//
//  Created by JSilver on 2019/11/19.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class AlarmSettingTableViewCellReactor: Reactor {
    enum AlarmState {
        case stop
        case play
    }
    
    enum Action {
        /// Stop alarm
        case stop
        
        /// Play alarm
        case play
    }
    
    enum Mutation {
        /// Set alarm state
        case setAlarmState(AlarmState)
    }
    
    struct State {
        /// Title of alarm
        let title: String
        
        /// Current alarm play state
        var alarmState: AlarmState
    }
    
    // MARK: - properties
    var initialState: State
    let alarm: Alarm
    
    // MARK: - constructor
    init(alarm: Alarm) {
        self.alarm = alarm
        initialState = State(title: alarm.title,
                             alarmState: .stop)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .stop:
            return .just(.setAlarmState(.stop))
            
        case .play:
            return .just(.setAlarmState(.play))
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setAlarmState(alarmState):
            state.alarmState = alarmState
            return state
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
