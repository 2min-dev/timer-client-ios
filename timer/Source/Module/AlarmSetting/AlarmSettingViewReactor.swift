//
//  AlarmSettingViewReactor.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RxDataSources
import ReactorKit

class AlarmSettingViewReactor: Reactor {
    enum Action {
        /// Load countdown menu items
        case load
        
        /// Select menu
        case select(Int)
        
        /// Stop alarm
        case stop
        
        /// Play alarm
        case play(Int)
    }
    
    enum Mutation {
        /// Set played alarm index
        case setPlayIndex(Int)
        
        /// Set selected index
        case setSelectedIndex(Int)
        
        /// Set countdown menu sections
        case setSections([AlarmSettingSectionModel])
    }
    
    struct State {
        /// Last played alarm index
        var playIndex: Int?
        
        /// Current selected index
        var selectedIndex: Int
        
        /// Countdown menu sections
        var sections: RevisionValue<[AlarmSettingSectionModel]>
    }
    
    // MARK: - properties
    var initialState: State
    private let appService: AppServiceProtocol
    
    private var dataSource: AlarmSettingSectionDataSource
    
    // MARK: - constructor
    init(appService: AppServiceProtocol) {
        self.appService = appService
        dataSource = AlarmSettingSectionDataSource()
        
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
            
        case let .select(index):
            return actionSelect(index: index)
            
        case .stop:
            return actionStop()
            
        case let .play(index):
            return actionPlay(at: index)
        }
    }
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setPlayIndex(index):
            state.playIndex = index
            return state
            
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
        let items = Alarm.allCases
        let index = items.firstIndex(of: appService.getAlarm()) ?? 0
        
        dataSource.setItems(items)
        
        let setSections: Observable<Mutation> = .just(.setSections(dataSource.makeSections()))
        let setSelectedIndexPath: Observable<Mutation> = .just(.setSelectedIndex(index))
        
        return .concat(setSections, setSelectedIndexPath)
    }
    
    private func actionSelect(index: Int) -> Observable<Mutation> {
        let items = dataSource.alarmSection
        guard (0 ..< items.count).contains(index) else { return .empty() }
        
        // Save selected alarm
        let alarm = items[index].alarm
        appService.setAlarm(alarm)
        
        return .just(.setSelectedIndex(index))
    }
    
    private func actionStop() -> Observable<Mutation> {
        let state = currentState
        guard let index = state.playIndex else { return .empty() }
        
        // Emit stop action to mutate alarm item state
        dataSource.alarmSection[index].action.onNext(.stop)
        
        return .empty()
    }
    
    private func actionPlay(at index: Int) -> Observable<Mutation> {
        let state = currentState
        let items = dataSource.alarmSection
        guard (0 ..< items.count).contains(index) else { return .empty() }
        
        if let previousIndex = state.playIndex {
            // Emit stop action to mutate previous alarm item state
            items[previousIndex].action.onNext(.stop)
        }
        // Emit play action to mutate current alarm item state
        items[index].action.onNext(.play)
        
        return .just(.setPlayIndex(index))
    }
    
    deinit {
        Logger.verbose()
    }
}

// MARK: - alarm setting datasource
typealias AlarmSettingSectionModel = SectionModel<Void, AlarmSettingTableViewCellReactor>

typealias AlarmSettingCellType = AlarmSettingTableViewCellReactor

struct AlarmSettingSectionDataSource {
    // MARK: - section
    private(set) var alarmSection: [AlarmSettingCellType] = []
    
    // MARK: - public method
    mutating func setItems(_ items: [Alarm]) {
        alarmSection = items
            .map { AlarmSettingTableViewCellReactor(alarm: $0) }
    }
    
    func makeSections() -> [AlarmSettingSectionModel] {
        [AlarmSettingSectionModel(model: Void(), items: alarmSection)]
    }
}
