//
//  AlarmSettingViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class AlarmSettingViewReactor: Reactor {
    enum Action {
        /// Load countdown menu items when view did load
        case viewDidLoad
        
        /// Select menu
        case select(IndexPath)
    }
    
    enum Mutation {
        /// Set selected index path
        case setSelectedIndexPath(IndexPath)
        
        /// Set countdown menu sections
        case setSections([AlarmSettingSectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Current selected index path
        var selectedIndexPath: IndexPath
        
        /// Countdown menu sections
        var sections: [AlarmSettingSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServicePorotocol
    
    // MARK: - constructor
    init(appService: AppServicePorotocol) {
        self.appService = appService
        initialState = State(selectedIndexPath: IndexPath(item: 0, section: 0),
                             sections: [],
                             shouldSectionReload: true)
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return actionViewDidLoad()
            
        case let .select(indexPath):
            return actionSelect(indexPath: indexPath)
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setSelectedIndexPath(indexPath):
            state.selectedIndexPath = indexPath
            return state
            
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
        let items: [AlarmSettingMenu] = [
            AlarmSettingMenu(title: "기본음"),
            AlarmSettingMenu(title: "진동"),
            AlarmSettingMenu(title: "무음")
        ]
        
        let setSections: Observable<Mutation> = .just(.setSections([AlarmSettingSectionModel(model: Void(), items: items)]))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSections, sectionReload)
    }
    
    private func actionSelect(indexPath: IndexPath) -> Observable<Mutation> {
        // TODO: Save selected default alarm
        return .just(.setSelectedIndexPath(indexPath))
    }
    
    deinit {
        Logger.verbose()
    }
}
