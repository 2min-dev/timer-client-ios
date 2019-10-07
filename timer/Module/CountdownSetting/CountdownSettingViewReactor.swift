//
//  CountdownSettingViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import ReactorKit

class CountdownSettingViewReactor: Reactor {
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
        case setSections([CountdownSettingSectionModel])
        
        /// Set should section reload `true`
        case sectionReload
    }
    
    struct State {
        /// Current selected index path
        var selectedIndexPath: IndexPath
        
        /// Countdown menu sections
        var sections: [CountdownSettingSectionModel]
        
        /// Need to reload section
        var shouldSectionReload: Bool
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    
    // MARK: - constructor
    init(appService: AppServiceProtocol) {
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
        let items: [CountdownSettingMenu] = [
            CountdownSettingMenu(seconds: 5),
            CountdownSettingMenu(seconds: 10),
            CountdownSettingMenu(seconds: 3),
            CountdownSettingMenu(seconds: 2),
            CountdownSettingMenu(seconds: 1),
            CountdownSettingMenu(seconds: 0)
        ]
        
        let countdown = appService.getCountdown()
        var indexPath = IndexPath(item: 0, section: 0)
        if let index = items.firstIndex(where: { $0.seconds == countdown }) {
            indexPath = IndexPath(item: index, section: 0)
        }
        
        let setSections: Observable<Mutation> = .just(.setSections([CountdownSettingSectionModel(model: Void(), items: items)]))
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndexPath(indexPath))
        let sectionReload: Observable<Mutation> = .just(.sectionReload)
        
        return .concat(setSections, setSelectedIndexPath, sectionReload)
    }
    
    private func actionSelect(indexPath: IndexPath) -> Observable<Mutation> {
        // Save selected countdown seconds
        let countdown = currentState.sections[indexPath.section].items[indexPath.row].seconds
        appService.setCountdown(countdown)
        
        return .just(.setSelectedIndexPath(indexPath))
    }
    
    deinit {
        Logger.verbose()
    }
}
