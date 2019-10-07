//
//  SettingViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class SettingViewReactor: Reactor {
    enum Action {
        /// Refresh menu items
        case refresh
    }
    
    enum Mutation {
        /// Set menu sections
        case setSections([SettingSectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Menu sections
        var sections: [SettingSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(appService: AppServiceProtocol) {
        self.appService = appService
        initialState = State(sections: [], shouldSectionReload: true)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return actionRefresh()
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
    private func actionRefresh() -> Observable<Mutation> {
        let alarm = appService.getAlarm()
        let countdown = appService.getCountdown()
        
        let items: [SettingMenu] = [
            .notice,
            .alarm(alarm.title),
            .countdown(countdown),
            .teamInfo,
            .license
        ]
        
        let setSections: Observable<Mutation> = .just(.setSections([SettingSectionModel(model: Void(), items: items)]))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSections, sectionReload)
    }
    
    deinit {
        Logger.verbose()
    }
}
