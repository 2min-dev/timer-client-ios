//
//  HistoryDetailViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

class HistoryDetailViewReactor: Reactor {
    enum Action {
        /// Update history to save
        case saveHistory
        
        /// Update memo of current time set
        case updateMemo(String)
        
        /// Save the time set
        case saveTimeSet
        
        /// Start the time set
        case startTimeSet
    }
    
    enum Mutation {
        /// Set memo of the time set
        case setMemo(String)
        
        /// Set did time set saved flag to `true`
        case save
        
        /// Set can start time set flag to `true`
        case start
    }
    
    struct State {
        /// Title of the time set
        let title: String
        
        /// Total running time of the time set
        let runningTime: TimeInterval
        
        /// Started date of the time set
        let startDate: Date
        
        /// Ended date of the time set
        let endDate: Date
        
        /// Extra added time of the time set
        let extraTime: TimeInterval
        
        /// Repeat count of the time set
        let repeatCount: Int
        
        /// Memo of the time set
        var memo: String
        
        /// End state of the time set
        let endState: History.EndState
        
        /// End index of the time set
        let endIndex: Int
        
        /// Remained time of the time set
        let remainedTime: TimeInterval
        
        /// Overtime of the time set
        let overtime: TimeInterval
        
        /// The timer list badge sections
        var sections: RevisionValue<[TimerBadgeSectionModel]>
        
        /// Flag that represent current time set can save
        var canTimeSetSave: Bool
        
        /// Flag that represent time set saved
        var didTimeSetSaved: RevisionValue<Bool>
        
        /// Flag that time set ready to start
        var canStartTimeSet: RevisionValue<Bool>
    }
    
    // MARK: - properties
    var initialState: State
    private let historyService: HistoryServiceProtocol
    private let timeSetService: TimeSetServiceProtocol
    private let logger: Logger
    
    private let history: History
    private(set) var timeSetItem: TimeSetItem
    
    private var dataSource: TimerBadgeSectionDataSource
    
    // MARK: - constructor
    init?(historyService: HistoryServiceProtocol, timeSetService: TimeSetServiceProtocol, logger: Logger, history: History, canSave: Bool) {
        // Check required properties of history
        guard let item = history.item,
            let startDate = history.startDate,
            let endDate = history.endDate else {
                Logger.error("history object not fulfill required properties", tag: "HISTORY DETAIL")
                return nil
        }
        
        guard let timeSetItem = item.copy() as? TimeSetItem else { return nil }
        timeSetItem.reset()
        
        self.historyService = historyService
        self.timeSetService = timeSetService
        self.logger = logger
        self.history = history
        self.timeSetItem = timeSetItem
        
        dataSource = TimerBadgeSectionDataSource(regulars: item.timers.toArray())
        
        initialState = State(
            title: item.title,
            runningTime: history.runningTime,
            startDate: startDate,
            endDate: endDate,
            extraTime: history.extraTime,
            repeatCount: history.repeatCount,
            memo: history.memo,
            endState: history.endState,
            endIndex: history.endIndex,
            remainedTime: item.timers.enumerated()
                .filter { $0.offset >= history.endIndex }
                .map { $0.element }
                .reduce(0) { $0 + ($1.end - $1.current) },
            overtime: item.overtimer?.current ?? 0,
            sections: RevisionValue(dataSource.makeSections()),
            canTimeSetSave: canSave,
            didTimeSetSaved: RevisionValue(false),
            canStartTimeSet: RevisionValue(false)
        )
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .saveHistory:
            return actionSaveHistory()
            
        case let .updateMemo(memo):
            return actionUpdateMemo(memo)
            
        case .saveTimeSet:
            return actionSaveTimeSet()
            
        case .startTimeSet:
            return actionStartTimeSet()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setMemo(memo):
            state.memo = memo
            return state
            
        case .save:
            state.canTimeSetSave = false
            state.didTimeSetSaved = state.didTimeSetSaved.next(true)
            return state
            
        case .start:
            state.canStartTimeSet = state.canStartTimeSet.next(true)
            return state
        }
    }
    
    // MARK: - action method
    private func actionSaveHistory() -> Observable<Mutation> {
        historyService.updateHistory(history)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in .empty() }
    }
    
    private func actionUpdateMemo(_ memo: String) -> Observable<Mutation> {
        // Update time set's memo
        history.memo = memo
        return .just(.setMemo(memo))
    }
    
    private func actionSaveTimeSet() -> Observable<Mutation> {
        // Create the time set
        timeSetService.createTimeSet(item: timeSetItem).asObservable()
            .do(onNext: { _ in
                // Log save time set event
                self.logger.logEvent(.click, parameters: [
                    .componentName: "save_time_set",
                    .text: "history"
                ])
            })
            .map { _ in .save }
    }
    
    private func actionStartTimeSet() -> Observable<Mutation> {
        // Fetch origin time set item from local database
        timeSetService.fetchTimeSet(id: history.originId)
            .do(onSuccess: { self.timeSetItem = $0 })
            .asObservable()
            .map { _ in .start }
    }
    
    deinit {
        Logger.verbose()
    }
}
