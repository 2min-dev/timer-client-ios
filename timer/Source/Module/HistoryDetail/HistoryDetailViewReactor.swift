//
//  HistoryDetailViewReactor.swift
//  timer
//
//  Created by JSilver on 2019/10/15.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

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
    }
    
    enum Mutation {
        /// Set memo of the time set
        case setMemo(String)
        
        /// Set did time set saved `true`
        case save
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
        
        /// Flag that time set is saved
        var didTimeSetSaved: RevisionValue<Bool?>
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    private let history: History
    var timeSetItem: TimeSetItem
    
    private var dataSource: TimerBadgeSectionDataSource
    
    // MARK: - constructor
    init?(timeSetService: TimeSetServiceProtocol, history: History, canSave: Bool) {
        // Check required properties of history
        guard let item = history.item,
            let startDate = history.startDate,
            let endDate = history.endDate else {
                Logger.error("history object not fulfill required properties", tag: "HISTORY DETAIL")
                return nil
        }
        
        // Copy & reset history's item to rollback to use
        guard let timeSetItem = history.item?.copy() as? TimeSetItem else { return nil }
        timeSetItem.reset()
        timeSetItem.isSaved = history.originId > 0
        
        self.timeSetService = timeSetService
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
            didTimeSetSaved: RevisionValue(nil)
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
        }
    }
    
    // MARK: - action method
    private func actionSaveHistory() -> Observable<Mutation> {
        return timeSetService.updateHistory(history).asObservable()
            .flatMap { _ -> Observable<Mutation> in .empty() }
    }
    
    private func actionUpdateMemo(_ memo: String) -> Observable<Mutation> {
        // Update time set's memo
        history.memo = memo
        return .just(.setMemo(memo))
    }
    
    private func actionSaveTimeSet() -> Observable<Mutation> {
        // Create the time set
        timeSetService.createTimeSet(item: timeSetItem)
            .do(onSuccess: {
                self.timeSetItem = $0
                self.history.originId = $0.id
            })
            .flatMap { _ in self.timeSetService.updateHistory(self.history) }
            .asObservable()
            .map { _ in .save }
    }
    
    deinit {
        Logger.verbose()
    }
}
