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
    static let MAX_TITLE_LENGTH = 20
    
    enum Action {
        case viewDidLoad
        case clearTitle
        case updateTitle(String)
        
        case deleteTimer
        case selectTimer(at: IndexPath)
        
        case applyAlarm(String)
    }
    
    enum Mutation {
        case setTitle(String)
        case removeTimer(at: Int)
        case setSelectedIndexPath(at: IndexPath)
        
        case setAlertMessage(String)
        case sectionReload
    }
    
    struct State {
        var title: String                   // Title of time set
        var hint: String                    // Title hint of time set
        let sumOfTimers: TimeInterval       // The time that sum of all timers
        
        var timers: [TimerInfo]             // The timer list model of time set
        var selectedIndexPath: IndexPath    // Current selected timer index path
        
        var alertMessage: String?           // Alert message
        var shouldSectionReload: Bool       // Need section reload
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetInfo: TimeSetInfo) {
        self.timeSetInfo = timeSetInfo
        self.initialState = State(title: timeSetInfo.title,
                                  hint: "생산성",
                                  sumOfTimers: timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  alertMessage: nil,
                                  shouldSectionReload: true)
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // TODO: Set time set hint after get time set list
            return .empty()
        case .clearTitle:
            return .just(.setTitle(""))
        case let .updateTitle(title):
            let length = title.lengthOfBytes(using: .utf8)
            guard length <= TimeSetEditViewReactor.MAX_TITLE_LENGTH else { return .just(.setTitle(timeSetInfo.title)) }
            
            timeSetInfo.title = title
            return .just(.setTitle(title))
        case .deleteTimer:
            let index = currentState.selectedIndexPath.row
            guard index > 0 else { return .empty() }
            
            timeSetInfo.timers.remove(at: index)
            
            var setSelectIndexPath: Observable<Mutation> = mutate(action: .selectTimer(at: currentState.selectedIndexPath))
            let removeTimer: Observable<Mutation> = .just(.removeTimer(at: index))
            let sectionReload: Observable<Mutation> = .just(.sectionReload)
            
            if index == timeSetInfo.timers.count {
                // Last timer deleted
                let indexPath = IndexPath(row: index - 1, section: 0)
                setSelectIndexPath = mutate(action: .selectTimer(at: indexPath))
            }
            
            return .concat(setSelectIndexPath, removeTimer, sectionReload)
        case let .selectTimer(at: indexPath):
            return .just(.setSelectedIndexPath(at: indexPath))
        case let .applyAlarm(alarm):
            timeSetInfo.timers.forEach { $0.alarm = alarm }
            return .just(.setAlertMessage("알람이 전체 적용 되었습니다."))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        state.alertMessage = nil
        
        switch mutation {
        case let .setTitle(title):
            state.title = title
            return state
        case let .removeTimer(at: index):
            state.timers.remove(at: index)
            return state
        case let .setSelectedIndexPath(at: indexPath):
            state.selectedIndexPath = indexPath
            return state
        case let .setAlertMessage(message):
            state.alertMessage = message
            return state
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
}
