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
        /// Set title hint from time set list data when view will appear
        case viewWillAppear
        
        /// Clear title text
        case clearTitle
        
        /// Update title text
        case updateTitle(String)
        
        /// Select timer
        case selectTimer(at: Int)
        
        /// Save time set
        case saveTimeSet
    }
    
    enum Mutation {
        /// Set time set title
        case setTitle(String)
        
        /// Set time set title hint
        case setHint(String)
        
        /// Set all time of time set
        case setAllTime(TimeInterval)
        
        /// Set current selected timer
        case setTimer(TimerInfo)
        
        /// Set selected index
        case setSelectedIndex(at: Int)
        
        /// Set saved time set info
        case setSavedTimeSet(info: TimeSetInfo)
    }
    
    struct State {
        /// Title of time set
        var title: String
        
        /// Title hint of time set
        var hint: String
        
        /// All time of time set
        var allTime: TimeInterval
        
        /// Selected timer of time set
        var timer: TimerInfo
        
        /// Section datasource to make sections
        let sectionDataSource: TimerBadgeDataSource
        
        /// The timer list badge sections
        var sections: [TimerBadgeSectionModel] {
            sectionDataSource.makeSections()
        }
        
        /// Current selected timer index
        var selectedIndex: Int
        
        /// The saved time set
        var savedTimeSet: TimeSetInfo?
        
        /// Need section reload
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    let timeSetInfo: TimeSetInfo
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, timeSetInfo: TimeSetInfo) {        
        self.timeSetService = timeSetService
        self.timeSetInfo = timeSetInfo
        
        // Create seciont datasource
        let dataSource = TimerBadgeDataSource(timers: self.timeSetInfo.timers.toArray(), index: 0)
        
        initialState = State(title: timeSetInfo.title,
                             hint: "",
                             allTime: timeSetInfo.timers.reduce(0) { $0 + $1.endTime },
                             timer: timeSetInfo.timers.first ?? TimerInfo(),
                             sectionDataSource: dataSource,
                             selectedIndex: 0,
                             shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return actionViewWillAppear()
            
        case .clearTitle:
            return actionClearTitle()
            
        case let .updateTitle(title):
            return actionUpdateTitle(title)
            
        case let .selectTimer(at: index):
            return actionSelectTimer(at: index)
            
        case .saveTimeSet:
            return actionSaveTimeSet()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setTitle(title):
            state.title = title
            return state
            
        case let .setHint(hint):
            state.hint = hint
            return state
            
        case let .setAllTime(timeInterval):
            state.allTime = timeInterval
            return state
            
        case let .setTimer(timer):
            state.timer = timer
            return state
            
        case let .setSelectedIndex(at: index):
            let section: Int = TimerBadgeSectionType.regular.rawValue
            guard index >= 0 && index < state.sections[section].items.count else { return state }
            
            state.selectedIndex = index
            return state
            
        case let .setSavedTimeSet(info: timeSetInfo):
            state.savedTimeSet = timeSetInfo
            return state
        }
    }
    
    // MAKR: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        // Set hint
        let hint = timeSetInfo.title.isEmpty ? String(format: "time_set_default_title".localized) : timeSetInfo.title
        return .just(.setHint(hint))
    }
    
    private func actionClearTitle() -> Observable<Mutation> {
        // Clear titile
        timeSetInfo.title = ""
        
        return .just(.setTitle(""))
    }
    
    private func actionUpdateTitle(_ title: String) -> Observable<Mutation> {
        // Update title
        timeSetInfo.title = title
        
        return .just(.setTitle(title))
    }
    
    private func actionSelectTimer(at index: Int) -> Observable<Mutation> {
        guard index >= 0 && index < timeSetInfo.timers.count else { return .empty() }
        
        let state = currentState
        let previousIndex = state.selectedIndex
        
        // Update selected timer state
        if index != previousIndex {
            state.sectionDataSource.regulars[previousIndex].action.onNext(.select(false))
        }
        state.sectionDataSource.regulars[index].action.onNext(.select(true))
        
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(at: index))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSetInfo.timers[index]))
        
        return .concat(setSelectedIndex, setTimer)
    }
    
    private func actionSaveTimeSet() -> Observable<Mutation> {
        if timeSetInfo.title.isEmpty {
            // Set title from hint if it's nil
            timeSetInfo.title = currentState.hint
        }
        
        if timeSetInfo.id == nil {
            // Create time set
            return timeSetService.createTimeSet(info: timeSetInfo).asObservable()
                .flatMap { Observable<Mutation>.just(.setSavedTimeSet(info: $0))}
        } else {
            // Update time set
            return timeSetService.updateTimeSet(info: timeSetInfo).asObservable()
                .flatMap { Observable<Mutation>.just(.setSavedTimeSet(info: $0))}
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
