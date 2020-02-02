//
//  NoticeListViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
import ReactorKit

class NoticeListViewReactor: Reactor {
    enum Action {
        /// Load notice list to refresh
        case refresh
    }
    
    enum Mutation {
        /// Set countdown menu sections
        case setSections([NoticeListSectionModel]?)
        
        /// Set loading flag
        case setLoading(Bool)
    }
    
    struct State {
        /// Countdown menu sections
        var sections: RevisionValue<[NoticeListSectionModel]?>
        
        /// Is loading to process
        var isLoading: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    
    private var dataSource: NoticeListSectionDataSource
    
    // MARK: - constructor
    init(appService: AppServiceProtocol) {
        self.appService = appService
        dataSource = NoticeListSectionDataSource()
        
        initialState = State(
            sections: RevisionValue(dataSource.makeSections()),
            isLoading: true
        )
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
        case let .setSections(sections):
            state.sections = state.sections.next(sections)
            return state
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return state
        }
    }
    
    // MARK: - action method
    private func actionRefresh() -> Observable<Mutation> {
        guard dataSource.noticeSection == nil else { return .empty() }
        
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        let requestNoticeList: Observable<Mutation> = appService.fetchNoticeList()
            .catchErrorJustReturn([])
            .do(onSuccess: { self.dataSource.setItems($0) })
            .asObservable()
            .map { _ in .setSections(self.dataSource.makeSections()) }
        let endLoading: Observable<Mutation> = .just(.setLoading(false))
        
        return .concat(startLoading, requestNoticeList, endLoading)
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - countdown setting datasource
typealias NoticeListSectionModel = SectionModel<Void, Notice>

typealias NoticeListCellType = Notice

struct NoticeListSectionDataSource {
    // MARK: - section
    private(set) var noticeSection: [NoticeListCellType]?
    
    // MARK: - public method
    mutating func setItems(_ items: [Notice]) {
        noticeSection = items
    }
    
    func makeSections() -> [NoticeListSectionModel]? {
        guard let items = noticeSection else { return nil }
        return [NoticeListSectionModel(model: Void(), items: items)]
    }
}
