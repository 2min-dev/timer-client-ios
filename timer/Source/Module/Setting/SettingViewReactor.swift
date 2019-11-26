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
        /// Load menu items
        case loadMenu
        
        /// Check app version
        case versionCheck
    }
    
    enum Mutation {
        /// Set is app version latest
        case setLatestVersion(Bool)
        
        /// Set menu sections
        case setSections([SettingSectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// App version is latest
        var isLatestVersion: Bool?
        
        /// Menu sections
        var sections: [SettingSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(appService: AppServiceProtocol, networkService: NetworkServiceProtocol) {
        self.appService = appService
        self.networkService = networkService
        
        initialState = State(sections: [], shouldSectionReload: true)
    }
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadMenu:
            return actionLoadMenu()
            
        case .versionCheck:
            return actionVersionCheck()
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldSectionReload = false
        
        switch mutation {
        case let .setLatestVersion(isLatestVersion):
            state.isLatestVersion = isLatestVersion
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
    private func actionLoadMenu() -> Observable<Mutation> {
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
    
    private func actionVersionCheck() -> Observable<Mutation> {
        networkService.requestAppVersion().asObservable()
            .map {
                guard let app = Constants.appVersion, let appVersion = Version(app) else { return true }
                guard let latestVersion = Version($0.version) else { return true }
                // Return current app version is latest
                return appVersion >= latestVersion
            }
            .map { .setLatestVersion($0) }
    }
    
    deinit {
        Logger.verbose()
    }
}
