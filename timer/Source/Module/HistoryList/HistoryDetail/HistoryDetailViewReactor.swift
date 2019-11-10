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
    }
    
    enum Mutation {
        /// Set memo of the time set
        case setMemo(String)
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
        
        /// Section datasource to make sections
        let sectionDataSource: TimerBadgeDataSource
        
        /// The timer list badge sections
        var sections: [TimerBadgeSectionModel] {
            sectionDataSource.makeSections()
        }
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let timeSetService: TimeSetServiceProtocol
    
    private let history: History
    var origin: TimeSetItem? {
        guard let copiedObject = history.item?.copy() as? TimeSetItem else { return nil }
        copiedObject.reset()
        
        return copiedObject
    }
    
    // MARK: - constructor
    init?(timeSetService: TimeSetServiceProtocol, history: History) {
        guard let item = history.item, let startDate = history.startDate, let endDate = history.endDate else { return nil }
        
        self.timeSetService = timeSetService
        self.history = history
        initialState = State(title: item.title,
                             runningTime: history.runningTime,
                             startDate: startDate,
                             endDate: endDate,
                             extraTime: item.timers.reduce(0) { $0 + $1.extra },
                             repeatCount: history.repeatCount,
                             memo: item.memo,
                             sectionDataSource: TimerBadgeDataSource(timers: item.timers.toArray()),
                             shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .saveHistory:
            return actionSaveHistory()
            
        case let .updateMemo(memo):
            return actionUpdateMemo(memo)
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setMemo(memo):
            state.memo = memo
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
        history.item?.memo = memo
        return .just(.setMemo(memo))
    }
    
    deinit {
        Logger.verbose()
    }
}
