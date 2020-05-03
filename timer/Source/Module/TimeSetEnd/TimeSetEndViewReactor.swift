//
//  TimeSetEndViewReactor.swift
//  timer
//
//  Created by JSilver on 22/08/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class TimeSetEndViewReactor: Reactor {
    enum Action {
        /// Update history to save
        case saveHistory
        
        /// Update memo of current time set
        case updateMemo(String)
        
        /// Save the time set
        case saveTimeSet
    }
    
    enum Mutation {
        /// Set memo of time set
        case setMemo(String)
        
        /// Set did time set saved `true`
        case save
    }
    
    struct State {
        /// Title of time set
        let title: String
        
        /// Started date of the time set
        let startDate: Date
        
        /// Ended date of the time set
        let endDate: Date
        
        /// Memo of time set
        var memo: String
        
        /// Flag that represent current time set can save
        var canTimeSetSave: Bool
        
        /// Flag that time set is saved
        var didTimeSetSaved: RevisionValue<Bool?>
    }
    
    // MARK: - properties
    var initialState: State
    private let historyService: HistoryServiceProtocol
    private let timeSetService: TimeSetServiceProtocol
    private let logger: Logger
    
    private let history: History
    
    private var savedTimeSetItem: TimeSetItem?
    var timeSetItem: TimeSetItem? {
        if let timeSet = savedTimeSetItem {
            return timeSet
        } else {
            guard let copiedObject = history.item?.copy() as? TimeSetItem else { return nil }
            copiedObject.reset()
            
            return copiedObject
        }
    }
    
    // MARK: - constructor
    init(historyService: HistoryServiceProtocol, timeSetService: TimeSetServiceProtocol, logger: Logger, history: History, canSave: Bool) {
        self.historyService = historyService
        self.timeSetService = timeSetService
        self.logger = logger
        self.history = history
        
        initialState = State(
            title: history.item?.title ?? "",
            startDate: history.startDate ?? Date(),
            endDate: history.endDate ?? Date(),
            memo: history.memo,
            canTimeSetSave: canSave,
            didTimeSetSaved: RevisionValue(nil)
        )
    }
    
    // MARK: - Mutate
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
    
    // MARK: - Reduce
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
        _ = historyService.updateHistory(history).subscribe()
        return .empty()
    }
    
    private func actionUpdateMemo(_ memo: String) -> Observable<Mutation> {
        // Update time set's memo
        history.memo = memo
        return .just(.setMemo(memo))
    }
    
    private func actionSaveTimeSet() -> Observable<Mutation> {
        guard let timeSetItem = timeSetItem else { return .empty() }
        // Create the time set
        return timeSetService.createTimeSet(item: timeSetItem).asObservable()
            .do(onNext: { self.savedTimeSetItem = $0 })
            .do(onNext: { _ in
                // Log save time set event
                self.logger.logEvent(.click, parameters: [
                    .componentName: "save_time_set",
                    .text: "end"
                ])
            })
            .map { _ in .save }
    }
    
    deinit {
        Logger.verbose()
    }
}
