//
//  NoticeDetailViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class NoticeDetailViewReactor: Reactor {
    enum Action {
        /// Load notice content when view did load
        case viewDidLoad
    }
    
    enum Mutation {
        /// Set notice content
        case setContent(String)
    }
    
    struct State {
        /// Title of notice
        let title: String
        
        /// Created date of notice
        let date: Date
        
        /// Content of notice
        var content: String
    }
    
    // MARK: - properties
    var initialState: State
    private let notice: Notice
    
    // MARK: - constructor
    init(notice: Notice) {
        self.notice = notice
        initialState = State(title: notice.title, date: notice.date, content: "")
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return actionViewDidLoad()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setContent(content):
            state.content = content
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewDidLoad() -> Observable<Mutation> {
        // TODO: request notice content from server
        return .just(.setContent("""
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항 샘플 공지사항
"""))
    }
    
    deinit {
        Logger.verbose()
    }
}
