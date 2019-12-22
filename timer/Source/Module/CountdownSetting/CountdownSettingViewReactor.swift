//
//  CountdownSettingViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
import ReactorKit

class CountdownSettingViewReactor: Reactor {
    enum Action {
        /// Load countdown menu items
        case load
        
        /// Select menu
        case select(IndexPath)
    }
    
    enum Mutation {
        /// Set selected index path
        case setSelectedIndex(Int)
        
        /// Set countdown menu sections
        case setSections([CountdownSettingSectionModel])
    }
    
    struct State {
        /// Current selected index
        var selectedIndex: Int
        
        /// Countdown menu sections
        var sections: RevisionValue<[CountdownSettingSectionModel]>
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    
    private var dataSource: CountdownSettingSectionDataSource
    
    // MARK: - constructor
    init(appService: AppServiceProtocol) {
        self.appService = appService
        dataSource = CountdownSettingSectionDataSource()
        
        initialState = State(
            selectedIndex: 0,
            sections: RevisionValue(dataSource.makeSections())
        )
    }
    
    // MARK: - mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return actionLoad()
            
        case let .select(indexPath):
            return actionSelect(indexPath: indexPath)
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setSelectedIndex(index):
            state.selectedIndex = index
            return state
            
        case let .setSections(sections):
            state.sections = state.sections.next(sections)
            return state
        }
    }
    
    // MARK: - action method
    private func actionLoad() -> Observable<Mutation> {
        let items: [CountdownSettingMenu] = [
            CountdownSettingMenu(seconds: 10),
            CountdownSettingMenu(seconds: 5),
            CountdownSettingMenu(seconds: 3),
            CountdownSettingMenu(seconds: 2),
            CountdownSettingMenu(seconds: 1),
            CountdownSettingMenu(seconds: 0)
        ]
        
        dataSource.setItems(items)
        
        let countdown = appService.getCountdown()
        let index = items.firstIndex(where: { $0.seconds == countdown }) ?? 0
        
        let setSections: Observable<Mutation> = .just(.setSections(dataSource.makeSections()))
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndex(index))
        
        return .concat(setSections, setSelectedIndexPath)
    }
    
    private func actionSelect(indexPath: IndexPath) -> Observable<Mutation> {
        // Save selected countdown seconds
        let countdown = dataSource.countdownSection[indexPath.item].seconds
        appService.setCountdown(countdown)
        
        return .just(.setSelectedIndex(indexPath.item))
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - countdown setting datasource
typealias CountdownSettingSectionModel = SectionModel<Void, CountdownSettingMenu>

typealias CountdownSettingCellType = CountdownSettingMenu

struct CountdownSettingSectionDataSource {
    // MARK: - section
    private(set) var countdownSection: [CountdownSettingCellType] = []
    
    // MARK: - public method
    mutating func setItems(_ items: [CountdownSettingMenu]) {
        countdownSection = items
    }
    
    func makeSections() -> [CountdownSettingSectionModel] {
        [CountdownSettingSectionModel(model: Void(), items: countdownSection)]
    }
}
