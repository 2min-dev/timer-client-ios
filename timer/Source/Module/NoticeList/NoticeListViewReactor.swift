//
//  NoticeListViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class NoticeListViewReactor: Reactor {
    enum Action {
        /// Load notice list when view did load
        case viewDidLoad
    }
    
    enum Mutation {
        /// Set countdown menu sections
        case setSections([NoticeListSectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Countdown menu sections
        var sections: [NoticeListSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    
    // MARK: - constructor
    init() {
        self.initialState = State(sections: [], shouldSectionReload: true)
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
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setSections(sections):
            state.sections = sections
            return state
            
        case .sectionReload:
            state.shouldSectionReload = true
            return state
        }
    }
    
    // MARK: - action method
    private func actionViewDidLoad() -> Observable<Mutation> {
        // TODO: Load notice from server
        let items: [Notice] = [
            Notice(id: 1, title: "샘플 공지사항", date: Date()),
            Notice(id: 2, title: "공지사항 타이틀 입력 제한 테스트 테스트 테스트 테스트", date: Date()),
            Notice(id: 3, title: "취업하고싶습니다.", date: Date()),
            Notice(id: 4, title: "뽑아주세요.", date: Date())
        ]
        
        let setSections: Observable<Mutation> = .just(.setSections([NoticeListSectionModel(model: Void(), items: items)]))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSections, sectionReload)
    }
    
    deinit {
        Logger.verbose()
    }
}
