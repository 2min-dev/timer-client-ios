//
//  NoticeDetailViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

class NoticeDetailViewReactor: Reactor {
    enum Action {
        /// Load notice content to refresh
        case refresh
    }
    
    enum Mutation {
        /// Set notice content
        case setContent(String)
        
        /// Set loading flag
        case setLoading(Bool)
    }
    
    struct State {
        /// Title of notice
        let title: String
        
        /// Created date of notice
        let date: Date
        
        /// Content of notice
        var content: String
        
        /// Is loading to process
        var isLoading: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    private let notice: Notice
    
    // MARK: - constructor
    init(appService: AppServiceProtocol, notice: Notice) {
        self.appService = appService
        self.notice = notice
        
        initialState = State(title: notice.title, date: notice.date, content: "", isLoading: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return actionRefresh()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setContent(content):
            state.content = content
            return state
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let requestNoticeDetail: Observable<Mutation> = appService.fetchNoticeDetail(id: notice.id)
            .asObservable()
            .map { .setContent($0.content) }
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        return .concat(startLoading, requestNoticeDetail, endLoading)
    }
    
    deinit {
        Logger.verbose()
    }
}
