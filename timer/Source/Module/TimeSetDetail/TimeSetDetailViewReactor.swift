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
    enum TimeSetType {
        case saved
        case recentlyUsed
        case preset
        
        fileprivate var logText: String {
            switch self {
            case .saved:
                return "saved"
                
            case .recentlyUsed:
                return "history"
                
            case .preset:
                return "preset"
            }
        }
    }
    
    enum Action {
        /// Select the timer
        case selectTimer(at: Int)
        
        /// Save the time set
        case saveTimeSet
        
        /// Start the time set
        case startTimeSet
    }
    
    enum Mutation {
        /// Set current timer
        case setTimer(TimerItem)
        
        /// Set selected index
        case setSelectedIndex(at: Int)
        
        /// Save the time set
        case save
    }
    
    struct State {
        /// Type of time set
        let type: TimeSetType
        
        /// Title of time set
        let title: String
        
        /// All time of time set
        let allTime: TimeInterval
        
        /// Current selected timer
        var timer: TimerItem
        
        /// The timer list badge sections
        var sections: RevisionValue<[TimerBadgeSectionModel]>
        
        /// Current selected timer index
        var selectedIndex: Int
        
        /// Flag that represent current time set can save
        var canTimeSetSave: Bool
        
        /// Flag that time set is saved
        var didTimeSetSaved: RevisionValue<Bool>
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    private let logger: Logger
    
    private(set) var timeSetItem: TimeSetItem
    
    private let dataSource: TimerBadgeSectionDataSource
    
    // MARK: - constructor
    init(timeSetService: TimeSetServiceProtocol, logger: Logger, timeSetItem: TimeSetItem, type: TimeSetType) {
        self.timeSetService = timeSetService
        self.logger = logger
        
        self.timeSetItem = timeSetItem
        
        // Create seciont datasource
        dataSource = TimerBadgeSectionDataSource(regulars: timeSetItem.timers.toArray(), index: 0)
        
        initialState = State(
            type: type,
            title: timeSetItem.title,
            allTime: timeSetItem.timers.reduce(0) { $0 + $1.end },
            timer: timeSetItem.timers.first ?? TimerItem(),
            sections: RevisionValue(dataSource.makeSections()),
            selectedIndex: 0,
            canTimeSetSave: type != .saved,
            didTimeSetSaved: RevisionValue(false)
        )
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .selectTimer(at: index):
            return actionSelectTimer(at: index)
            
        case .saveTimeSet:
            return actionSaveTimeSet()
            
        case .startTimeSet:
            return actionStartTimeSet()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setTimer(timer):
            state.timer = timer
            return state
            
        case let .setSelectedIndex(at: index):
            state.selectedIndex = index
            return state
            
        case .save:
            state.canTimeSetSave = false
            state.didTimeSetSaved = state.didTimeSetSaved.next(true)
            return state
        }
    }
    
    // MARK: - action method
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
        guard let timeSetItem = timeSetItem.copy() as? TimeSetItem else { return .empty() }
        
        // Create the time set
        return timeSetService.createTimeSet(item: timeSetItem)
            .do(onSuccess: { self.timeSetItem = $0 })
            .do(onSuccess: { _ in
                // Log save time set event
                self.logger.logEvent(.click, parameters: [
                    .componentName: "save_time_set",
                    .text: self.currentState.type.logText
                ])
            })
            .asObservable()
            .map { _ in .save }
    }
    
    private func actionStartTimeSet() -> Observable<Mutation> {
        logger.logEvent(.click, parameters: [
            .componentName: "start_time_set",
            .text: currentState.type.logText
        ])
        return .empty()
    }
    
    deinit {
        Logger.verbose()
    }
}
