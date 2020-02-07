//
//  SettingViewReactor.swift
//  timer
//
//  Created by Jeong Jin Eun on 09/04/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
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
    }
    
    struct State {
        /// App version is latest
        var isLatestVersion: Bool?
        
        /// Menu sections
        var sections: RevisionValue<[SettingSectionModel]>
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    
    private var dataSource: SettingSectionDataSource
    
    private var disposeBag = DisposeBag()
    
    // MARK: - constructor
    init(appService: AppServiceProtocol) {
        self.appService = appService
        dataSource = SettingSectionDataSource()
        
        initialState = State(sections: RevisionValue(dataSource.makeSections()))
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
        
        switch mutation {
        case let .setLatestVersion(isLatestVersion):
            state.isLatestVersion = isLatestVersion
            return state
            
        case let .setSections(sections):
            state.sections = state.sections.next(sections)
            return state
        }
    }
    
    // MARK: - action method
    private func actionLoadMenu() -> Observable<Mutation> {
        let alarm = appService.getAlarm()
        let countdown = appService.getCountdown()
        
        dataSource.setItems([
            .notice,
            .alarm(alarm.title),
            .countdown(countdown),
            .teamInfo,
            .license
        ])
        
        return .just(.setSections(dataSource.makeSections()))
    }
    
    private func actionVersionCheck() -> Observable<Mutation> {
        appService.getVersion()
            .map {
                // Return current app version is latest
                guard let app = Constants.appVersion, let appVersion = Version(app) else { return true }
                return appVersion >= $0
            }
            .catchErrorJustReturn(true)
            .asObservable()
            .map { .setLatestVersion($0) }
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - setting datasource
typealias SettingSectionModel = SectionModel<Void, SettingMenu>

typealias SettingCellType = SettingMenu

struct SettingSectionDataSource {
    // MARK: - section
    private var menuSection: [SettingCellType] = []
    
    // MARK: - public method
    mutating func setItems(_ items: [SettingMenu]) {
        menuSection = items
    }
    
    func makeSections() -> [SettingSectionModel] {
        [SettingSectionModel(model: Void(), items: menuSection)]
    }
}
