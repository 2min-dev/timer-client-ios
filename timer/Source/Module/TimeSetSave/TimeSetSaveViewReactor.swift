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
        case setTimer(TimerItem)
        
        /// Set selected index
        case setSelectedIndex(at: Int)
        
        /// Set saved time set item
        case setSavedTimeSet(item: TimeSetItem)
    }
    
    struct State {
        /// Title of time set
        var title: String
        
        /// Title hint of time set
        var hint: String
        
        /// All time of time set
        var allTime: TimeInterval
        
        /// Selected timer of time set
        var timer: TimerItem
        
        /// The timer list badge sections
        var sections: RevisionValue<[TimerBadgeSectionModel]>
        
        /// Current selected timer index
        var selectedIndex: Int
        
        /// The saved time set
        var savedTimeSet: TimeSetItem?
        
        /// Need section reload
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    private let logger: Logger
    
    let timeSetItem: TimeSetItem
    private var dataSource: TimerBadgeSectionDataSource
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, logger: Logger, timeSetItem: TimeSetItem) {
        self.timeSetService = timeSetService
        self.logger = logger
        self.timeSetItem = timeSetItem
        
        // Create seciont datasource
        dataSource = TimerBadgeSectionDataSource(regulars: timeSetItem.timers.toArray(), index: 0)
        
        initialState = State(title: timeSetItem.title,
                             hint: "",
                             allTime: timeSetItem.timers.reduce(0) { $0 + $1.end },
                             timer: timeSetItem.timers.first ?? TimerItem(),
                             sections: RevisionValue(dataSource.makeSections()),
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
            state.selectedIndex = index
            return state
            
        case let .setSavedTimeSet(item: timeSetItem):
            state.savedTimeSet = timeSetItem
            return state
        }
    }
    
    // MAKR: - action method
    private func actionViewWillAppear() -> Observable<Mutation> {
        // Set hint
        let hint = timeSetItem.title.isEmpty ? String(format: "time_set_default_title".localized) : timeSetItem.title
        return .just(.setHint(hint))
    }
    
    private func actionClearTitle() -> Observable<Mutation> {
        // Clear titile
        timeSetItem.title = ""
        
        return .just(.setTitle(""))
    }
    
    private func actionUpdateTitle(_ title: String) -> Observable<Mutation> {
        // Update title
        timeSetItem.title = title
        
        return .just(.setTitle(title))
    }
    
    private func actionSelectTimer(at index: Int) -> Observable<Mutation> {
        guard index >= 0 && index < timeSetItem.timers.count else { return .empty() }
        
        let state = currentState
        let previousIndex = state.selectedIndex
        
        // Update selected timer state
        if index != previousIndex {
            dataSource.setSelected(false, at: previousIndex)
        }
        dataSource.setSelected(true, at: index)
        
        let setSelectedIndex: Observable<Mutation> = .just(.setSelectedIndex(at: index))
        let setTimer: Observable<Mutation> = .just(.setTimer(timeSetItem.timers[index]))
        
        return .concat(setSelectedIndex, setTimer)
    }
    
    private func actionSaveTimeSet() -> Observable<Mutation> {
        if timeSetItem.title.isEmpty {
            // Set title from hint if it's nil
            timeSetItem.title = currentState.hint
        }
        
        if timeSetItem.id < 0 {
            // Create time set
            return timeSetService.createTimeSet(item: timeSetItem).asObservable()
                .do(onNext: { _ in
                    // Log save time set event
                    self.logger.logEvent(.click, parameters: [
                        .componentName: "save_time_set",
                        .text: "create"
                    ])
                })
                .flatMap { Observable<Mutation>.just(.setSavedTimeSet(item: $0))}
        } else {
            // Update time set
            return timeSetService.updateTimeSet(item: timeSetItem).asObservable()
                .flatMap { Observable<Mutation>.just(.setSavedTimeSet(item: $0))}
        }
    }
    
    deinit {
        Logger.verbose()
    }
}
