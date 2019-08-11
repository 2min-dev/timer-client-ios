//
//  TimeSetSaveViewReactor.swift
//  timer
//
//  Created by JSilver on 31/07/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetSaveViewReactor: Reactor {
    static let MAX_TITLE_LENGTH = 20
    
    enum Action {
        case viewWillAppear
        
        case clearTitle
        case updateTitle(String)
        
        case deleteTimer
        case selectTimer(at: IndexPath)
        
        case applyAlarm(String)
        
        case saveTimeSet
    }
    
    enum Mutation {
        case setTitle(String)
        case setHint(String)
        case removeTimer(at: Int)
        case setSelectedIndexPath(at: IndexPath)
        
        case setSavedTimeSet(info: TimeSetInfo)
        
        case setAlertMessage(String)
        case sectionReload
    }
    
    struct State {
        var title: String                   // Title of time set
        var hint: String                    // Title hint of time set
        let sumOfTimers: TimeInterval       // The time that sum of all timers
        
        var timers: [TimerInfo]             // The timer list model of time set
        var selectedIndexPath: IndexPath    // Current selected timer index path
        
        var savedTimeSet: TimeSetInfo?      // The saved time set
        
        var alertMessage: String?           // Alert message
        var shouldSectionReload: Bool       // Need section reload
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    let timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, timeSetInfo: TimeSetInfo) {
        self.timeSetService = timeSetService
        self.timeSetInfo = timeSetInfo
        self.initialState = State(title: timeSetInfo.title,
                                  hint: "",
                                  sumOfTimers: timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                                  timers: timeSetInfo.timers,
                                  selectedIndexPath: IndexPath(row: 0, section: 0),
                                  savedTimeSet: nil,
                                  alertMessage: nil,
                                  shouldSectionReload: true)
    }
    
    // MARK: - Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
        case .clearTitle:
            return actionClearTitle()
        case let .updateTitle(title):
            return actionUpdateTitle(title)
        case .deleteTimer:
            return actionDeleteTimer()
        case let .selectTimer(at: indexPath):
            return actionSelectTimer(at: indexPath)
        case let .applyAlarm(alarm):
            return actionApplyAlarm(alarm)
        case .saveTimeSet:
            return actionSaveTimeSet()
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
        case let .setHint(hint):
            state.hint = hint
            return state
        case let .removeTimer(at: index):
            state.timers.remove(at: index)
            return state
        case let .setSelectedIndexPath(at: indexPath):
            state.selectedIndexPath = indexPath
            return state
        case let .setSavedTimeSet(info: timeSetInfo):
            state.savedTimeSet = timeSetInfo
            return state
        case let .setAlertMessage(message):
            state.alertMessage = message
            return state
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MAKR: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        // Set hint after fetch time set list
        let setHint: Observable<Mutation> = timeSetService.fetchTimeSets().asObservable()
            .map { $0.count + 1 }
            .map { String(format: "time_set_default_title".localized, $0) }
            .flatMap { Observable.just(Mutation.setHint($0)) }
        
        return .concat(setHint)
    }
    
    private func actionClearTitle() -> Observable<Mutation> {
        return .just(.setTitle(""))
    }
    
    private func actionUpdateTitle(_ title: String) -> Observable<Mutation> {
        let length = title.lengthOfBytes(using: .utf8)
        guard length <= TimeSetSaveViewReactor.MAX_TITLE_LENGTH else { return .just(.setTitle(timeSetInfo.title)) }
        
        // Update title
        timeSetInfo.title = title
        
        return .just(.setTitle(title))
    }
    
    private func actionDeleteTimer() -> Observable<Mutation> {
        let index = currentState.selectedIndexPath.row
        guard index > 0 else { return .empty() }
        
        // Remove timer
        timeSetInfo.timers.remove(at: index)
        
        var setSelectIndexPath: Observable<Mutation> = actionSelectTimer(at: currentState.selectedIndexPath)
        let removeTimer: Observable<Mutation> = .just(.removeTimer(at: index))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        if index == timeSetInfo.timers.count {
            // Last timer deleted
            let indexPath = IndexPath(row: index - 1, section: 0)
            setSelectIndexPath = actionSelectTimer(at: indexPath)
        }
        
        return .concat(setSelectIndexPath, removeTimer, sectionReload)
    }
    
    private func actionSelectTimer(at indexPath: IndexPath) -> Observable<Mutation> {
        return .just(.setSelectedIndexPath(at: indexPath))
    }
    
    private func actionApplyAlarm(_ alarm: String) -> Observable<Mutation> {
        timeSetInfo.timers.forEach { $0.alarm = alarm }
        return .just(.setAlertMessage("alert_alarm_all_apply_description".localized))
    }
    
    private func actionSaveTimeSet() -> Observable<Mutation> {
        if timeSetInfo.title.isEmpty {
            // Set title from hint if it's nil
            timeSetInfo.title = currentState.hint
        }
        
        if timeSetInfo.id == nil {
            return timeSetService.createTimeSet(info: timeSetInfo)
                .asObservable()
                .flatMap { Observable<Mutation>.just(.setSavedTimeSet(info: $0))}
        } else {
            return timeSetService.updateTimeSet(info: timeSetInfo)
                .asObservable()
                .flatMap { Observable<Mutation>.just(.setSavedTimeSet(info: $0))}
        }
    }
}
